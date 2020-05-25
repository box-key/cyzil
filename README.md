cyzil
=====
[![PyPI version](https://badge.fury.io/py/cyzil.svg)](https://pypi.org/project/cyzil/)
[![Supported Python version](https://img.shields.io/badge/python-3.7-brightgreen)](https://pypi.org/project/cyzil/)
[![Coding style](https://img.shields.io/badge/style-black-lightgrey)](https://github.com/psf/black)

Description
-----------

Cyzil provides tools that enable quick and in-depth analysis of sequence generation models such as machine translation models. It contains a Cython module that provides fast computation of standard metrics. It covers [edit distance (Levenstein Distance)](https://en.wikipedia.org/wiki/Levenshtein_distance) and BLEU score proposed by [Papineni et al. (2002)](https://www.aclweb.org/anthology/P02-1040.pdf) so far.

- [Command-line tool](#command-line-tool)
- [Python API](#python-api)
- [User guide](https://box-key.github.io/cyzil/)

Requirements
------------

* Python 3.7+

Installation
------------
Cyzil requires Python 3.7+. Please install it by running the following code:

```bash
pip install cyzil
```

Command-line tool
-----------------

### User Guide

With cyzil, you can compute BLEU score and Edit distance on your terminal. All you have to do is
to specify the path to a reference file (correct translations) and a candidate file
(translation generated by a machine translation model).
The reference and candidate sentences should be stored in separate lines, e.g.
sentence 1\n sentence 2\n ... sentence k\n.
Please see examples [here](https://github.com/box-key/cyzil/tree/master/data).
For computing score, you can tokenize sentences by white space or [nltk tokenizer](https://www.nltk.org/).
By default, it tokenizes sentences
by white space.

### Usage

The following code shows an example for corpus-leve BLEU score. It prints out the precision, the brevity penalty and BLEU score.

``` bash
> cyzil-bleu-corpus \
    --reference data/ref.en \
    --candidate data/can.en \
    --ngram 4 \
    --tokenizer nltk
[0.9041149616241455, 1.0, 0.9041149616241455]
```

The below is an example for corpus-level edit distance.

``` bash
> cyzil-edit-distance-corpus \
    --reference data/ref.en \
    --candidate data/can.en \
    --tokenizer nltk
[0.5, 0.04545454680919647]
```

### Computing Score for Each Pair

Cyzil also computes the metric of each reference-candidate pair to for in-depth analysis of sequence generation models. The output can be stored in a csv file. Each row of output corresponds to each reference-candidate pair.


Here is an example for BLEU score. The first column of the output is the precision, the second is the brevity penalty and the last column is the BLEU score.

``` bash
> cyzil-bleu-points \
    --reference data/ref.en \
    --candidate data/can.en \
    --ngram 4 \
    --tokenizer nltk \
    --output output.csv
```

Edit distance can be computed as follows. The first column of the output is edit distance and the second column is normalized edit distance.

``` bash
> cyzil-edit-distance-points \
    --reference data/ref.en \
    --candidate data/can.en \
    --tokenizer nltk \
    --output output.csv
```

For more details, please refer to help of each command, e.g. `cyzil-bleu-corpus -h`.

Python API
----------

Cyzil can be imported as a python module into your program.
The following shows example of API calls.
For more details, please refer to [User Guide](https://box-key.github.io/cyzil/).

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

License
-------
This project is licensed under Apache 2.0.
