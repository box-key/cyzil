"""
Cyzil provides tools that enable quick and in-depth analysis of
sequence-sequence models such as machine translation models. It contains
a Cython module that provides fast computation of standard metrics such as
BLEU score.
"""

from bleu import bleu_sentence, bleu_corpus, bleu_points
from edit_distance import edit_distance_sentence, edit_distance_corpus, edit_distance_points

__all__ = [
    "bleu_sentence",
    "bleu_corpus",
    "bleu_points",
    "edit_distance_sentence",
    "edit_distance_corpus",
    "edit_distance_points"
]
