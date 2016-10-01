

clear
clc

%%
% prepare data

addpath('io/');
addpath('../mesh/io/');
addpath('../mesh/skel/');
addpath('../mesh/quatern/');
addpath(genpath('../scape/MATLAB_daz_m_srf'));

% generate textured model

Meta.instance.readA;
Meta.instance.readPCA;

% triangles = Meta.instance.triangles;
triangles = load('data/facespoints.txt');

% Be careful!!! Here faces of textured models is
% different from original models!!!

%%
% textured models

textures = load('data/textures.txt');
facespoints = load('data/facespoints.txt');
facestextures = load('data/facestextures.txt');

fid = fopen('data/fp.txt', 'w');
for i = 1:12894
    fprintf(fid, '{ %d, %d, %d },\n', facespoints(i, :));
end
fclose(fid);

fid = fopen('data/ft.txt', 'w');
for i = 1:12894
    fprintf(fid, '{%d, %d, %d},\n', facestextures(i, :));
end
fclose(fid);

fid = fopen('data/t.txt', 'w');
for i = 1:7025
    fprintf(fid, '{%f, %f},\n', textures(i, :));
end
fclose(fid);

%%

RR = repmat(eye(3), 1, 1, 15);
shapepara = Meta.instance.sem_default;

points = Body(RR, shapepara).points;

tic;
generate_obj_mtl(...
    points, textures,...
    facespoints, facestextures,...
    'data/tpose.obj', 'texture.png');
toc;


