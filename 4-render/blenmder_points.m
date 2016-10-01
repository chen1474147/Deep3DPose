function [ p ] = blenmder_points( points,  ccccc, qqqqq, num )
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

if nargin == 3
    num = 6449;
end
% camera is in ccccc, 1x3
% camera's rotation will be qqqqq, 1x4, w, x, y, z

% change points in blender coordinate
% points is 6449x3
p = points;
p(:, 3) = points(:, 2);
p(:, 2) = -points(:, 3);

% change to camera coordinate
% camera is in ccccc
p = p - repmat(ccccc, num, 1);

% rotate
q = qqqqq;
q(1, 1:3) = qqqqq(1, 2:4);
q(1, 4) = qqqqq(1);
q = q';

matrix = q2matrix(q);
p = p';
% points should rotate by inverse matrix
p = matrix'*p;

end

