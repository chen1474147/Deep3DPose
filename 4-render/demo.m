

clear;
clc;

%%
% scape

addpath('../prepare/mesh/io/');
addpath('../prepare/mesh/skel/');
addpath('../prepare/mesh/quatern/');

% male
scapepath = '../prepare/scape/MATLAB_daz_m_srf';
addpath(genpath(scapepath));

Meta.instance.readA;
Meta.instance.readPCA;

% ponints weights
weights = Meta.instance.weight;
[weights_sort, ind] = sort(weights, 2);


%%
% path to put obj files

folder = '../data/models';
outfolder = folder;

% obj names & num
objfiles = dir([folder '/*.obj']);
objnum = size(objfiles, 1);

%%

for i = 1:objnum
    
    disp(i);
    
    objname = [folder '/'  objfiles(i).name];
    
    try
        [p, ~] = get_data_from_obj_blender(objname);
        r = 85/180*3.1416;
        rr = [1, 0, 0; 0, cos(r), -sin(r);0, sin(r), cos(r)];
        p = rr'*p;
    catch
        continue
    end
    
    if p == 0
        continue
    end
    
    % skeleton
    pp = p';
    [ skel ] = points2skel( pp, weights_sort, ind );
    
    % wangchunyu skeleton
    skelton = skel([4, 1, 17, 18, 19, 13, 14, 15, 3, 9, 10, 11, 5, 6, 7], :);
    
    [pre, name, ~] = fileparts(objname);
    fid = fopen([pre '/' name '.txt'], 'w');
    for k = 1:15
        fprintf(fid, '%f %f %f\n', skelton(k, :));
    end
    fclose(fid);
end



