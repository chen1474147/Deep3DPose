% write the filelist


clear
clc


%%
% folder

folder = '../data/models';
objfiles = dir([folder '/*.obj']);
objnum = size(objfiles, 1);

%%
% absfoler

fid = fopen('model_objs.txt', 'w');
for i = 1:objnum
    disp(i);
    objname = [folder '/' objfiles(i).name ];
    [pre, name, ~] = fileparts(objname);
    fprintf(fid, '%s %s/%s.obj\n', num2str(i), pre, name);
end
fclose(fid);

