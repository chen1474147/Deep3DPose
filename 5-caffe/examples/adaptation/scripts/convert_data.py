#!/usr/bin/python

# Copyright (c) 2015, Yaroslav Ganin (yaroslav.ganin@gmail.com)
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without modification,
# are permitted provided that the following conditions are met:
#
# - Redistributions of source code must retain the above copyright notice,
#   this list of conditions and the following disclaimer.
# 
# - Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
# EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

from __future__ import print_function

import os
import glob
import argparse
import shutil
import lmdb

import numpy as np
import numpy.random as nr
import scipy.misc
import cv2

print_spaces = 100

# Make sure that caffe is on the python path:
caffe_root = '/home/yganin/Arbeit/Projects/NN/skaffe'  # this file is expected to be in {caffe_root}/examples
import sys
sys.path.insert(0, os.path.join(caffe_root, 'python'))

from caffe.proto.caffe_pb2 import Datum

def read_data(source_path):
    images = [] # images
    labels = [] # corresponding labels

    r = [x for x in os.listdir(source_path) 
         if os.path.isdir(os.path.join(source_path, x))]
    r.sort()

    for c, subdir in enumerate(r):
        class_root = os.path.join(source_path, subdir)

        files = glob.iglob(os.path.join(class_root, '*.jpg'))

        for f in files:
            # CAUTION: The following call reads an image in BGR order.
            img = cv2.imread(f)
            img = cv2.resize(img, (256, 256))
            img = img.transpose((2, 0, 1))

            images.append(img)
            labels.append(c)

        # Print status.
        sys.stdout.write("\r%s\r    Processed %d of %d classes" % 
                         (print_spaces * ' ', c + 1, len(r)))
        sys.stdout.flush()
    print()

    labels = np.array(labels, dtype=np.int32)

    return images, labels

def convert_dataset(source_path, target_path, domain, examples, iters):
    print('[*] Reading Office (%s) dataset...' % domain)
    images, labels = read_data(os.path.join(source_path, domain, 'images'))

    print('    Total samples: %d' % labels.size)

    suffixes = ['train', 'test']

    num_classes = labels.max() + 1

    rnd = nr.RandomState(1349)

    for t in xrange(iters):
        if examples > 0:
            all_train_indices = []
            all_test_indices = []

            for c in xrange(num_classes):
                indices = np.where(labels == c)[0]

                to_pick = min(examples, indices.size)

                train_indices = rnd.choice(indices, size=to_pick, replace=False)        
                test_indices = np.setdiff1d(indices, train_indices)

                all_train_indices.append(train_indices)
                all_test_indices.append(test_indices)

            all_train_indices = np.concatenate(all_train_indices, axis=0)
            all_test_indices = np.concatenate(all_test_indices, axis=0)

            splits = [
                all_train_indices,
                all_test_indices
            ]
        else:
            splits = [np.arange(labels.size)]

        print('[*] Writing splits (iteration %d)...' % (t + 1))
        for i, indices in enumerate(splits):
            print('    Split %s: %d samples' % (suffixes[i], indices.size))

            if examples > 0:
                name = domain + '_' + suffixes[i] + '_' + str(examples) + '_' + str(t)
            else:
                name = domain + '_' + suffixes[i] + '_' + str(t)

            write_dataset(images, labels, indices, 
                          name, 
                          target_path)

def write_dataset(images, labels, indices, suffix, target_path):
    db_path = os.path.join(target_path, '{0}_lmdb'.format(suffix))

    try:
        shutil.rmtree(db_path)
    except:
        pass
    os.makedirs(db_path, mode=0744)

    num_images = indices.size

    datum = Datum();
    datum.channels = 3
    datum.height = images[0].shape[1]
    datum.width = images[0].shape[2]

    mdb_env = lmdb.Environment(db_path, map_size=1099511627776, mode=0664)
    mdb_txn = mdb_env.begin(write=True)
    mdb_dbi = mdb_env.open_db(txn=mdb_txn)

    for i, img_idx in enumerate(indices):
        img = images[img_idx]

        datum.data = img.tostring()
        datum.label = np.int(labels.ravel()[img_idx])

        value = datum.SerializeToString()
        key = '{:08d}'.format(i)

        mdb_txn.put(key, value, db=mdb_dbi)

        if i % 1000 == 0:
            mdb_txn.commit()
            mdb_txn = mdb_env.begin(write=True)

    if num_images % 1000 != 0:
        mdb_txn.commit()
    
    mdb_env.close()

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Converts Office data into lmdb/caffe format')
    parser.add_argument('-s', '--source-path', dest='source_path', required=True)
    parser.add_argument('-t', '--target-path', dest='target_path', required=True)
    parser.add_argument('-d', '--domain', choices=['amazon', 'webcam', 'dslr'])
    parser.add_argument('-x', '--training-examples', dest='examples', type=int, default=-1)
    parser.add_argument('-i', '--iterations', type=int, default=5)

    args = parser.parse_args()

    convert_dataset(args.source_path, args.target_path, args.domain, args.examples, args.iterations)
