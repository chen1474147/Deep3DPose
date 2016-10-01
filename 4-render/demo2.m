

clear
clc

slash = '\';
abstractpath = 'D:\zcode\github\Deep3DPose-1-skel';

%%
% global variable

% Blender path
g_blender_path = 'D:\zcode\github\blender-2.76b-windows64\blender';

% Render meta data
g_model_obj_filelists_folder = '.';
g_view_distr_folder = '.';

% result folder
g_rendered_raw_imgs_folder = [abstractpath slash 'data' slash 'rawimages'];


%%
% render all

model_obj_filelists_folder = g_model_obj_filelists_folder;
view_distr_folder = g_view_distr_folder;
output_dir = g_rendered_raw_imgs_folder; % args['outdir']


model_obj_filelist = [model_obj_filelists_folder slash 'model_objs.txt'];
distr = [view_distr_folder slash 'Distr.txt'];
out_dir = output_dir;

num_per_model = 1;

command =sprintf('python render_batch.py --num %d --model %s --outdir %s --distr %s',...
    num_per_model, model_obj_filelist, out_dir, distr);
disp(command)


%%
% render batch

modelObjFilelist = model_obj_filelist;
distrFile = distr;
renderRootFolder = out_dir;

if ~exist(renderRootFolder, 'dir')
    cmd = ['mkdir ' renderRootFolder];
    system(cmd);
end

% render number per model
imgnum_per_model = num_per_model;
renderParams = load(distrFile);

% Get all the model IDs and model obj file paths
model_lines = importdata(modelObjFilelist, ' ', size(renderParams, 1));

modelnum = size(model_lines, 1);
viewnum = size(renderParams, 1);

%%
% commands

commands = [];

for i = 1:modelnum
    
    disp(i);
    
    str = model_lines{i};
    strsp = strsplit(str);
    modelId = strsp{1};
    
    objFile = strsp{2};
    objFile = strrep(objFile, '/', '\');
    
    renderFolder = [renderRootFolder slash modelId];
    if ~exist(renderFolder, 'dir')
        cmd = ['mkdir ' renderFolder];
        system(cmd);
    end
    if (size(dir(renderFolder), 1)-2)/2 >= imgnum_per_model
        disp('skip');
        continue;
    end
    
    tmp_dirname = 'tmp_views';
    if ~exist(tmp_dirname, 'dir')
        cmd = ['mkdir ' tmp_dirname];
        system(cmd);
    end
    
    
    viewname = [tmp_dirname slash modelId '.txt'];
    fp = fopen(viewname, 'w');
    for j = 1:imgnum_per_model
        paramId = randi(viewnum);
        param = renderParams(paramId, :);
        fprintf(fp, '%f %f %f %f\n', param);
    end
    fclose(fp);
    
    command = sprintf('%s blank.blend --background --python render_model_views.py -- %s %s %s',...
        g_blender_path, objFile, renderFolder, viewname);
    % disp(command);
    % system(command);
    commands{i} = command;
end

%%
% run

cmdnum = size(commands, 2);
tic
for i = 1:cmdnum
    system(commands{i});
end
toc
