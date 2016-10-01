

clear
clc

%%
%scape

% male£¡
addpath(genpath('../prepare/scape/MATLAB_daz_m_srf'));

Meta.instance.readA;
Meta.instance.readPCA;

% ponints weights
weights = Meta.instance.weight;
[weights_sort, ind] = sort(weights, 2);

%%
% textured models
load('../prepare/mesh3/data/arm_75_view_0');

%%
% shape
% it is a 12 dim vector. You can set your own parameters
shapepara = Meta.instance.sem_default;

%%
% load

load cmu_RR

sknum = size(jointsRR, 4);

%%
% RR2obj

objfolder = '../data/models';
texturefolder = '../textures';
texturefolder2 = '../textures2';

for skel_id = 1:100:sknum
    
    % skel_id = randi(sknum);
    
    RR = jointsRR(:, :, 1:15, skel_id);
    R = jointsRR(:, :, 16, skel_id);
    
    % generate points
    points = Body(RR, shapepara).points;
    
    % rot to original pose
    % p = R'*points';
    p = points';
    p = 0.5*p;
    
    points = p';
    points = moveToCenter(weights, points, 2);
    p = points';
    
    generate_blender( p, restfiles,...
        objfolder, [num2str(skel_id)],...
        texturefolder, randi(3),...
        texturefolder2, randi(3));
end

