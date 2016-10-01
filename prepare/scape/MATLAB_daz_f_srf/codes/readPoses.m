disp('read poses...');
files = dir('myData/SCAPE Pose/*.xyz');
bodysPose = cell(1, length(files));
for i=1:length(files)
    bodysPose{i} = Body(['myData/SCAPE Pose/' strrep(files(i).name,'.xyz','')]);
end
clear i files
