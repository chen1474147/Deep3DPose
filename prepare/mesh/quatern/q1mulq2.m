function [ q ] = q1mulq2( q1, q2 )
% q is (x, y, z, w)'
% q = q1*q2
% the rotate matrix will first rotate q1
% then rotate q2

w1 = q1(4, 1);
w2 = q2(4, 1);

x1 = q1(1, 1);
y1 = q1(2, 1);
z1 = q1(3, 1);

x2 = q2(1, 1);
y2 = q2(2, 1);
z2 = q2(3, 1);

w = w1*w2 - x1*x2 - y1*y2 - z1*z2;
x = w1*x2 + x1*w2 + z1*y2 - y1*z2;
y = w1*y2 + y1*w2 + x1*z2 - z1*x2;
z = w1*z2 + z1*w2 + y1*x2 - x1*y2;

q = [x, y, z, w]';

% q = q/sqrt(q'*q);

end

