#!/bin/bash

locdata=$1; shift
locdict=$1; shift


mkdir -p $locdict 

# change last argument to true so the text which covers czech phonemes are printed out
echo $locdict
perl local/phonetic_transcription_cs.pl $locdata/vocab-full.txt $locdict/cs_transcription.txt true | cut -f1 -d ' ' >> $locdata/vocab-full.txt
sort -k1,1 -u $locdata/vocab-full.txt -o $locdata/vocab-full.txt

# generate word word-transcription per line output
perl local/phonetic_transcription_cs.pl $locdata/vocab-full.txt $locdict/cs_transcription.txt false
sort -k1,1 -u $locdict/cs_transcription.txt -o $locdict/cs_transcription.txt

echo "--- Searching for OOV words ..."
gawk 'NR==FNR{words[$1]; next;} !($1 in words)' \
  $locdict/cs_transcription.txt $locdata/vocab-full.txt |\
  egrep -v '<.?s>' | tr -d "'" > $locdict/vocab-oov.txt

gawk 'NR==FNR{words[$1]; next;} ($1 in words)' \
  $locdata/vocab-full.txt $locdict/cs_transcription.txt |\
  egrep -v '<.?s>' | tr -d "'" > $locdict/lexicon.txt

sort -k1,1 -u $locdict/vocab-oov.txt -o $locdict/vocab-oov.txt
sort -k1,1 -u $locdict/lexicon.txt -o $locdict/lexicon.txt

wc -l $locdict/vocab-oov.txt
wc -l $locdict/lexicon.txt
