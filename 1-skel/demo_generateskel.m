

clear
clc

%%
% path

cd parse;
compile;
cd ..

addpath('parse\');

%%
% folder

datafolder = '..\data';

folder = [ datafolder '\asfamc'];

% each subfolder contain an asf and several amcs
subfolders = dir(folder);

%%
% load data

% count
skeletons = struct;
sequence_num = 0;
skeleton_num = 0;


for i = 1:size(subfolders, 1)
    
    if subfolders(i).name == '.'
        continue
    end
    if strcmp(subfolders(i).name, '..')
        continue
    end
    if subfolders(i).isdir == 0
        continue
    end
    
    asffolder = [ folder '\' subfolders(i).name];
    
    asffile = dir([ asffolder '\' '*.asf']);
    asfpath = [asffolder '\' asffile(1).name];
    
    if size(asffile, 1) ~= 1
        disp('more than one asf file, error!');
        continue;
    end
    
    amcfiles = dir([ asffolder '\' '*.amc']);
    
    %%
    for j = 1:size(amcfiles)
        
        disp([i, j]);
        
        amcpath = [asffolder '\' amcfiles(j).name];
        cmd = ['converter\converter.exe ' asfpath ' ' amcpath];
        system(cmd);
        
        a = parse();
        
        skeletons(sequence_num+1).data = a;
        sequence_num = sequence_num+1;
        
        skeleton_num  = skeleton_num+size(a, 2);
    end
    
end

%%
% save data

disp(skeleton_num);

save cmu_skeletons skeletons

