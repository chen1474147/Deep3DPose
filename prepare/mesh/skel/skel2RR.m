function [ RR, R ] = skel2RR( skel_wangchuyu, skel_scape )
% skel_wangchuyu is 15x3
% skel_scape is 20x3
% RR is scape input, 3x3x15
% R is rotate matrix, 3x3
% skel_scape' = R * skel_wangchuyu'

% change wangchuyu length to calculate rotate
[ skel_wangchuyu2 ] = change_length( skel_wangchuyu, skel_scape );

% calculate global ratation
hip_inds_wangchuyu2 = [6 2 3 16 9 13 10];
hip_inds_scape = [13 1 17 2 3 5 9];
weights = [0.1 0.5 0.1 0.9 0.5 0.1 0.1];

hip_points_wangchuyu2 = skel_wangchuyu2(hip_inds_wangchuyu2, :);
hip_points_scape = skel_scape(hip_inds_scape, :);

% scape = R*wangchunyu
[ R, ~, ~ ] =  myscript_5_calculate_RR_W( hip_points_wangchuyu2, hip_points_scape, weights );

skel_wangchuyu2 = R*skel_wangchuyu2';
skel_wangchuyu2 = skel_wangchuyu2';


% calculate local bone ratation
RR = zeros(3, 3, 15);

par_scape = [1, 2, 4, 13, 14, 14, 17, 18, 18, 5, 6, 6, 9, 10, 10];
child_scape = [2, 3, 1, 14, 15, 15, 18, 19, 19, 6, 7, 7, 10, 11, 11];

par_wangchuyu2 = [2, 16, 1, 6, 7, 7, 3, 4, 4, 13, 14, 14, 10, 11, 11];
child_wangchuyu2 = [16, 9, 2, 7, 8, 8, 4, 5, 5, 14, 15, 15, 11, 12, 12];

vecs_scape = skel_scape(child_scape, :) - skel_scape(par_scape, :);
vecs_wangchuyu2 = skel_wangchuyu2(child_wangchuyu2, :) - skel_wangchuyu2(par_wangchuyu2, :);


% calculate
for i = 1:15;
    
    vec1 = vecs_scape(i, :);
    vec2 = vecs_wangchuyu2(i, :);
    
    % vec2 = RR * vec1
    [ matrix ] = vector2matrix( vec1', vec2' );
    
    RR(:, :, i) = matrix;
end;

end

