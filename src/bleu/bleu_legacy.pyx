import numpy as np
cimport numpy as np
from libcpp.vector cimport vector
from libcpp.string cimport string
from libcpp.map cimport map
import re

DTYPE = np.float32
ctypedef np.float_t DTYPE_t
cdef string DELIM = ' '

cpdef vector[string] _copy_list(list data):
  cdef vector[string] _data
  for s in data:
    _data.push_back(s.encode("utf-8"))
  return _data

cpdef map[string,int] _test(list sentence, int max_order):
  cdef vector[string] _sentence = _copy_list(sentence)
  return _count_ngram(_sentence,max_order)

cpdef map[string,int] _get_overlap(map[string,int] m1, map[string,int] m2):
  cdef map[string,int] overlap
  cdef int c2
  # store elements appear both in m1 and m2
  for t1, c1 in m1:
    # if a token exists in both m1 and m2, take the smallest value
    if m2.count(t1)>0:
      c2 = m2[t1]
      overlap[t1] = min(c1,c2)
  return overlap

cpdef map[string,int] _count_ngram(vector[string] sentence, int max_order):
  cdef int size = sentence.size()
  cdef map[string, int] ngram_counts
  cdef string ngram

  for order in range(1, max_order+1):
    for i in range(0, size-order+1):
        ngram = ''
        for token in sentence[i:i+order]:
          ngram = ngram + token + DELIM
        if ngram_counts.count(ngram)>0:
          ngram_counts[ngram] += 1
        else:
          ngram_counts[ngram] = 1

  return ngram_counts

cpdef vector[float] bleu_sentence(list reference, list candidate, int max_order):
  cdef vector[float] scores
  scores.reserve(3)
  for i in range(3):
    scores.push_back(0)

  if (len(reference)==0) or (len(candidate)==0):
    return scores

  cdef vector[string] _reference = _copy_list(reference)
  cdef vector[string] _candidate = _copy_list(candidate)

  cdef map[string,int] reference_count = _count_ngram(_reference, max_order)
  cdef map[string,int] candidate_count = _count_ngram(_candidate, max_order)
  cdef map[string,int] overlap = _get_overlap(reference_count, candidate_count)

  cdef np.ndarray[DTYPE_t, ndim=1] clipped_count = np.zeros(max_order)
  cdef int order
  for ngram_token, count in overlap:
    # count the number of delimiters as n-gram order; refer to count_ngram
    order = len(re.findall(DELIM, ngram_token))
    # count the number of occurence of token
    clipped_count[order-1] += count

  # avoid division by 0
  cdef int norm
  for order in range(max_order):
    norm = _candidate.size()-order
    if norm>0:
      clipped_count[order] /= norm

  cdef float precision, bp
  if min(clipped_count)>0:
    log = np.log(clipped_count)/max_order
    precision = np.exp(log.sum())
  else:
    precision = 0

  cdef float ratio = (<float>_reference.size()/_candidate.size())
  bp = np.exp(min(1.-ratio,0))

  scores[0] += precision
  scores[1] += bp
  scores[2] += precision*bp

  return scores

cpdef vector[float] bleu_corpus(list reference_corpus, list candidate_corpus, int max_ngram):

  assert len(reference_corpus)==len(candidate_corpus), \
        'reference corpus and candiate corpus should have the same length'
  assert isinstance(reference_corpus[0], list), \
        'reference corpus should be a list of lists'
  assert isinstance(candidate_corpus[0], list), \
        'candidate corpus should be a list of lists'


  # corpus_score[0]: precision, corpus_score[1]: bp, corpus_score[2]: bleu
  cdef vector[float] corpus_score
  corpus_score.reserve(3)
  for i in range(3):
    corpus_score.push_back(0)
  cdef vector[float] sentence_score

  for reference, candidate in  zip(reference_corpus, candidate_corpus):
    sentence_score = bleu_sentence(reference, candidate, max_ngram)
    corpus_score[0] += sentence_score[0]
    corpus_score[1] += sentence_score[1]
    corpus_score[2] += sentence_score[2]

  cdef int n = len(candidate_corpus)
  corpus_score[0] /= n
  corpus_score[1] /= n
  corpus_score[2] /= n

  return corpus_score

cpdef np.ndarray bleu_points(list reference_corpus, list candidate_corpus, int max_ngram):

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
    points[row_idx][0] += sentence_score[0]
    points[row_idx][1] += sentence_score[1]
    points[row_idx][2] += sentence_score[2]
    row_idx += 1

  return points
