# Deep 3D Pose

## Synthesizing Training Images for Boosting Human 3D Pose Estimation

Created by <a href="http://irc.cs.sdu.edu.cn/~wenzheng/">Wenzheng Chen</a>, Huan Wang,
<a href="http://web.stanford.edu/~yangyan">Yangyan Li</a>,
<a href="http://ai.stanford.edu/~haosu">Hao Su</a>,
<a href="http://zhwang.me/">Zhenhua Wang</a>,
<a href="http://www.cs.sdu.edu.cn/zh/~chtu">Changhe Tu</a>,
<a href="http://www.cs.huji.ac.il/~danix/">Dani Lischinski</a>,
<a href="http://www.math.tau.ac.il/~dcor/">Daniel Cohen-Or</a>,
<a href="http://www.cs.sdu.edu.cn/~baoquan/">Baoquan Chen</a>.


### Introduction

Our work was initially described in an [arXiv tech report](https://arxiv.org/abs/1604.02703) and will appear as a 3D Vision 2016 paper. Deep3DPose is a scalable human image synthesis pipeline for generating millions of human images with their corresponding 2D and 3D pose annotations. These training images can be used for high-capacity models such as deep CNNs.


### License

Deep 3D Pose is released under the MIT License (refer to the LICENSE file for details).


### Citing Deep3DPose

    @InProceedings{Deep3DPose,
        Title={Synthesizing Training Images for Boosting Human 3D Pose Estimation},
        Author={{Wenzheng Chen and Huan Wang and Yangyan Li and Hao Su and Zhenhua Wang and Changhe Tu and Dani Lischinski and Daniel Cohen-Or and Baoquan Chen},
        Booktitle={3D Vision (3DV)},
        Year= {2015}
    }


### Contents

0. [Prerequisites](#prerequisites)
1. [Human poses](#human-poses)
2. [Human models](#human-models)
3. [Human clothes]()
4. [Render](#render)


### Prerequisites

0. Blender (tested with Blender 2.76 on 64-bit Windows). You can get it from <a href="http://www.blender.org/" target="_blank">Blender website</a> for free.

1. MATLAB (tested with 2015a on 64-bit Windows). You need to install a C++ compiler to make sure mex is available in your Matlab.


### Human Poses

To generate human models, you should define their poses first. We use [CMU Mocap Database](http://mocap.cs.cmu.edu/) as pose sources. This database contains about 4 million poses. To better cover the pose space, we also learn [a Bayesian network](http://npp.is.tue.mpg.de/iccv2013/) from these poses.

To generate poses, You can enter 1-skel directory and run demo_generateskel.m directory. It will generate cmu_skeletons.mat, which contains part of poses from [CMU Mocap Database](http://mocap.cs.cmu.edu/).

To acquire more poses, you can download the [asf & amc format zipfile](http://mocap.cs.cmu.edu/allasfamc.zip) from [CMU Mocap Database](http://mocap.cs.cmu.edu/) and unzip them in data/asfamc directory.

Note that the code doesn't include the [Bayesian network](http://npp.is.tue.mpg.de/iccv2013/) code. You can download it from the [original website](http://npp.is.tue.mpg.de/iccv2013/) and use the generated poses as input to learn the model.

We adjust pose format from CMU format to our own format. See images in sources directory. Then we use poses to generate human models.


### Human models

To generate human models, we adopt [SCAPE](http://robotics.stanford.edu/~drago/Projects/scape/scape.html). This model decomposes a human mesh into a set of pose parameters and shape parameters. You can generate infinite meshes by adjusting different poses and shapes.

To generate models, first you need to copy the cmu_skeletons.mat into 2-model directory. Then you can run demo_skel2RR.m and demo_RR2obj.m. The first m file will generate cmu_RR.mat file, which is used to transfer poses to rotation matrices. The scond m file will call scape to generate human models. The models are generated in data/models directory.

**Acknowledgement**
Scape is implenmented by Jie Mao. We are grateful to him for providing us with this code.


### Render

We use blender to render models in batch. To render generated models, you can enter the 4-render directory. First, run demo.m to generate some auxiliary files. Then run demo2.m to call blender to render them. You need to define your blender path in demo2.m.

Our rendering parameters will render human images only. To generate a complete images, we need to add background. You can run demo3.m, which will combine human and its background.

Note that this repository contains 3 backgrounds, 3 clothes. In the paper we use 796 backgrrounds and 10000 clothes. Thes clothes can be downloaded in the project website page. You can also make your own images by your own.


