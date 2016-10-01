function generate_obj_mtl(...
    points, textures,...
    facespoints, facestextures,...
    objfile, texturefile)
% points is 3d points, 6449x3
% textures is 2d textures, 7025x2
% facespoints is mesh faces, 12894x3
% facestextures is texture faces, 12894x3
% objfile is saved file name
% texturefile is model texture file

%%
%mtl
[pa, fi, ex] = fileparts(objfile);
fid = fopen([pa '/' fi '.mtl'], 'w');
fprintf(fid, 'newmtl Material\nmap_Kd %s\n', texturefile);
fclose(fid);

%%
%obj

fid = fopen(objfile, 'w');

% use mtl file
fprintf(fid, 'mtllib %s\n', [fi '.mtl']);

% points
pnum = size(points, 1);
for i = 1 : pnum
    fprintf(fid, 'v %f %f %f\n', points(i, :));
end;

% vt
tnum = size(textures, 1);
for i = 1 : tnum
    fprintf(fid, 'vt %f %f\n', textures(i, :));
end;

% use material
fprintf(fid, 'usemtl Material\n');

% faces
fnum = size(facespoints, 1);
for i = 1 : fnum
    fprintf(fid, 'f %d/%d %d/%d %d/%d\n',...
        facespoints(i, 1), facestextures(i, 1),...
        facespoints(i, 2), facestextures(i, 2),...
        facespoints(i, 3), facestextures(i, 3));
end;

fclose(fid);

end

