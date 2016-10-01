function [ re_im ] = combine_crop1( tmpalpha2, tmpim2, im_back )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

[ylen, xlen, ~] = size(tmpim2);
[ylen2, xlen2, ~ ] =  size(im_back);


% the ratio of model/back
k = 1/3 + 1/3*rand();
% the position of the model in back
% height of k/2
s_height = abs((0.5-k/2)/2.*randn())+k/2;
if s_height>0.5
    s_height = 0.5;
end

% resize
ylen_resize = round(ylen2*k);
xlen_resize = round(ylen_resize*xlen/ylen);

% position in back
ymin = round(s_height*ylen2 - ylen_resize/2);
if ymin == 0
    ymin = 1;
end
ymax = ymin + ylen_resize-1;

if xlen_resize > xlen2
    re_im = 0;
    return
end

% position of x
k2 = xlen_resize/xlen2;
% x at k/2
s_width = k2/2 + (1-k2)*rand();
xmin = round(s_width*xlen2 - xlen_resize/2);
if xmin == 0
    xmin = 1;
end
if xmin+xlen_resize-1 > xlen2
    xmin = 1;
end
xmax = xmin+xlen_resize-1;

% resize
tmpalpha3 = imresize(tmpalpha2, [ylen_resize, xlen_resize]);
tmpim3 = imresize(tmpim2, [ylen_resize, xlen_resize]);

% add
im_back = im_back(ymin:ymax, xmin:xmax, :);
im_back = double(im_back)/255;
tmpalpha3_back = 1-tmpalpha3;

re_im = zeros(ymax-ymin+1, xmax-xmin+1, 3);
for k = 1:3
    re_im(:, :, k) = tmpalpha3.*tmpim3(:, :, k) + tmpalpha3_back .* im_back(:, :, k);
end

end

