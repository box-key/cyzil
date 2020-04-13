# Description

Cyzil provides tools that enable quick and in-depth analysis of sequence-sequence models, especially machine translation models. It contains a Cython module that provides fast computation of standard metrics. It covers [edit distance (Levenstein Distance)](https://en.wikipedia.org/wiki/Levenshtein_distance) and BLEU score proposed by [Papineni et al. (2002)](https://www.aclweb.org/anthology/P02-1040.pdf) so far.

# Requirements
* Python 3.7+

# Usage

``` python
import cyzil

reference = ['this', 'is', 'a', 'test']
candidate = ['this', 'is', 'a', 'test']

cyzil.bleu_sentence(reference, candidate, max_ngram=4)

cyzil.bleu_corpus([reference], [candidate], max_ngram=4)

cyzil.bleu_points([reference], [candidate], max_ngram=4)

cyzil.edit_distance_sentence(reference, candidate)

cyzil.edit_distance_corpus([reference], [candidate])

cyzil.edit_distance_points([reference], [candidate])
```

For more details, please refer to [User Guide](https://box-key.github.io/cyzil/)

# Testing

1. `git clone` this repository
1. `cd` into the repository
1. run `pytest`. If you don't have `pytest`, run `pip install pytest` first.