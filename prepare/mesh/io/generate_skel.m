function generate_skel( skel, file )
% skel is 3d skeletons, 15x3 or 20x3
% file is saved file

snum = size(skel, 1);

fid = fopen(file, 'w');

for i = 1:snum
    fprintf(fid, '%f %f %f\n', skel(i, :));
end;

fclose(fid);

end

