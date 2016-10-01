function [ len ] = get_skel_len( skel_wangchunyu )
% skel_wangchunyu is skeleton wangchunyu, 15x3
% len is the length of skeleton

par_wangchunyu = [1, 2, 3, 4, 2, 6, 7, 2, 9, 10, 11, 9, 13, 14];
child_wangchunyu = [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15];

vec_wangchunyu = skel_wangchunyu(child_wangchunyu, :) - skel_wangchunyu(par_wangchunyu, :);
veclen_wangchunyu = sqrt(sum(vec_wangchunyu.*vec_wangchunyu, 2));

len = sum(veclen_wangchunyu);

end

