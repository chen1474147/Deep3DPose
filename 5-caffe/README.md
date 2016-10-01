# Domain adaptation caffe

This is a modification to caffe which allows one to train a domain adaptation network in paper [Synthesizing Training Images for Boosting Human 3D Pose Estimation](http://irc.cs.sdu.edu.cn/Deep3DPose/) (accepted to 3D Vision 2016).

## How to use

### solver

Define grl_train, grl_interval and fc_interval in solver.prototxt.

At first, we will train the network normally to get a good initial point of regressor and classifier. grl_train defines this normal iteration times. We will fix feature extractor and train a good classifier and regressor, say, a pose estimator. Then based on them, we begin to adjust feature extracotr. fc_interval is feature extractor iteration times grl_interval is classifier iteration times

Below parameters mean that we will first train 10000 times to get a good initial classifier and regressor. Then we begin to adjst feature extractor. We will adjust 1 time feature extractor, then we train 100 times classifier. We will fix one when we train another. We train it in a circular way. But the regressor is always in back propagation.

```
net: "train_val.prototxt"
test_iter: 1800
test_interval: 500
base_lr: 0.001
lr_policy: "step"
gamma: 0.1
stepsize: 150000
display: 100
max_iter: 150000
momentum: 0.9
weight_decay: 0.0005
snapshot: 10000
snapshot_prefix: "snapshots/grl_syn"
solver_mode: GPU
# add three parameters
grl_interval: 100
fc_interval: 1
grl_train: 10000
```

### trainval

In train val prototxt, you should define the property of every layer. For a normal layer with parameters, you can define it belongs to feature extractor, classifier or regressor. You need to add is_grl_layer in the layer param.
is_grl_layer 2 means that it is feature layer
is_grl_layer 1 means that it is clasifier layer
is_grl_layer 0 means that it is regressor layer

ALso, you should define loss together.
is_grl_loss 0 means that it is regressor loss
is_grl_loss 1 means that it is right classifier loss, say, the mage classifier label is [0 1] and its ground truth is [0 1]
is_grl_loss 1 means that it is confusing classifier loss, say, the image classifier label is [0 1] and its ground truth is [0.5 0.5]

see myexamples for more detials.


## Citation

Please cite the following technical report if you are using this extension in your research:

    @InProceedings{Deep3DPose,
        Title={Synthesizing Training Images for Boosting Human 3D Pose Estimation},
        Author={{Wenzheng Chen and Huan Wang and Yangyan Li and Hao Su and Zhenhua Wang and Changhe Tu and Dani Lischinski and Daniel Cohen-Or and Baoquan Chen},
        Booktitle={3D Vision (3DV)},
        Year= {2015}
    }
