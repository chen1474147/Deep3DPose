function [V, D, M, dataMeaned] = pca(data)
%data: datas in rows
%V: eigenvector of cov (components) in rows
%D: eigenvalues of cov (variance)   in column
%M: mean of data in row
[M, dataMeaned] = meanData(data);
[~, S, V] = svd(dataMeaned, 'econ');
D = diag(S).^2;
V = V';

end
