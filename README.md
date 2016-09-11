# Deep 3D Pose

## Synthesizing Training Images for Boosting Human 3D Pose Estimation
Created by <a href="http://irc.cs.sdu.edu.cn/~wenzheng/">Wenzheng Chen</a>, Huan Wang,
<a href="http://web.stanford.edu/~yangyan">Yangyan Li</a>,
<a href="http://ai.stanford.edu/~haosu">Hao Su</a>,
<a href="http://www.cs.sdu.edu.cn/zh/~chtu">Changhe Tu</a>,
<a href="http://www.cs.huji.ac.il/~danix/">Dani Lischinski</a>,
<a href="http://www.math.tau.ac.il/~dcor/">Daniel Cohen-Or</a>,
<a href="http://www.cs.sdu.edu.cn/~baoquan/">Baoquan Chen</a>.


### Introduction

Our work was initially described in an [arXiv tech report](https://arxiv.org/abs/1604.02703) and will appear as a 3D Vision 2016 paper. Deep3DPose is a scalable human image synthesis pipeline for generating millions of human images with their corresponding 2D and 3D pose annotations. These training images can be used for high-capacity models such as deep CNNs.


### License

Deep 3D Pose is released under the MIT License (refer to the LICENSE file for details).


### Citing Deep3DPose
If you find Deep3DPose useful in your research, please consider citing:

To be continued.


### Contents
1. [generate human poses](#human-pose)
2. [generate human models](#human-models)
3. [generate human clothes](#human-clothes)
4. [generate human images and annotations](#human-render)

###  Human Pose
The code in the repository is used to generate human poses. Our pose is composed of 15 joints, as is shown below.



