disp('read shapes...');
files = dir('myData/SCAPE Shape/*.xyz');
bodysShape = cell(1, length(files));
for i=1:length(files)
    bodysShape{i} = Body(['myData/SCAPE Shape/' strrep(files(i).name,'.xyz','')]);
end
clear i files
