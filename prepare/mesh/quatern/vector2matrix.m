function [ matrix ] = vector2matrix( vec1, vec2 )
% vec is (x, y, z)'
% vec2 = matrix*vec1

v1 = vec1/sqrt(vec1'*vec1);
v2 = vec2/sqrt(vec2'*vec2);

angle = acos(v1'*v2);

v3 = cross(v1, v2);
v3 = v3/sqrt(v3'*v3);

q = angle2q(v3, angle);

matrix = q2matrix(q);

end

