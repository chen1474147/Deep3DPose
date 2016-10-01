

% test functions

clear
clc

%%
% rotation axis and angle

vec = rand(3, 1);
theta = pi * rand();

q = angle2q(vec, theta);

R = q2matrix(q);

q2 = matrix2quaternion(R);

disp(q - q2);

% q = q2

%%
% two vecs

vec1 = rand(3, 1);

vec2 = R*vec1;

R2 = vector2matrix(vec1, vec2);

disp(R);
disp(R2);

disp(vec2 - R*vec1);
disp(vec2 - R2*vec1);

% it is interesting.
% R != R2
% vec2 = R*vec1 = R2*vec1

%%
% q1mulq2

clear
clc

vec = [1 2 3]';

vec1 = [2 3 4]';
theta1 = 30/180*pi;
q1 = angle2q(vec1, theta1);
R1 = q2matrix(q1);
vecr = R1*vec;

vec2 = [7 1 -3]';
theta2 = 50/180*pi;
q2 = angle2q(vec2, theta2);
R2 = q2matrix(q2);
vecr = R2*vecr;


q3 = q1mulq2(q1, q2);
R3 = q2matrix(q3);
vecrr = R3*vec;

disp(vecr - vecrr);
disp(R2*R1 - R3);

%%
% points
% p2 = q*p*qinv

clear
clc

% q & qinv
q = rand(4, 1);
q = q/sqrt(q'*q);
matrix = q2matrix(q);

qinv = [-q(1:3); q(4)];

% points
p = rand(3, 1);
p4 = [p; 0];

% cal
pr = matrix * p;

prr = q1mulq2(q1mulq2(qinv, p4), q);

disp(pr - prr(1:3));