function [ q ] = angle2q( axis, angle )
% axis is rotating axis, (x, y ,z)'
% angle is rotating degree, in PI
% q is (x, y, z, w)'

axis = axis/sqrt(axis'*axis);

angle = angle/2;

q = zeros(4, 1);

q(4, 1) = cos(angle);

q(1:3, 1) = sin(angle)*axis;

end

