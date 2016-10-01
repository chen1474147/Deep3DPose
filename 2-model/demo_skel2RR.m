

clear
clc

%%
% path

addpath('../prepare/mesh/skel/');
addpath('../prepare/mesh/quatern/');

skel_scape = load('../prepare/mesh/data/tpose.txt');

%%
% load skel

load cmu_skeletons

% 45xm frames
% 45 is 15x3 skeleton
% here I use only one sequence
joints3d = skeletons(1).data;

%%
% skel2RR

sknum = size(joints3d, 2);

jointsRR = zeros(3, 3, 16, sknum);

for skel_id = 1:sknum
    
    disp(skel_id);
    
    skel = joints3d(:, skel_id);
    
    skel = reshape(skel, 3, []);
    skel = skel';
    
    [ RR,  R ] = skel2RR( skel, skel_scape );
    
    jointsRR(:, :, 1:15, skel_id) = RR;
    jointsRR(:, :, 16, skel_id) = R;
end


%%
% move head

sknum = size(jointsRR, 4);

heads = zeros(4, sknum);

% cal head
for skel_id = 1:sknum
    
    disp(skel_id);
    
    head = jointsRR(:, :, 3, skel_id);
    headq = matrix2quaternion(head);
    
    heads(:, skel_id) = headq;
end

% move head
headmean = mean(heads, 2);
headmean = headmean/sqrt(headmean'*headmean);

matrix = q2matrix(headmean);
matrix = matrix';

% valid
for skel_id = 1:sknum
    
    disp(skel_id);
    
    jointsRR(:, :, 3, skel_id) = matrix*jointsRR(:, :, 3, skel_id);
    
    head = jointsRR(:, :, 3, skel_id);
    
    headq = matrix2quaternion(head);
    
    heads(:, skel_id) = headq;
end

headmean = mean(heads, 2);
disp(headmean);


save cmu_RR jointsRR

