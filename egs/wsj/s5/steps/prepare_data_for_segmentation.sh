#!/bin/bash

nj=4
cmd=run.pl
stage=-1
make_lang=true
make_feats=true

input=$1 # contains data
srcdir=$2 # contains model
WDIR=preparation.$$
lang=$WDIR/lang
lm=$WDIR/lm.arpa
srcdir_aligned=$WDIR/aligned
data=
corpus=$WDIR/whole_corpus
tmpcorpus=/tmp/corpus 
[ -f path.sh ] && . ./path.sh
. parse_options.sh || exit 1
. cmd.sh

mkdir -p $WDIR
[ -f $tmpcorpus ] && rm $tmpcorpus
if [ -z $data ]; then
    data=$WDIR/data
    mkdir -p $data
    find $input -name *.wav | while read f; do ff=${f##*/}; echo $ff `cat ${f%.*}.trn | steps/process_trn.sh $WDIR/tmpout` ; done | tee $corpus | sort -k1,1 -u > $data/text
    find $input -name *.wav | while read f; do ff=${f##*/}; echo $ff $f; done | sort -k1,1 -u > $data/wav.scp
    find $input -name *.wav | while read f; do ff=${f##*/}; echo $ff $ff; done | sort -k1,1 -u > $data/utt2spk
    find $input -name *.wav | while read f; do ff=${f##*/}; echo $ff $ff; done | sort -k1,1 -u > $data/spk2utt
    find $input -name *.wav | while read f; do ff=${f##*/}; printf "%s %.2f\n" $ff `soxi -D $f`; done | sort -k1,1 -u > $data/utt2dur
    sed -ri 's/^[^ ]+ (.*)$/a\1/' $corpus
    # mv $tmpcorpus $corpus
fi

if [ ! -f $lm ]; then
    steps/train_lm.sh --remove_numbers true --corpus $corpus --output $lm --vocab `pwd`/vocab-full.txt
    gzip -c $lm > $lm.gz
    lm=$lm
fi

if $make_feats; then
    echo "Create MFCC features and storing them (Could be large)."
    steps/make_mfcc.sh --mfcc-config conf/mfcc.conf --cmd \
      "run.pl" --nj $nj $data $data mfcc || exit 1;
#    # Note --fake -> NO CMVN
    steps/compute_cmvn_stats.sh $data \
      make_mfcc/train mfcc || exit 1;
fi

if $make_lang; then
    set -x
    local/prepare_cs_transcription.sh . $lang/dict
    local/create_phone_lists.sh $lang/dict
    utils/prepare_lang.sh $lang/dict '_SIL_' $lang.tmp $lang
    utils/format_lm.sh $lang $lm.gz $lang/dict/lexicon.txt $lang
fi

for f in $data/text $lang/oov.int $srcdir/tree $srcdir/final.mdl \
    $lang/L_disambig.fst $lang/phones/disambig.int; do
  [ ! -f $f ] && echo "$0: expected file $f to exist" && exit 1;
done

utils/lang/check_phones_compatible.sh $lang/phones.txt $srcdir/phones.txt || exit 1;

steps/align_fmllr.sh $data $lang $srcdir $srcdir_aligned

echo "Done preparing data."
echo "Now you can run: steps/cleanup/clean_and_segment_data.sh $data $lang $srcdir_aligned  clean_segment_dir cleaned_segment_data"
