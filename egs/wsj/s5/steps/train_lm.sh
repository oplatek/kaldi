#!/bin/bash
corpus=
output=

if [ $# -lt 2 ]; then
    echo "Usage: $0 --corpus corpus --output output_lm [--expand_numbers] [--remove_numbers] [--remove_punctuation]"
    exit 1
fi

tmpdir=tmp.$$
expand_numbers=false
remove_numbers=false
remove_punctuation=false

vocab=vocab.txt
compulsary_vocabulary_num_words=50000
limit_vocabulary_num_words=50000   # should be bigger than $compulsary_vocabulary_num_words

. parse_options.sh
general_corpus_tmp=$tmpdir/$general_corpus
corpus_tmp=$tmpdir/$(basename $corpus)

mkdir -p $tmpdir

cp $corpus $corpus_tmp

if $expand_numbers; then
    echo TODO: expand numbers
fi

if $remove_numbers; then
    awk '!/[0-9]/{print $0}' $corpus_tmp > $tmpdir/corpus.tmp
    mv $tmpdir/corpus.tmp $corpus_tmp
fi

if $remove_punctuation; then
    sed -ir 's/\.|,|!|\?|-//g' $corpus_tmp
fi
cat $corpus_tmp \
    | tr ' ' '\n' | tr '\t' '\n' | sort | uniq -c | sort -r -n -k 1  | cut -c 9- \
    > $vocab


estimate-ngram -text $corpus_tmp \
 -order 3 \
 -wl $output

 rm -rf $tmpdir
