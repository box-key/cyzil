# Description

Cyzil provides fast libraries that compute various metrics for machine translation, implemented in Cython.
So far, it covers [edit distance (Levenstein Distance)](https://en.wikipedia.org/wiki/Levenshtein_distance) and BLEU score proposed by [Papineni et al. (2002)](https://www.aclweb.org/anthology/P02-1040.pdf).

# Dependencies
* Python 3.7+

# Usage

``` python
import bleu
import edit_distance as e

reference = ['this', 'is', 'a', 'test']
candidate = ['this', 'is', 'a', 'test']

# bleu_sentence takes a list of strings
# it computes bleu score of input sentence
# output: [precision, brevity penalty, bleu score]
bleu.bleu_sentence(reference, candidate, max_ngram=4)

# bleu_corpus takes a list of lists
# it computes the average bleu score of input corpus
# output: [precision, brevity penalty, bleu score]
bleu.bleu_corpus([reference], [candidate], max_ngram=4)

# bleu_points takes a list of lists
# it computes bleu score of each sentence in corpus
# output: [precision, brevity penalty, bleu score] * N, where N is the number of points
bleu.bleu_points([reference], [candidate], max_ngram=4)

# edit_distance_sentence takes a list of strings
# it computes edit distance of input sentence
# output: [edit distance, normalized edit distance]
e.edit_distance_sentence(reference, candidate)

# edit_distance_corpus takes a list of lists
# it computes the average edit distance of input corpus
# output: [edit distance, normalized edit distance]
e.edit_distance_corpus([reference], [candidate])

# edit_distance_points takes a list of lists
# it computes edit distance of each sentence in corpus
# output: [edit distance, normalized edit distance] * N, where N is the number of points
e.edit_distance_points([reference], [candidate])


```

# Testing

1. `git clone` this repository
1. `cd` into the repository
1. run `python setup.py develop`. this will create local files under the root.
1. run `python cyzil_test.py`