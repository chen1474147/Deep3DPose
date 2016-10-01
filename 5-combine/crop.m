function [ alpha2, img2, points2 ] = crop(alpha, bgColor, img, points)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% get boundaries of object
[nr, nc] = size(alpha);
colsum = sum(alpha == bgColor, 1) ~= nr;
rowsum = sum(alpha == bgColor, 2) ~= nc;

left = find(colsum, 1, 'first')- 20 - randi(40);
if left <= 0
    left = 1;
end
right = find(colsum, 1, 'last')+ 20 +randi(40);
if right >= nc
    right = length(colsum);
end
top = find(rowsum, 1, 'first')- 15 - randi(30);
if top <= 0
    top = 1;
end
bottom = find(rowsum, 1, 'last')+ 15 +randi(30);
if bottom >= nr
    bottom = length(rowsum);
end

alpha2 = alpha(top:bottom, left:right);
img2 = img(top:bottom, left:right, :);

data2d = points;
data2d(:, 2) = 1-data2d(:, 2);
data2d = data2d.*repmat([nc, nr], 15, 1);
data2d = data2d - repmat([left-1, top-1], 15, 1);
data2d = data2d ./ repmat([right-left+1, bottom-top+1], 15, 1);
data2d(:, 2) = 1-data2d(:, 2);

points2 = data2d;

end

