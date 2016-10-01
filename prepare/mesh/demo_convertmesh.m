

clear
clc

%%
% prepare data

addpath('io/');
addpath('skel/');
addpath('quatern/');

% male
scapepath = '../scape/MATLAB_daz_m_srf';
addpath(genpath(scapepath));


%%
% predifined data

Meta.instance.readA;
Meta.instance.readPCA;

% mesh triangles
triangles = Meta.instance.triangles;

% ponints weights
weights = Meta.instance.weight;
[weights_sort, ind] = sort(weights, 2);


%%
% RR to points

RR = repmat(eye(3), 1, 1, 15);

shapepara = Meta.instance.sem_default;

tic;
points = Body(RR, shapepara).points;
toc;

tic;
generate_obj(points, triangles, 'data/tpose.obj');
toc;


%%

% points2skel

tic
[ skel ] = points2skel( points, weights_sort, ind );
toc

generate_skel(skel, 'data/tpose.txt');


%%
% skel2RR

skel_scape = skel;

% wangchuyu
ind_wangchuyu = [4, 1, 17, 18, 19, 13, 14, 15, 3, 9, 10, 11, 5, 6, 7];
skel_wangchuyu = skel_scape(ind_wangchuyu, :);

theta = -85/180*3.1416;
rot_x = [1 0 0; 0 cos(theta), -sin(theta); 0 sin(theta), cos(theta)];
skel_wangchuyu = rot_x*skel_wangchuyu';
skel_wangchuyu = skel_wangchuyu';

tic;
[ RR, R ] = skel2RR( skel_wangchuyu, skel_scape );
toc;

