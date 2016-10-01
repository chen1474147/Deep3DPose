function Y = solveY( T )
%templatePoints: pointsNum * 3
%templateTriangles : trianglesNum  * 3
%T             : (3 * 3)   * trianglesNum
%V2/V3/AV2/AV3 : trianglesNum * 3

persistent V23 K L U P Q;
if isempty(V23)
    disp('init persistent');
    V2 = Meta.template.points(Meta.instance.triangles(:,2),:) - Meta.template.points(Meta.instance.triangles(:,1),:);
    V3 = Meta.template.points(Meta.instance.triangles(:,3),:) - Meta.template.points(Meta.instance.triangles(:,1),:);
    V2 = permute(V2,[3 2 1]);
    V3 = permute(V3,[3 2 1]);
    V23 = [V2;V3];
    a = Meta.instance.triangles(:,1);
    b = Meta.instance.triangles(:,2);
    c = Meta.instance.triangles(:,3);
    o = ones(size(a));
    col = (1:Meta.instance.trianglesNum)';
    IJS = [ ...
        a, col, -o;
        b, col, o;
        a, col+Meta.instance.trianglesNum, -o;
        c, col+Meta.instance.trianglesNum, o
    ];
    K = sparse(IJS(:,1), IJS(:,2), IJS(:,3), Meta.instance.pointsNum, 2*Meta.instance.trianglesNum);
    
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
    [L,U,P,Q] = lu(relation);
end
AV = mtimesx(V23, T, 'T', 'SPEED');
AV = reshape(shiftdim(AV,2), [], 3);
y = K * AV;
Y = Q*(U\(L\(P*y)));    %Y = relation \ y;
end
