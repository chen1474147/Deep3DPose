

%%
clear
clc

%%
%scape

addpath('../mesh/io/');
addpath('../mesh/skel/');
addpath('../mesh/quatern/');
addpath(genpath('../scape/MATLAB_daz_m_srf'));

% generate textured model

Meta.instance.readA;
Meta.instance.readPCA;

%%
% points

RR = repmat(eye(3), 1, 1, 15);
shapepara = Meta.instance.sem_default;

points = Body(RR, shapepara).points;
p = points';

%%
% textured model

angle = 75;
view = 0;

load('data/arm_75_view_0.mat');

fid = fopen('data/tpose.obj', 'w');
fprintf(fid, 'mtllib tpose.mtl\n');
for i = 1:6449
    fprintf(fid, 'v %f %f %f\n', p(:, i));
end
fprintf(fid, '%s', restfiles);
fclose(fid);

fid = fopen('data/tpose.mtl', 'w');
fprintf(fid, 'newmtl Material\n');
fprintf(fid, 'map_Kd  1.png\n');
fprintf(fid, 'newmtl Material2\n');
fprintf(fid, 'map_Kd  projection_arm_75_view_0.png\n');
fclose(fid);

