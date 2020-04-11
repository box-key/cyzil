from libcpp.vector cimport vector
from libcpp.string cimport string


ctypedef float DTYPE


# if I can cast input type, i don't need this method
cpdef vector[string] _list2vec(list data):
  cdef vector[string] _data = [token.encode("utf-8") for token in data]
  return _data


cpdef void _assign_zeros(vector[int] &vec):
  for v in vec:
    v = 0


cpdef int edit_distance_sentence(list sen1, list sen2):
  cdef vector[string] _sen1 = _list2vec(sen1)
  cdef vector[string] _sen2 = _list2vec(sen2)
  cdef int len_s1 = _sen1.size() + 1
  cdef int len_s2 = _sen2.size() + 1
  if (len_s1 == 0) or (len_s2 == 0):
    return max(len_s1, len_s2)
  if len_s1 > len_s2:
    _sen1, _sen2 = _sen2, _sen1
    len_s1, len_s2 = len_s2, len_s1
  cdef vector[int] distances = range(len_s1)
  distances.reserve(len_s1)
  cdef vector[int] dist_temp = [0]*len_s1
  dist_temp.reserve(len_s1)
  cdef int val
  cdef string _w1
  cdef string _w2
  for i2, w2 in enumerate(_sen2):
    _w2 = <string> w2
    dist_temp[0] = i2 + 1
    for i1, w1 in enumerate(_sen1):
      _w1 = <string> w1
      # w1 is the same with w2, store the previous cell
      if _w1.compare(_w2) == 0:
        dist_temp[i1+1] = distances[i1]
      else:
        val = 1 + min((distances[i1], distances[i1+1], dist_temp[i1]))
        dist_temp[i1+1] = val
    distances = dist_temp
    _assign_zeros(dist_temp)
  return distances.back()


cpdef vector[DTYPE] edit_distance_corpus(list reference_corpus,
                                          list candidate_corpus):
  assert len(reference_corpus) == len(candidate_corpus), \
        'reference corpus and candiate corpus should have the same length'
  assert isinstance(reference_corpus[0], list), \
        'reference corpus should be a list of lists'
  assert isinstance(candidate_corpus[0], list), \
        'candidate corpus should be a list of lists'
  # corpus_score[0]: edit distance, corpus_score[1]: normalized edit distance
  cdef vector[DTYPE] corpus_score = [0.0, 0.0]
  corpus_score.reserve(2)
  cdef int sentence_score
  # Iterate through corpus
  for reference, candidate in zip(reference_corpus, candidate_corpus):
    sentence_score = edit_distance_sentence(reference, candidate)
    corpus_score[0] += sentence_score
    corpus_score[1] += (<float> sentence_score/len(reference))
  corpus_score[0] /= len(reference_corpus)
  corpus_score[1] /= len(reference_corpus)
  return corpus_score


cpdef vector[vector[DTYPE]] edit_distance_points(list reference_corpus,
                                                 list candidate_corpus):
  assert len(reference_corpus)==len(candidate_corpus), \
        'reference corpus and candiate corpus should have the same length'
  assert isinstance(reference_corpus[0], list), \
        'reference corpus should be a list of lists'
  assert isinstance(candidate_corpus[0], list), \
        'candidate corpus should be a list of lists'
  # points[:, 0]: edit distance, points[:, 1]: normalized edit distance
  cdef vector[vector[DTYPE]] points
  points.reserve(len(reference_corpus))
  cdef int point_score
  cdef DTYPE normalized_score
  # Iterate through corpus
  for reference, candidate in zip(reference_corpus, candidate_corpus):
    point_score = edit_distance_sentence(reference, candidate)
    normalized_score = <DTYPE> point_score/len(reference)
    points.push_back([<DTYPE> point_score, normalized_score])
  return points
