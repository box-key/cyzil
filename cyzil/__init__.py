"""
Cyzil provides tools that enable quick and in-depth analysis of
sequence-sequence models, especially machine translation models. It contains
the following utilities:

* a Cython module that provides fast computation of standard metrics such as
bleu.
"""

from bleu import bleu_sentence, bleu_corpus, bleu_sentence
from edit_distance import edit_distance_sentence, edit_distance_corpus, edit_distance_points

__all__ = [
    "bleu_sentence",
    "bleu_corpus",
    "bleu_sentence",
    "edit_distance_sentence",
    "edit_distance_corpus",
    "edit_distance_points"
]
