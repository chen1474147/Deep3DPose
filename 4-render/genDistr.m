% a= mean+stand *randn(n)

num = 300;

% degree from x axis in xy plane, blender coordiante
a = 270 + 60*randn(1, num);
a = mod(a, 360);
% a = round(a);

% degree from xy plane, blender coordinate
b = 0 + 25*randn(1, num);
% b = round(b);

% degree rotated around camera axis
c  = 0 + 15*randn(1, num);
% c = round(c);

% camera distance, perspective degree
d = 2.15;

fid = fopen('Distr.txt', 'w');
for i = 1:num
    fprintf(fid, '%f %f %f %f\n', a(i), b(i), c(i), d);
end
fclose(fid);

