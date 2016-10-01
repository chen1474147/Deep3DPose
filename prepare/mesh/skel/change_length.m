function [ skel_wangchunyu2 ] = change_length( skel_wangchunyu, skel_scape )
% skel_wangchuyu is skeleton wangchunyu, 15x3
% skel_scape is skeleton scape, 20x3
% skel_wangchunyu2 is to modify wangchunyu to be the same length as scape for every bone, 16x3

skel_wangchunyu(16, :) = (skel_wangchunyu(2, :) + skel_wangchunyu(9, :))/2;

par_wangchunyu = [1, 2, 3, 4, 2, 6, 7, 2, 16, 9, 10, 11, 9, 13, 14];
child_wangchuyu = [2, 3, 4, 5, 6, 7, 8, 16, 9, 10, 11, 12, 13, 14, 15];

vec_wangchunyu = skel_wangchunyu(child_wangchuyu, :) - skel_wangchunyu(par_wangchunyu, :);
veclen_wangchuyu = sqrt(sum(vec_wangchunyu.*vec_wangchunyu, 2));


par_scape = [4, 1, 17, 18, 1, 13, 14, 1, 2, 3, 9, 10, 3, 5, 6];
child_scape = [1, 17, 18, 19, 13, 14, 15, 2, 3, 9, 10, 11, 5, 6, 7];

vec_scape = skel_scape(child_scape, :) - skel_scape(par_scape, :);
veclen_scape = sqrt(sum(vec_scape.*vec_scape, 2));


vecratio = veclen_scape ./veclen_wangchuyu;
vec_wangchunyu = vec_wangchunyu .* repmat(vecratio, 1, 3);


skel_wangchunyu2 = zeros(16, 3);
skel_wangchunyu2(1, :) = skel_wangchunyu(1, :);

for i = 1:15
    be = par_wangchunyu(i);
    en = child_wangchuyu(i);
    
    skel_wangchunyu2(en, :) = skel_wangchunyu2(be, :) + vec_wangchunyu(i, :);
end

end

