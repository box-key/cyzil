import re


def white_space(data):
    return data.split()


def nltk(data):
    try:
        from nltk.tokenize import word_tokenize
        return word_tokenize(data)
    except ImportError:
        raise ImportError('nltk is missing, please run `pip install nltk`')
