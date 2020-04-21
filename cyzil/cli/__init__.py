"""
A module for cyzil cli tool.
"""
from .bleu_cli import bleu_corpus, bleu_points
from .edit_distance_cli import edit_distance_corpus, edit_distance_points


__all__ = [
    "bleu_corpus",
    "bleu_points",
    "edit_distance_corpus",
    "edit_distance_points"
]
