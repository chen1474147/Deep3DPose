#!/bin/python

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

import shutil
import os
import sys
import argparse

from string import Template

DEFAULT_PARAMS = {
    'amazon_to_webcam': {
        'model': {
            'from': 'amazon',
            'to': 'webcam',
            'grl_upper_bound': 1.0,
            'grl_alpha': 10.0,
            'grl_max_iter': 10000
        },
        'solver': {
            'max_iter': 50000,
            'test_iter': 795,
        }
    },
    'dslr_to_webcam': {
        'model': {
            'from': 'dslr',
            'to': 'webcam',
            'grl_upper_bound': 1.0,
            'grl_alpha': 10.0,
            'grl_max_iter': 10000
        },
        'solver': {
            'max_iter': 50000,
            'test_iter': 795,
        }
    },
    'webcam_to_dslr': {
        'model': {
            'from': 'webcam',
            'to': 'dslr',
            'grl_upper_bound': 1.0,
            'grl_alpha': 10.0,
            'grl_max_iter': 10000
        },
        'solver': {
            'max_iter': 50000,
            'test_iter': 498,
        }
    }
}

TRAIN_TEMPLATE = """\
#!/usr/bin/env sh

TOOLS=./build/tools

$$TOOLS/caffe train \\
    --solver=${solver_path} \\
    --weights=${weights_path} \\
    --gpu 0
"""

def clear_dir(path):
    try:
        shutil.rmtree(path)
    except:
        pass

    os.makedirs(path)

def prepare_dirs(params):
    target_path = os.path.abspath(params['target_path'])

    model_id = params['mode']
    exper_path = os.path.join(target_path, model_id)

    protos_path = os.path.join(exper_path, 'protos')
    solver_path = os.path.join(protos_path, 'solver.prototxt')
    model_path = os.path.join(protos_path, 'train_val.prototxt')
    snapshots_path = os.path.join(exper_path, 'snapshots')
    scripts_path = os.path.join(exper_path, 'scripts')

    datasets_path = os.path.abspath(params['datasets_path'])
    alexnet_model_path = os.path.abspath(params['alexnet_model_path'])
    imagenet_mean_path = os.path.abspath(params['imagenet_mean_path'])

    protos_templates_path = os.path.abspath(params['protos_path'])
    solver_template_path = os.path.join(protos_templates_path, 'solver.prototxt')
    model_templates_path = os.path.join(protos_templates_path, 'train_val.prototxt')

    # Create model.
    print('[*] Setting up %s...' % model_id)

    for d in [protos_path, snapshots_path, scripts_path]:
        clear_dir(d)

    model_template = file(model_templates_path, 'r').read()
    solver_template = file(solver_template_path, 'r').read()
    model_template = Template(model_template)
    solver_template = Template(solver_template)

    template_subs = DEFAULT_PARAMS[model_id]

    template_subs['solver'].update({
        'net': model_path,
        'snapshots_path': snapshots_path
    })

    template_subs['model'].update({
        'datasets_path': datasets_path,
        'imagenet_mean_path': imagenet_mean_path
    })
    
    file(model_path, 'w').write(model_template.substitute(template_subs['model']))
    file(solver_path, 'w').write(solver_template.substitute(template_subs['solver']))

    train_script = Template(TRAIN_TEMPLATE).substitute({
        'solver_path': solver_path,
        'weights_path': alexnet_model_path})

    file(os.path.join(scripts_path, 'train.sh'), 'w').write(train_script)
    os.chmod(os.path.join(scripts_path, 'train.sh'), 0744)

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=
        'Prepares all files necessary to train a model')
    parser.add_argument('-m', '--mode', choices=['amazon_to_webcam', 'dslr_to_webcam', 'webcam_to_dslr'], required=True)
    parser.add_argument('-t', '--target-path', required=True)
    parser.add_argument('-d', '--datasets-path', required=True)
    parser.add_argument('-a', '--alexnet-model-path', required=True)
    parser.add_argument('-i', '--imagenet-mean-path', required=True)
    parser.add_argument('-p', '--protos-path', required=True)

    args = parser.parse_args()

    params = vars(args)
    params = { k : params[k] for k in params if params[k] != None }

    prepare_dirs(params)
