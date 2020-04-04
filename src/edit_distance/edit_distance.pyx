import numpy as np
cimport numpy as np
from libcpp.vector cimport vector
from libcpp.string cimport string

DTYPE = np.float32
ctypedef np.float_t DTYPE_t

cpdef vector[string] _copy_list(list data):
  cdef vector[string] _data
  for _str in data:
    _data.push_back(_str.encode("utf-8"))
  return _data

cpdef void _assign_zeros(vector[int]& vec):
  for v in vec:
    v = 0

cpdef vector[int] _make_zeros(int size):
  cdef vector[int] zeros
  for i in range(size):
    zeros.push_back(0)
  return zeros

cpdef int edit_distance_sentence(list sen1, list sen2):
  cdef int len_s1 = len(sen1)+1
  cdef int len_s2 = len(sen2)+1

  if len_s1==0 or len_s2==0:
    return max(len_s1, len_s2)

  if len_s1 > len_s2:
    sen1, sen2 = sen2, sen1
    len_s1, len_s2 = len_s2, len_s1

  cdef vector[string] _sen1 = _copy_list(sen1)
  cdef vector[string] _sen2 = _copy_list(sen2)

  cdef vector[int] distances = range(len_s1)
  distances.reserve(len_s1)

  cdef vector[int] dist_temp = _make_zeros(len_s1)
  dist_temp.reserve(len_s1)

  cdef int comp
  cdef string w1,w2
  for i2, c2 in enumerate(_sen2):
    w2 = <string> c2
    dist_temp[0] = i2+1
    for i1, c1 in enumerate(_sen1):
      w1 = <string> c1
      comp = w1.compare(w2)
      dist_temp[i1+1] = distances[i1] if comp==0 else 1 + min((distances[i1], distances[i1+1], dist_temp[i1]))
    distances = dist_temp
    _assign_zeros(dist_temp)

  return distances.back()

cpdef vector[double] edit_distance_corpus(list reference_corpus, list candidate_corpus):

  assert len(reference_corpus)==len(candidate_corpus), \
        'reference corpus and candiate corpus should have the same length'
  assert isinstance(reference_corpus[0], list), \
        'reference corpus should be a list of lists'
  assert isinstance(candidate_corpus[0], list), \
        'candidate corpus should be a list of lists'


  # corpus_score[0]: edit distance, corpus_score[1]: normalized edit distance
  cdef vector[double] corpus_score
  corpus_score.reserve(2)
  corpus_score.push_back(0.0)
  corpus_score.push_back(0.0)

  cdef int sentence_score

  for reference, candidate in  zip(reference_corpus, candidate_corpus):
    sentence_score = edit_distance_sentence(reference, candidate)
    corpus_score[0] += sentence_score
    corpus_score[1] += (<float>sentence_score/len(reference))

  corpus_score[0] /= len(reference_corpus)
  corpus_score[1] /= len(reference_corpus)

  return corpus_score

cpdef np.ndarray edit_distance_points(list reference_corpus, list candidate_corpus):

  assert len(reference_corpus)==len(candidate_corpus), \
        'reference corpus and candiate corpus should have the same length'
  assert isinstance(reference_corpus[0], list), \
        'reference corpus should be a list of lists'
  assert isinstance(candidate_corpus[0], list), \
        'candidate corpus should be a list of lists'


  # corpus_score[:, 0]: edit distance, corpus_score[:, 1]: normalized edit distance
  cdef np.ndarray points = np.zeros([len(reference_corpus), 2], dtype=DTYPE)
  cdef int row_idx = 0
  cdef int point_score

  for reference, candidate in  zip(reference_corpus, candidate_corpus):
    point_score = edit_distance_sentence(reference, candidate)
    points[row_idx][0] += point_score
    points[row_idx][1] += (<float>point_score/len(reference))
    row_idx += 1

  return points
