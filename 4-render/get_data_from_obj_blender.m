function [ p, f ] = get_data_from_obj_blender( obj )
% obj is file name
% p is obj points, 3x6449

% load data
a = importdata(obj);

% verify
if size(a.data, 1) ~= 6449+6449+7025 && size(a.data, 1) ~= 6449+7025
    p = 0;
    f = 0;
    return
end

if size(a.data, 2) ~= 3
    p = 0;
    f = 0;
    return
end

%%
% points
points = a.data(1:6449, :);
p = points';
f = 0;

% nan
if sum(sum(isnan(p)))>0
    p = 0;
    f = 0;
    return
end

end

