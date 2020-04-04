import numpy as np
cimport numpy as np

DTYPE = np.int
ctypedef np.int_t DTYPE_t

def edit_distance_by_token(np.ndarray sen1, np.ndarray sen2):
  cdef int len_s1 = len(sen1)+1
  cdef int len_s2 = len(sen2)+1

  if len_s1==0 or len_s2==0:
    return max(len_s1, len_s2)

  if len_s1 > len_s2:
    sen1, sen2 = sen2, sen1


  cdef np.ndarray[DTYPE_t, ndim=1] distances = np.arange(len_s1, dtype=DTYPE)
  cdef np.ndarray[DTYPE_t, ndim=1] dist_temp
  for i2, c2 in enumerate(sen2):
    dist_temp = np.zeros((len_s1,), dtype=np.int)
    dist_temp[0] = i2+1
    for i1, c1 in enumerate(sen1):
      dist_temp[i1+1] = distances[i1] if c1==c2 else 1 + min((distances[i1], distances[i1 + 1], dist_temp[i1]))
    distances = dist_temp

  return distances[-1]
