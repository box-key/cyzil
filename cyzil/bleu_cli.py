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
        "--ngram",
        default=4,
        help="the maximum order of ngram to compute the score"
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


def bleu_corpus():
    parser = _parse_argument("compute corpus-level BLEU score")
    reference = load_data(parser.reference, parser.tokenizer)
    candidate = load_data(parser.candidate, parser.tokenizer)
    scores = cyzil.bleu_corpus(reference, candidate, parser.ngram)
    print(scores)


def bleu_points():
    parser = _parse_argument("compute BLEU score for each translation pair in corpus")
    reference = load_data(parser.reference, parser.tokenizer)
    candidate = load_data(parser.candidate, parser.tokenizer)
    scores = cyzil.bleu_points(reference, candidate, parser.ngram)
    if parser.output is not None:
        store_output(scores, parser.output)
    else:
        print(scores)
