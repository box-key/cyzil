import pytest
import os


# compile pyx files for testing
string = "python setup.py build_ext --inplace"
os.system(string)


# package to test
import cyzil


# Test strings
r1 = "I have a pen but do not have an apple".split()
c1 = "I have a pen but do not have an apple".split()
r2 = "I have a pen but do not have an apple".split()
c2 = "I have a pen but not have apples".split()
ref = [r1, r2]
cand = [c1, c2]


class TestBLEU:


    def test_bleu_sentence(self):
        """ Test return type and value of bleu_sentence """
        b = cyzil.bleu_sentence(r1, c1, 4)
        # bleu_sentence returns a list of 3 elements:
        # [precision, brevity penalty, bleu score]
        assert len(b) == 3 and isinstance(b, list)
        # for an identical translation, bleu score is 1
        assert all(x == 1 for x in b)


    def test_bleu_corpus(self):
        """ Test return type and value of bleu_corpus """
        b = cyzil.bleu_corpus(ref, cand, 4)
        # bleu_corpus returns a list of 3 elements:
        # [precision, brevity penalty, bleu score]
        assert len(b) == 3 and isinstance(b, list)
        # bleu score ranges from 0 to 1
        assert (0 <= b[2]) and (b[2] <= 1)


    def test_bleu_points(self):
        """ Test return type and value of bleu_points """
        b = cyzil.bleu_points(ref, cand, 4)
        # bleu_points returns bleu score for each sentence as 2d numpy array:
        # number of pairs by 3
        assert len(b) == len(ref) and isinstance(b, list)
        # each sentence has 3 elements
        assert all(len(x) == 3 for x in b)


class TestEditDistance:


    def test_edit_distance_sentence(self):
        """ Test return type and value of edit_distance_sentence """
        edit = cyzil.edit_distance_sentence(r1, c1)
        # edit_distance_sentence returns an integer
        assert isinstance(edit, int)
        # for identical translation,edit distance is 0
        assert edit == 0


    def test_edit_distance_corpus(self):
        """ Test return type and value of edit_distance_corpus """
        edit = cyzil.edit_distance_corpus(ref, cand)
        # edit_distance_corpus returns a list of 2 elements:
        # [edit distance, normalizer edit distance]
        assert len(edit) == 2 and isinstance(edit, list)


    def test_edit_distance_points(self):
        """ Test return type and value of edit_distance_points """
        edit = cyzil.edit_distance_points(ref, cand)
        # edit_distance_points returns edit distance for each sentence
        # as 2d np array: number of pairs by 2
        assert len(edit) == len(ref) and isinstance(edit, list)
        # edit_distance is greater than or equal to 0
        assert all((0 <= x[0]) for r, c, x in zip(ref, cand, edit))
        # maximum edit distance is the length of reference or candidate
        max_len = [max(len(r), len(c)) for r, c in zip(ref, cand)]
        assert all((x[0] < len) for x, len in zip(edit, max_len))
