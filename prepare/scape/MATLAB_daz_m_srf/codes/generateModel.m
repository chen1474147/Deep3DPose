function model = generateModel()
%GENERATEMODEL Summary of this function goes here
%   Detailed explanation goes here
disp('generate model...');
clear all;
Meta.instance.readA;
Meta.instance.readPCA;

model = struct;

filesPose = dir('myData/SCAPE Pose/*.xyz');
filesShape = dir('myData/SCAPE Shape/*.xyz');
model.test_poseParam = Body(['myData/SCAPE Pose/' strrep(filesPose( randi(length(filesPose)) ).name,'.xyz', '')]).RR;
model.test_shapeParam = Body(['myData/SCAPE Shape/' strrep(filesShape( randi(length(filesShape)) ).name,'.xyz', '')]).readSem();
model.test_points = Body(model.test_poseParam, model.test_shapeParam).points;

model.model_A = Meta.instance.A;
model.model_U = Meta.instance.U;
model.model_u = Meta.instance.u;
V2 = Meta.template.points(Meta.instance.triangles(:,2),:) - Meta.template.points(Meta.instance.triangles(:,1),:);
V3 = Meta.template.points(Meta.instance.triangles(:,3),:) - Meta.template.points(Meta.instance.triangles(:,1),:);
V2 = permute(V2,[3 2 1]);
V3 = permute(V3,[3 2 1]);
model.V23 = [V2;V3];
model.t2bone = Meta.instance.t2bone;
a = Meta.instance.triangles(:,1);
b = Meta.instance.triangles(:,2);
c = Meta.instance.triangles(:,3);
pointsNum = Meta.instance.pointsNum;
trianglesNum = Meta.instance.trianglesNum;
col = (1:trianglesNum)';
o = ones(trianglesNum,1);
IJS = [ ...
    a, col, -o;
    b, col, o;
    a, col+trianglesNum, -o;
    c, col+trianglesNum, o
];
model.K = sparse(IJS(:,1), IJS(:,2), IJS(:,3), pointsNum, 2*trianglesNum);
IJS = [
    a,a,o; ...
    a,b,-o; ...
    b,b,o; ...
    b,a,-o; ...
    a,a,o; ...
    a,c,-o; ...
    c,c,o; ...
    c,a,-o; ...
];
relation = sparse(IJS(:,1), IJS(:,2), IJS(:,3), Meta.instance.pointsNum, Meta.instance.pointsNum);
[model.L,model.U,model.P,model.Q] = lu(relation);

t1 = Meta.instance.t2bone;
t2 = Meta.instance.t2bone2;
t3 = Meta.instance.t2bone3;
[model.s1, ~, s] = unique([t1 t2; t1 t3], 'rows');
model.s2 = s(1:Meta.instance.trianglesNum);
model.s3 = s(Meta.instance.trianglesNum+1:2*Meta.instance.trianglesNum);
model.o = ones(1, 1, Meta.instance.trianglesNum);
model.weight_anchor = Meta.instance.weight(:,1)';
model.weight_anchor = model.weight_anchor / sum(model.weight_anchor);
model.pointsNum = Meta.instance.pointsNum;
model.trianglesNum = Meta.instance.trianglesNum;

model.bonesNum = Meta.instance.bonesNum;
model.triangles = Meta.instance.triangles;
model.trisurfCData = Meta.instance.trisurfCData;
model.p2bone = Meta.instance.p2bone;
model.pcsNum = Meta.instance.pcsNum;
model.weight = Meta.instance.weight;
model.weightTri = Meta.instance.weightTri;
model.sem_num = Meta.instance.sem_num;
model.sem_default = Meta.instance.sem_default;
model.sem_label = Meta.instance.sem_label;

save(['../MATLAB_TINY/models/' Meta.instance.currentFolder '.mat'], '-struct', 'model');
end
