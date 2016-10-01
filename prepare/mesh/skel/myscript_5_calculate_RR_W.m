function [ RR, T, sumErrors ] = myscript_5_calculate_RR_W( PL, PR, weight )
% PL is source points, mx3
% PR is target points, mx3
% weight is weight of every points, mx1
% RR is rotate matrix, 3x3
% T is transform vecor, 1x3
% PR' = RR*PL' + T

W = diag(weight);

if ~all(size(PL) == size(PR))
    print 'size incorrect';
    return;
end

numPoints = size(PL, 1);

%ʹ��SVD��R
avgPL0 = sum(PL,1)/numPoints;
avgPR0 = sum(PR,1)/numPoints;
PLAvg = repmat(avgPL0,numPoints,1);
PRAvg = repmat(avgPR0,numPoints,1);

PL = PL - PLAvg;
PR = PR - PRAvg;

PL = PL'; %3*n
PR = PR'; %3*n

S0 = PL*W*PR';

[U, S, V] = svd(S0);
M = eye(3);
M(3,3) = det(V*U');

RR = V*M*U';
T = avgPR0' - RR*avgPL0';

PL = PL';
PR = PR';

%�������
sumErrors = 0;
% for i = 1:numPoints
%     pl = PL(i,:);
%     pr = PR(i,:)';
%     prr = RR*pl' + T;
%     diff = pr - prr;
%     sumErrors = sumErrors + norm(diff);
% end

end

