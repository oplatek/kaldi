#!/usr/bin/env python3
"""
Create necessary scp files which specifies how the audio can be loaded.
"""
import argparse
import glob
import os
import subprocess


def sh(cmd):
    subprocess.call(cmd, shell=True)


def create_scpdir(vystdir, outdir):
    wav_scp = os.path.join(outdir, 'wav.scp')
    utt2spk = os.path.join(outdir, 'utt2spk')
    spk2utt = os.path.join(outdir, 'spk2utt')
    trans_txt = os.path.join(outdir, 'trans_txt')
    spk2gender = os.path.join(outdir, 'spk2gender')
    with open(wav_scp, 'w') as w, open(utt2spk, 'w') as u, open(spk2utt, 'w') as s, open(trans_txt, 'wt', encoding='utf-8') as t, open(spk2gender, 'w') as g:
        glob_pattern = os.path.join(vystdir, '*/*/*.wav')
        for wav_path in glob.glob(glob_pattern):
            wav_name = os.path.basename(wav_path)
            wav_path = os.path.realpath(wav_path)
            w.write('%s %s\n' % (wav_name, wav_path))
            u.write('%s %s\n' % (wav_name, wav_name))
            s.write('%s %s\n' % (wav_name, wav_name))
            with open(wav_path + '.trn', 'r', encoding='utf-8') as trn:
                t.write('%s %s\n' % (wav_name, trn.read().strip()))
            g.write('%s m\n' % wav_name)  # ignoring gender - use M - male all the times

    # sort the files
    for file_name in [wav_scp, utt2spk, spk2utt, trans_txt, spk2gender]:
        sh('sort %s -k1,1 -u -o %s' % (file_name, file_name))


if __name__ == "__main__":
    p = argparse.ArgumentParser(__doc__)
    p.add_argument('vystadial_data_voip_cs_2016', help='vystadial 2016 directory with data train, dev, test directories')
    p.add_argument('split_name', default='train', help='one of train, dev, test')
    p.add_argument('outdir', help='directory where to store the scp files')
    args = p.parse_args()
    vystdir = os.path.join(args.vystadial_data_voip_cs_2016, args.split_name)
    outdir = args.outdir
    if not os.path.exists(outdir):
        os.mkdir(outdir)
    create_scpdir(vystdir, outdir)
