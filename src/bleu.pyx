import numpy as np
cimport numpy as np
from libcpp.vector cimport vector
from libcpp.string cimport string
from libcpp.map cimport map


DTYPE = np.float32
ctypedef np.float32_t DTYPE_t
cdef string DELIM = ' '


cpdef vector[string] _copy_list(list data):
  cdef vector[string] _data
  for s in data:
    _data.push_back(s.encode("utf-8"))
  return _data


cpdef map[string, int] _get_overlap(map[string, int] m1,
                                    map[string, int] m2):
  cdef map[string, int] overlap
  cdef int c2
  # store elements appear both in m1 and m2
  for t1, c1 in m1:
    # if a token exists in both m1 and m2, store the smallest count
    if m2.count(t1):
      c2 = m2[t1]
      overlap[t1] = min(c1, c2)
  return overlap


cpdef map[string, int] _count_ngram(vector[string] sentence, int max_order):
  cdef int size = sentence.size()
  cdef map[string, int] ngram_counts
  cdef string ngram
  # Iterate through all orders of ngram
  for order in range(1, max_order + 1):
    # count each order of ngram tokens
    for i in range(0, size - order + 1):
        ngram = ''
        for token in sentence[i : i+order]:
          ngram = ngram + token + DELIM
        if ngram_counts.count(ngram):
          ngram_counts[ngram] += 1
        else:
          ngram_counts[ngram] = 1
  return ngram_counts


cpdef vector[float] bleu_sentence(list reference,
                                  list candidate,
                                  int max_ngram):
  if (len(reference) == 0) or (len(candidate) == 0):
    return [0, 0, 0]
  assert isinstance(reference[0], str), \
      "reference should be a list of strings"
  assert isinstance(candidate[0], str), \
      "candidate should be a list of strings"
  return bleu_corpus([reference], [candidate], max_ngram)


cpdef vector[float] bleu_corpus(list reference_corpus,
                                list candidate_corpus,
                                int max_ngram):
  assert len(reference_corpus)==len(candidate_corpus), \
        'reference corpus and candiate corpus should have the same length'
  assert isinstance(reference_corpus[0], list), \
        'reference corpus should be a list of lists'
  assert isinstance(candidate_corpus[0], list), \
        'candidate corpus should be a list of lists'
  # corpus_score[0]: precision, corpus_score[1]: bp, corpus_score[2]: bleu
  cdef np.ndarray[DTYPE_t, ndim=1] clipped_count = np.zeros(max_ngram, dtype=DTYPE)
  cdef np.ndarray[DTYPE_t, ndim=1] clip_norm = np.zeros(max_ngram, dtype=DTYPE)
  cdef vector[string] _reference
  cdef vector[string] _candidate
  cdef map[string, int] reference_count
  cdef map[string, int] candidate_count
  cdef map[string, int] overlap
  cdef long ref_len = 0
  cdef long cand_len = 0
  # Iterate through corpus
  for reference, candidate in zip(reference_corpus, candidate_corpus):
    _reference = _copy_list(reference)
    _candidate = _copy_list(candidate)
    ref_len += _reference.size()
    cand_len += _candidate.size()
    # count ngrams in reference and candidate
    reference_count = _count_ngram(_reference, max_ngram)
    candidate_count = _count_ngram(_candidate, max_ngram)
    # store overlaps
    overlap = _get_overlap(reference_count, candidate_count)
    # count the occurence of ngram tokens
    for ngram_token, count in overlap:
      clipped_count[len(nram_token.split()) - 1] += count
    for order in range(max_ngram):
      clip_norm[order] += max(_candidate.size() - order, 0)
  cdef float precision
  cdef float bp
  # avoid division by 0
  if min(clipped_count):
    clipped_count /= clip_norm
    precision = np.exp(<float> np.log(clipped_count).sum()/max_ngram)
  else:
    precision = 0
  bp = np.exp(min(1.-(<float> ref_len/cand_len), 0))
  # corpus_score[0]: precision, corpus_score[1]: bp, corpus_score[2]: bleu
  cdef vector[float] corpus_score
  corpus_score.reserve(3)
  corpus_score.push_back(precision)
  corpus_score.push_back(bp)
  corpus_score.push_back(precision*bp)
  return corpus_score


cpdef np.ndarray bleu_points(list reference_corpus,
                             list candidate_corpus,
                             int max_ngram):
  assert len(reference_corpus)==len(candidate_corpus), \
        'reference corpus and candiate corpus should have the same length'
  assert isinstance(reference_corpus[0], list), \
        'reference corpus should be a list of lists'
  assert isinstance(candidate_corpus[0], list), \
        'candidate corpus should be a list of lists'
  # corpus_score[:, 0]: edit distance, corpus_score[:, 1]: normalized edit distance
  cdef np.ndarray points = np.zeros([len(reference_corpus), 3], dtype=DTYPE)
  cdef int row_idx = 0
  cdef vector[float] sentence_score
  for reference, candidate in  zip(reference_corpus, candidate_corpus):
    sentence_score = bleu_sentence(reference, candidate, max_ngram)
    points[row_idx,0] += sentence_score[0]
    points[row_idx,1] += sentence_score[1]
    points[row_idx,2] += sentence_score[2]
    row_idx += 1
  return points
