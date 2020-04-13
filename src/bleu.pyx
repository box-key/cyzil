from libcpp.vector cimport vector
from libcpp.string cimport string
from libcpp.unordered_map cimport unordered_map
from libc.math cimport exp
from libc.math cimport log


ctypedef float DTYPE
# Delimitor to store a ngram token
# Used to count ngram order
cdef string DELIM = ' '


cpdef vector[string] _list2vec(list data):
    cdef vector[string] _data = [token.encode("utf-8") for token in data]
    return _data


cpdef unordered_map[string, int] _get_overlap(unordered_map[string, int] &m1,
                                              unordered_map[string, int] &m2):
    cdef unordered_map[string, int] overlap
    cdef int c2
    # store elements appear both in m1 and m2
    for t1, c1 in m1:
        # if a token exists in both m1 and m2, store the smallest count
        if m2.count(t1):
            c2 = m2[t1]
            overlap[t1] = min(c1, c2)
    return overlap


cpdef unordered_map[string, int] _count_ngram(const vector[string] &sentence,
                                              int max_order):
    cdef int size = sentence.size()
    cdef unordered_map[string, int] ngram_counts
    cdef string ngram
    # Iterate through all orders of ngram
    for order in range(1, max_order + 1):
        # count each order of ngram tokens
        for i in range(0, size - order + 1):
            ngram = ''
            for token in sentence[i : i+order]:
                ngram = ngram + token + DELIM
            if ngram_counts.count(ngram):
                ngram_counts[ngram] += 1
            else:
                ngram_counts[ngram] = 1
    return ngram_counts


cpdef vector[DTYPE] bleu_sentence(list reference,
                                  list candidate,
                                  int max_ngram):
    """Computes sentence-level BLEU score.

    Parameters
    ----------
    reference, candiate : list
        A tokenized sentence stored as a list of strings. Reference is assumed
        to be a correct sequence, and candidateis is assumed to be a sequence
        generated by some model.
    max_ngram : int
        The maximum order of ngram to compute the score.

    Returns
    -------
    list
        A list of 3 decimal values: the first value is the precision, the
        second value is brevity penalty, and the last value is bleu score,
        which is the product of precision and brevity penalty.

    Example
    --------
    >>> from cyzil import bleu_sentence
    >>> bleu_sentence(['this', 'is', 'a', 'test', 'sentence'],
                      ['this', 'is', 'a', 'test', 'sentence'])
    [1.0, 1.0, 1.0]

    """
    if (len(reference) == 0) or (len(candidate) == 0):
        return [0, 0, 0]
    assert isinstance(reference[0], str), \
        "reference should be a list of strings"
    assert isinstance(candidate[0], str), \
        "candidate should be a list of strings"
    return bleu_corpus([reference], [candidate], max_ngram)


cpdef vector[DTYPE] bleu_corpus(list reference_corpus,
                                list candidate_corpus,
                                int max_ngram):
    """Computes corpus-level BLEU score.

    Parameters
    ----------
    reference_corpus, candidate_corpus : list
        A corpus contains a list of strings as individual sentences. Reference
        is assumed to be correct sequences, and candidateis is assumed to be
        sequences generated by some model. It assumes that a pair of reference
        and candidate is stored at the same index.
    max_ngram : int
        The maximum order of ngram to compute the score.

    Returns
    -------
    corpus_score : list
        A list of 3 decimal values: the first value is the precision, the
        second value is brevity penalty, and the last value is bleu score,
        which is the product of precision and brevity penalty.

    Example
    --------
    >>> from cyzil import bleu_corpus
    >>>  reference_corpus = [['this', 'is', 'a', 'test', 'sentence'],
                             ['I', 'see', 'an', 'apple', 'and', 'a', 'cat']]
         candidate_corpus = [['this', 'is', 'a', 'test', 'sentence'],
                             ['I', 'see', 'an', 'apple', 'and', 'a', 'dog']]
    >>> bleu_corpus(reference_corpus, candidate_corpus, 4)
    [0.8806841373443604, 1.0, 0.8806841373443604]

    """
    assert len(reference_corpus)==len(candidate_corpus), \
          'reference corpus and candiate corpus should have the same length'
    assert isinstance(reference_corpus[0], list), \
          'reference corpus should be a list of lists'
    assert isinstance(candidate_corpus[0], list), \
          'candidate corpus should be a list of lists'
    cdef vector[DTYPE] clipped_count = [0.0]*max_ngram
    cdef vector[DTYPE] clip_norm = [0.0]*max_ngram
    cdef vector[string] _reference
    cdef vector[string] _candidate
    cdef unordered_map[string, int] reference_count
    cdef unordered_map[string, int] candidate_count
    cdef unordered_map[string, int] overlap
    cdef long ref_len = 0
    cdef long cand_len = 0
    # Iterate through corpus
    for reference, candidate in zip(reference_corpus, candidate_corpus):
        _reference = _list2vec(reference)
        _candidate = _list2vec(candidate)
        ref_len += _reference.size()
        cand_len += _candidate.size()
        # count ngrams in reference and candidate
        reference_count = _count_ngram(_reference, max_ngram)
        candidate_count = _count_ngram(_candidate, max_ngram)
        # store overlaps
        overlap = _get_overlap(reference_count, candidate_count)
        # count the occurence of ngram tokens
        for ngram_token, count in overlap:
            # -2 as offset, e.g. 'I am '.split() = ['I', 'am', '']
            clipped_count[len(ngram_token.split(DELIM)) - 2] += count
        for order in range(max_ngram):
            clip_norm[order] += max(_candidate.size() - order, 0)
    cdef vector[DTYPE] norm_counts
    cdef DTYPE precision = 0.0
    cdef DTYPE log_sum = 0.0
    # avoid division by 0
    if min(clipped_count):
        # normalize each count
        norm_counts = [<DTYPE> c/n for c, n in zip(clipped_count, clip_norm)]
        for count in norm_counts:
            log_sum += <DTYPE> log(count)/max_ngram
        precision = exp(log_sum)
    cdef float bp = exp(min(1.-(<DTYPE> ref_len/cand_len), 0))
    # corpus_score[0]: precision, corpus_score[1]: bp, corpus_score[2]: bleu
    cdef vector[DTYPE] corpus_score = [precision, bp, precision*bp]
    corpus_score.reserve(3)
    return corpus_score


cpdef vector[vector[DTYPE]] bleu_points(list reference_corpus,
                                        list candidate_corpus,
                                        int max_ngram):
    """Computes BLEU score for each reference-candiate pair in corpus.

    Parameters
    ----------
    reference_corpus, candidate_corpus : list
        A corpus contains a list of strings as individual sentences. Reference
        is assumed to be correct sequences, and candidateis is assumed to be
        sequences generated by some model. It assumes that a pair of reference
        and candidate is stored at the same index.
    max_ngram : int
        The maximum order of ngram to compute the score.

    Returns
    -------
    points : list of bleu score [number of pairs in corpus, 3]
        A 2-dimensional list that contains precision, brevity penalty, and
        bleu score for each reference-candidate pair, where each row corresponds
        to each pair.

    Example
    --------
    >>> from cyzil import bleu_points
    >>>  reference_corpus = [['this', 'is', 'a', 'test', 'sentence'],
                             ['I', 'see', 'an', 'apple', 'and', 'a', 'cat']]
         candidate_corpus = [['this', 'is', 'a', 'test', 'sentence'],
                             ['I', 'see', 'an', 'apple', 'and', 'a', 'dog']]
    >>> bleu_points(reference_corpus, candidate_corpus, 4)
    [[1.0, 1.0, 1.0], [0.809106707572937, 1.0, 0.809106707572937]]

    """
    assert len(reference_corpus)==len(candidate_corpus), \
          'reference corpus and candiate corpus should have the same length'
    assert isinstance(reference_corpus[0], list), \
          'reference corpus should be a list of lists'
    assert isinstance(candidate_corpus[0], list), \
          'candidate corpus should be a list of lists'
    # points[:, 0]: precision, points[:, 1]: bp, points[:, 2]: bleu score
    cdef vector[vector[DTYPE]] points
    points.reserve(len(reference_corpus))
    cdef vector[DTYPE] sentence_score
    sentence_score.reserve(3)
    # Iterate through corpus
    for reference, candidate in zip(reference_corpus, candidate_corpus):
        sentence_score = bleu_sentence(reference, candidate, max_ngram)
        points.push_back(sentence_score)
    return points
