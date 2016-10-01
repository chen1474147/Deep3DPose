clear all;
clc;
disp('start training...');
addpath(genpath('.'));
readPoses;
readShapes;
Meta.instance.trainA(bodysPose, 1E-6);
Meta.instance.trainPCA(bodysShape, 1E-6);

generateModel;