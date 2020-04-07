import pytest

# compile pyx files for testing
import os
string = "python setup.py build_ext --inplace"
os.system(string)

import numpy as np

# cython modules to be tested
import bleu
import edit_distance as e


r1 = 'I have a pen but do not have an apple'.split()
c1 = 'I have a pen but do not have an apple'.split()
r2 = 'I have a pen but do not have an apple'.split()
c2 = 'I have a pen but not have apples'.split()
ref = [r1, r2]
cand = [c1, c2]

class TestBLEU:

    def test_bleu_sentence(self):
        """ Test return type and value of bleu_sentence """
        b = bleu.bleu_sentence(r1, c1, 4)

        assert len(b)==3 and isinstance(b, list) # bleu_sentence returns a list of 3 elements: [precision, brevity penalty, bleu score]
        assert all(x==1 for x in b) # for an identical translation, bleu score is 1

    def test_bleu_corpus(self):
        """ Test return type and value of bleu_corpus """
        b = bleu.bleu_corpus(ref, cand, 4)

        assert len(b)==3 and isinstance(b, list) # bleu_corpus returns a list of 3 elements: [precision, brevity penalty, bleu score]
        assert (0<=b[2]) and (b[2]<=1)# bleu score ranges from 0 to 1

    def test_bleu_points(self):
        """ Test return type and value of bleu_points """
        b = bleu.bleu_points(ref, cand, 4)

        assert len(b)==len(ref) and isinstance(b, np.ndarray) # bleu_points returns bleu score for each sentence as 2d numpy array: # of pairs by 3
        assert all(len(x)==3 for x in b) # each sentence has 3 elements

class TestEditDistance:

    def test_edit_distance_sentence(self):
        """ Test return type and value of edit_distance_sentence """
        edit = e.edit_distance_sentence(r1, c1)

        assert isinstance(edit, int) # edit_distance_sentence returns an integer
        assert edit==0 # for identical translation,edit distance is 0

    def test_edit_distance_corpus(self):
        """ Test return type and value of edit_distance_corpus """
        edit = e.edit_distance_corpus(ref, cand)

        assert len(edit)==2 and isinstance(edit, list) # edit_distance_corpus returns a list of 2 elements: [edit distance, normalizer edit distance]

    def test_edit_distance_points(self):
        """ Test return type and value of edit_distance_points """
        edit = e.edit_distance_points(ref, cand)

        assert len(edit)==len(ref) and isinstance(edit, np.ndarray)  # edit_distance_points returns edit distance for each sentence as 2d numpy array: # of pairs by 2
        assert all((0<=x[0]) and (x[0]<=max(len(r), len(c))) \
                        for r,c,x in zip(ref,cand,edit)) # maximum edit distance is the length of reference or candidate
