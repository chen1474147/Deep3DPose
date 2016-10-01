function [ M, dataMeaned ] = meanData( data )
M = mean(data);
dataMeaned = bsxfun(@minus, data, M);
end
