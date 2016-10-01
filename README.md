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
1. [generate human poses](#human-pose)
2. [generate human models](#human-models)
3. [generate human clothes](#human-clothes)
4. [render human images](#human-clothes)


### Human Pose
The code in the repository is used to generate human poses. We use [CMU Mocap Database](http://mocap.cs.cmu.edu/) as pose sources. This database contains about 4 million poses. To better cover the pose space, we also learn [a Bayesian network](http://npp.is.tue.mpg.de/iccv2013/) from these poses.

To use the code, You can directly run the code demo_generateskel.m in matlab directory. It will generate cmu_skeletons mat file which contains poses.

To acquire more poses, you can download the [asf & amc format zipfile](http://mocap.cs.cmu.edu/allasfamc.zip) from [CMU Mocap Database](http://mocap.cs.cmu.edu/). Then you can set the directory in demo_generateskel.m to generate new poses.

Note that the code doesn't include the [Bayesian network](http://npp.is.tue.mpg.de/iccv2013/) code. You can download it from the [original website](http://npp.is.tue.mpg.de/iccv2013/) and use the generated poses as input to learn the model.

We transform poses from CMU format to our own format. See images in sources directory. Then we use poses to generate human models.


### Human-models
