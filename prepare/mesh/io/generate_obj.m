function generate_obj(points, triangles, file)
% points is 3d points, 6449x3
% triangles is mesh faces, 12894x3
% file is saved file name

pnum = size(points, 1);
fnum = size(triangles, 1);

fid = fopen(file, 'w');

for i = 1 : pnum
    fprintf(fid, 'v %f %f %f\n', points(i, :));
end;

for i = 1 : fnum
    fprintf(fid, 'f %d %d %d\n', triangles(i, :));
end;

fclose(fid);

end

