#!/bin/bash

locdata=$1; shift
locdict=$1; shift


mkdir -p $locdict 



# change last argument to true so the text which covers czech phonemes are printed out
perl local/phonetic_transcription_cs.pl $locdata/vocab-full.txt $locdict/cs_transcription.txt true | cut -f1 -d ' ' >> $locdata/vocab-full.txt
sort -u $locdata/vocab-full.txt -o $locdata/vocab-full.txt

# generate word word-transcription per line output
perl local/phonetic_transcription_cs.pl $locdata/vocab-full.txt $locdict/cs_transcription.txt false

echo "--- Searching for OOV words ..."
gawk 'NR==FNR{words[$1]; next;} !($1 in words)' \
  $locdict/cs_transcription.txt $locdata/vocab-full.txt |\
  egrep -v '<.?s>' > $locdict/vocab-oov.txt

gawk 'NR==FNR{words[$1]; next;} ($1 in words)' \
  $locdata/vocab-full.txt $locdict/cs_transcription.txt |\
  egrep -v '<.?s>' > $locdict/lexicon.txt

wc -l $locdict/vocab-oov.txt
wc -l $locdict/lexicon.txt
