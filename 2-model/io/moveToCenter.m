function [ points ] = moveToCenter(weights, points, partIdx)
% weights is 6449x15
% points is 6449x3
% partIdx is part index

center = calculateCenterOfPart(weights, points, partIdx);
points = bsxfun(@minus, points, center);

end

function [ center ] = calculateCenterOfPart(weights, points, partIdx)
center = (weights(:, partIdx)' * points)/sum(weights(:, partIdx));
end

