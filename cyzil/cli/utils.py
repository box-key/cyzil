import csv
from cyzil import tokenizers


def _get_tokenizer(option=None):
    if (option is None) or (option == 'space'):
        return tokenizers.white_space
    elif option == 'nltk':
        return tokenizers.nltk


def load_data(path, tokenizer_option):
    with open(path, mode='rt', encoding='utf-8') as f:
        data = f.read().strip().split('\n')
    tokenizer = _get_tokenizer(tokenizer_option)
    tokenized = [tokenizer(sentence) for sentence in data]
    return tokenized


def store_output(data, path_file):
    # append csv extension if a path doesn't have one
    if path_file.find('.csv') == -1:
        path_file += '.csv'
    with open(path_file, mode='w', encoding="utf-8", newline='\n') as f:
        writer = csv.writer(f, delimiter=',')
        for row in data:
            writer.writerow(row)
