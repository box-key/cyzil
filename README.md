# Description

Cyzil provides fast libraries that compute various metrics for machine translation, implemented in Cython.
So far, it covers [edit distance (Levenstein Distance)](https://en.wikipedia.org/wiki/Levenshtein_distance) and BLEU score proposed by [Papineni et al. (2002)](https://www.aclweb.org/anthology/P02-1040.pdf).

# Dependencies
* Python 3.7+

# Usage

``` python
import bleu
import edit_distance as e

reference = 'this is a test'.split()
candidate = 'this is a test'.split()

# bleu_sentence takes a list of strings
bleu.bleu_sentence(reference, candidate, max_ngram=4)
# bleu_corpus takes a list of lists
bleu.bleu_corpus([reference], [candidate], max_ngram=4)
# bleu_points takes a list of lists
bleu.bleu_points([reference], [candidate], max_ngram=4)

# edit_distance_sentence takes a list of strings
e.edit_distance_sentence(reference, candidate)
# edit_distance_corpus takes a list of lists
e.edit_distance_corpus([reference], [candidate], max_ngram=4)
# edit_distance_points takes a list of lists
e.edit_distance_points([reference], [candidate], max_ngram=4)


```

# Testing

1. `git clone` this repository
1. `cd` into the repository
1. run `python setup.py develop`. this will create local files under the root.
1. run `python cyzil_test.py`