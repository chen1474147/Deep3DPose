function [ skel ] = points2skel( points, weights_sort, ind )
% points is 6449x3
% weights is 6449x15
% weights_sort is sorted weights by rows
% ind is sorted index
% skel is 20x3 skeleton

% [ weights_sort, ind ] = sort(weights, 2);
skel = zeros(20, 3);

% skel is calculated by one bone.

% head part is 3
% left hand part is 9
% right hand part is 6
% left foot part is 15
% right foot part is 12

partinds = [3, 9, 6, 15, 12];
skelinds = [4, 20, 16, 12, 8];

for i = 1:5
    partind = partinds(i);
    skelind = skelinds(i);
    
    partsele = ind(:, 15) == partind;
    partpoints = points(partsele, :);
    partweights = weights_sort(partsele, 15);
    
    partpoints = partpoints.*repmat(partweights, 1, 3);
    skel(skelind, :) = sum(partpoints)/sum(partweights);
end


% skel is calculated by two bones.
% first is skel ind, second and third are part ind

skelinds2 = [1 1 3;...
    2 1 2;...
    5 2 10;...
    6 10 11;...
    7 11 12;...
    9 2 13;...
    10 13 14;...
    11 14 15;....
    13 1 4;...
    14 4 5;...
    15 5 6;...
    17 1 7;...
    18 7 8;...
    19 8 9];

for i = 1:14
    skelind = skelinds2(i, 1);
    partind1 = skelinds2(i, 2);
    partind2 = skelinds2(i, 3);
    
    sele1 = ind(:, 15) == partind1 & ind(:, 14) == partind2;
    sele2 = ind(:, 15) == partind2 & ind(:, 14) == partind1;
    partsele = sele1 | sele2;
    
    partpoints = points(partsele, :);
    partweights = weights_sort(partsele, 14:15);
    partweights = 1 - (partweights(:, 2) - partweights(:, 1));
    
    partpoints = partpoints.*repmat(partweights, 1, 3);
    skel(skelind, :) = sum(partpoints)/sum(partweights);
end

skel(3, :) =  (skel(2, :)* 1 +  skel(5, :) * 3 +  skel(9, :)*3)/7;
skel(4, :) = skel(1, :) + 1.8 * (skel(4, :) - skel(1, :));

end

