function generate_blender( points, restfile,  folder, name, texturefolder, texturenum,...
    texturefolder2, texturenum2)
% points is 3x6449
% restfile is rest part of a textured obj file
% folder is obj path
% name is obj name
% texturefolder is texture folder
% texturenum is which image the obj use, [1-1728]
% texturefolder2 is texture2 folder
% texturenum is which image the obj use, [1-10000]


% obj
fid = fopen([folder, '/', name '.obj'], 'w');

% mtl
fprintf(fid, 'mtllib %s.mtl\n', name);

% points
for i = 1:6449
    fprintf(fid, 'v %f %f %f\n', points(:, i));
end

% rest
fprintf(fid, '%s', restfile);
fclose(fid);

% mtl
fid = fopen([folder, '/', name '.mtl'], 'w');

% mtl
% fprintf(fid, '%s\n%s%s/%d%s', 'newmtl Material', 'map_Kd ', texturefolder,...
%     texturenum, '.png');
fprintf(fid, 'newmtl Material\n');
fprintf(fid, 'map_Kd  %s/%d.png\n', texturefolder, texturenum);
fprintf(fid, 'newmtl Material2\n');
fprintf(fid, 'map_Kd  %s/%d.png\n', texturefolder2, texturenum2);
fclose(fid);

end

