# Description

Cyzil provides fast libraries that compute various metrics for machine translation, implemented in Cython.
So far, it covers [edit distance (Levenstein Distance)](https://en.wikipedia.org/wiki/Levenshtein_distance) and BLEU score proposed by [Papineni et al. (2002)](https://www.aclweb.org/anthology/P02-1040.pdf).

# Dependencies
* Python 3.7+

# Usage

``` python
import cyzil

reference = ['this', 'is', 'a', 'test']
candidate = ['this', 'is', 'a', 'test']

# bleu_sentence takes a list of strings
# it computes bleu score of input sentence
# output: [precision, brevity penalty, bleu score]
cyzil.bleu_sentence(reference, candidate, max_ngram=4)

# bleu_corpus takes a list of lists
# it computes the average bleu score of input corpus
# output: [precision, brevity penalty, bleu score]
cyzil.bleu_corpus([reference], [candidate], max_ngram=4)

# bleu_points takes a list of lists
# it computes bleu score of each sentence in corpus
# output: [precision, brevity penalty, bleu score] * N, where N is the number of points
cyzil.bleu_points([reference], [candidate], max_ngram=4)

# edit_distance_sentence takes a list of strings
# it computes edit distance of input sentence
# output: int
cyzil.edit_distance_sentence(reference, candidate)

# edit_distance_corpus takes a list of lists
# it computes the average edit distance of input corpus
# output: [edit distance, normalized edit distance]
cyzil.edit_distance_corpus([reference], [candidate])

# edit_distance_points takes a list of lists
# it computes edit distance of each sentence in corpus
# output: [edit distance, normalized edit distance] * N, where N is the number of points
cyzil.edit_distance_points([reference], [candidate])
```

# Testing

1. `git clone` this repository
1. `cd` into the repository
1. run `pytest`. If you don't have `pytest`, run `pip install pytest` first.