import argparse
import sys

from .utils import load_data, store_output

import cyzil


def _parse_argument(docs):
    parser = argparse.ArgumentParser(description=docs)
    parser.add_argument(
        "--reference",
        required=True,
        help="path to a reference file, where each serntence is in a separate line"
    )
    parser.add_argument(
        "--candidate",
        required=True,
        help="path to a candiate file, where each serntence is in a separate line"
    )
    parser.add_argument(
        "--tokenizer",
        default='space',
        choices=['space', 'nltk'],
        help="a way to tokenize sentences (white space by default)"
    )
    parser.add_argument(
        "-o",
        "--output",
        help="a file path to store output in csv format"
    )
    return parser.parse_args()


def edit_distance_corpus():
    parser = _parse_argument("compute corpus-level Edit Disntance")
    reference = load_data(parser.reference, parser.tokenizer)
    candidate = load_data(parser.candidate, parser.tokenizer)
    scores = cyzil.edit_distance_corpus(reference, candidate)
    print(scores)


def edit_distance_points():
    parser = _parse_argument("compute Edit Distance for each translation pair in corpus")
    reference = load_data(parser.reference, parser.tokenizer)
    candidate = load_data(parser.candidate, parser.tokenizer)
    scores = cyzil.edit_distance_points(reference, candidate)
    if parser.output is not None:
        store_output(scores, parser.output)
    else:
        print(scores)
