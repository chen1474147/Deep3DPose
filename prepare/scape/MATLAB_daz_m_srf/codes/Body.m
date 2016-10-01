classdef Body < handle
    properties
        path;
        points;
        RR;      %Relative R (with respect to template)
        S;
    end
    
    methods
        function handle = drawMesh(obj, varargin)
            ps = obj.points;
            
            if(length(varargin) == 1)
                ps(:,1) = ps(:,1) + varargin{1};
            elseif(length(varargin) == 3)
                ps(:,1) = ps(:,1) + varargin{1};
                ps(:,2) = ps(:,2) + varargin{2};
                ps(:,3) = ps(:,3) + varargin{3};
            end
            handle = trisurf(Meta.instance.triangles, ...
                ps(:,1), ...
                ps(:,2), ...
                ps(:,3), ...
                'LineStyle','none', ...
                'FaceLighting','phong', ...
                'CData', Meta.instance.trisurfCData ...
            );
        end
        
        function drawMesh2(obj, varargin)
            ps = obj.points;
            
            if(length(varargin) == 1)
                ps(:,1) = ps(:,1) + varargin{1};
            elseif(length(varargin) == 3)
                ps(:,1) = ps(:,1) + varargin{1};
                ps(:,2) = ps(:,2) + varargin{2};
                ps(:,3) = ps(:,3) + varargin{3};
            end
            trisurf(Meta.instance.triangles, ...
                ps(:,1), ...
                ps(:,2), ...
                ps(:,3), ...
                'CData', Meta.instance.trisurfCData ...
            );
        end
        function drawPart(obj, partIdx, varargin)
            ps = obj.points;
            %{
            if(length(varargin) == 1)
                ps(:,1) = ps(:,1) + varargin{1};
            elseif(length(varargin) == 3)
                ps(:,1) = ps(:,1) + varargin{1};
                ps(:,2) = ps(:,2) + varargin{2};
                ps(:,3) = ps(:,3) + varargin{3};
            end
            %}
            if(length(varargin) >= 1)
                ps = bsxfun(@plus, ps, varargin{1});
            end
            if(length(varargin) >= 2)
                ps = ps * varargin{2}';
            end
            trisurf(Meta.instance.triangles(Meta.instance.t2bone==partIdx, :), ...
                ps(:,1), ...
                ps(:,2), ...
                ps(:,3), ...
                'LineStyle','none', ...
                'FaceLighting','phong', ...
                'CData', Meta.instance.trisurfCData ...
            );
        end
    end
    
    methods        %constructor
        function obj = Body(varargin)
            if(length(varargin) == 1)
                if(ischar(varargin{1}))
                    obj.path = varargin{1};
                    obj.points = load([obj.path '.xyz']);
                    
                    if(exist([obj.path '.RR'], 'file'))
                        obj.RR = permute(reshape(load([obj.path '.RR'])', 3, 3, []), [2 1 3]);
                    else
                        obj.RR = repmat(eye(3), [1 1 Meta.instance.bonesNum]);
                    end
                    obj.moveToCenter();
                else
                    obj.path = 'none....';
                    obj.S = repmat(eye(3), [1 1 Meta.instance.trianglesNum]);
                    obj.changePose(varargin{1});
                end
            elseif(length(varargin)==2)
                obj.path = 'none...';
                %obj.S = repmat(eye(3), [1 1 Meta.instance.trianglesNum]);
                
                obj.learnS(varargin{2});    %varargin{2} = ShapeParam
                obj.changePose(varargin{1});    %varargin{1} = RR
            end
        end
        function changePose(obj, RR)
            obj.RR = RR;
            Q = obj.learnQ();                                       %time costy!!!!
            obj.points = solveY_RSQ(RR, obj.S, Q);  %time costy!!
            obj.moveToCenter();
        end
        function moveToCenter(obj, varargin)
            if(length(varargin)==0)
                partIdx = 1;
            else
                partIdx = varargin{1};
            end
            center = obj.calculateCenterOfPart(partIdx);
            obj.points = bsxfun(@minus, obj.points, center);
        end
        function center=calculateCenterOfPart(obj, partIdx)
            center = (Meta.instance.weight(:,partIdx)' * obj.points)/sum(Meta.instance.weight(:,partIdx));
        end
    end
    
    methods(Access = public)
        %{
        function computeRR(obj)
            for i=1:Meta.instance.bonesNum
                select = Meta.instance.weight(:,i)>0.6;
                
                X1 = Meta.template.points(select, :);
                X2 = obj.points(select, :);
                
                obj.RR(:,:,i) = computeRotationLS(X1, X2);
            end
        end
        %}
        function Q = trainQ(obj, ws)
            fprintf('trainQ: %s, ws = %d\n', obj.path, ws);
            
            Q = zeros(3, 3, Meta.instance.trianglesNum);
            for i=1:Meta.instance.bonesNum
                triIdx = find(Meta.instance.t2bone==i);
                triIdxInv = accumarray(triIdx, 1:length(triIdx));
                triAdjPart = triIdxInv(Meta.instance.triAdj(all(Meta.instance.t2bone(Meta.instance.triAdj)==i, 2), :));
                t1 = Meta.instance.triangles(triIdx, 1);
                t2 = Meta.instance.triangles(triIdx, 2);
                t3 = Meta.instance.triangles(triIdx, 3);
                u2 = Meta.template.points(t2,:) - Meta.template.points(t1,:);
                v2 = obj.points(t2,:) - obj.points(t1,:);
                u3 = Meta.template.points(t3,:) - Meta.template.points(t1,:);
                v3 = obj.points(t3,:) - obj.points(t1,:);
                for j=1:3
                    Q(j,:,triIdx) = obj.trainQorS_OnePartOneRow(u2, v2, u3, v3, triAdjPart, obj.RR(:,j,i), ws);
                end
            end
            Q = reshape(Q, [9 1 Meta.instance.trianglesNum]);
        end
        
        function S = trainS(obj, ws)
            fprintf('trainS: %s, ws = %d\n', obj.path, ws);
            %R = obj.getRelativeR();
            %Q = obj.learnQ();
            
            S = zeros(3, 3, Meta.instance.trianglesNum);
            
            persistent triIdx triAdjPart t1 t2 t3 u2 u3
            if(isempty(triIdx))
                disp('init trainS...');
                triIdx = cell(Meta.instance.bonesNum,1);
                triAdjPart = cell(Meta.instance.bonesNum,1);
                t1 = cell(Meta.instance.bonesNum,1);
                t2 = cell(Meta.instance.bonesNum,1);
                t3 = cell(Meta.instance.bonesNum,1);
                
                for i=1:Meta.instance.bonesNum
                    triIdx{i} = find(Meta.instance.t2bone==i);
                    triIdxInv = accumarray(triIdx{i}, 1:length(triIdx{i}));
                    triAdjPart{i} = triIdxInv(Meta.instance.triAdj(all(Meta.instance.t2bone(Meta.instance.triAdj)==i, 2), :));
                    t1{i} = Meta.instance.triangles(triIdx{i}, 1);
                    t2{i} = Meta.instance.triangles(triIdx{i}, 2);
                    t3{i} = Meta.instance.triangles(triIdx{i}, 3);
                    u2{i} = Meta.template.points(t2{i},:) - Meta.template.points(t1{i},:);
                    u3{i} = Meta.template.points(t3{i},:) - Meta.template.points(t1{i},:);
                end
            end
            
            
            for i=1:Meta.instance.bonesNum
                %{
                triIdx = find(Meta.instance.t2bone==i);
                triIdxInv = ArrayInv(triIdx);
                triAdjPart = triIdxInv(Meta.instance.triAdj(all(Meta.instance.t2bone(Meta.instance.triAdj)==i, 2), :));
                t1 = Meta.instance.triangles(triIdx, 1);
                t2 = Meta.instance.triangles(triIdx, 2);
                t3 = Meta.instance.triangles(triIdx, 3);
                %}
                
                v2 = obj.points(t2{i},:) - obj.points(t1{i},:);
                v3 = obj.points(t3{i},:) - obj.points(t1{i},:);
                
                %%%%%%%%%%
                %{
                p = rows(triIdx);
                
                QPart = Q(:,:,triIdx);
                for j=1:p
                    u2(j,:) = u2(j,:) * QPart(:,:,j)';
                    u3(j,:) = u3(j,:) * QPart(:,:,j)';
                end
                %}
                %%%%%%%%%%
                
                for j=1:3
                    S(j,:,triIdx{i}) = obj.trainQorS_OnePartOneRow(u2{i}, v2, u3{i}, v3, triAdjPart{i}, obj.RR(:,j,i), ws);
                end
            end
        end
        
        function QorS = trainQorS_OnePartOneRow(obj, u2, v2, u3, v3, triAdjPart, r, ws)
            %q : 3 * p
            %r : 3 * 1
            %u : p * 3
            %v : p * 3
            
            p = size(u2, 1);
            q = size(triAdjPart, 1);
            matrixSize = [3 inf];
            
            IJS = zeros(3*p*3+q*12, 3);
            Y = zeros(3*p, 1);
            cnt = 0;
            
            for i=1:3
                for l=1:3
                    IJS(cnt+1:cnt+p, :) = [sub2ind(matrixSize, ones(p,1)*i,(1:p)'), sub2ind(matrixSize, ones(p,1)*l,(1:p)'), (u2(:,l).*u2(:,i)  + u3(:,l).*u3(:,i))];
                    Y(sub2ind(matrixSize, ones(p,1)*i,(1:p)'), 1) = Y(sub2ind(matrixSize, ones(p,1)*i,(1:p)'), 1)     + r(l)*(v2(:,l).*u2(:,i)) + r(l)*(v3(:,l).*u3(:,i));
                    cnt = cnt + p;
                end
            end
            part1 = triAdjPart(:,1);
            part2 = triAdjPart(:,2);
            for l=1:3
                IJS(cnt+1:cnt+q,:) = [sub2ind(matrixSize, ones(q,1)*l,part1), sub2ind(matrixSize, ones(q,1)*l,part1), repmat( ws,q,1)];  cnt=cnt+q;
                IJS(cnt+1:cnt+q,:) = [sub2ind(matrixSize, ones(q,1)*l,part1), sub2ind(matrixSize, ones(q,1)*l,part2), repmat(-ws,q,1)];  cnt=cnt+q;
                IJS(cnt+1:cnt+q,:) = [sub2ind(matrixSize, ones(q,1)*l,part2), sub2ind(matrixSize, ones(q,1)*l,part2), repmat( ws,q,1)];  cnt=cnt+q;
                IJS(cnt+1:cnt+q,:) = [sub2ind(matrixSize, ones(q,1)*l,part2), sub2ind(matrixSize, ones(q,1)*l,part1), repmat(-ws,q,1)];  cnt=cnt+q;
            end
            
            A = sparse(IJS(:,1), IJS(:,2), IJS(:,3), 3*p, 3*p);
            QorS = reshape(A \ Y, 3, []);
        end
        function Q = learnQ(obj)
            jointAngles = obj.getJointAngles2();    %7x1xMeta.instance.trianglesNum                 %time costy!!!!
            Q = mtimesx(Meta.instance.A, jointAngles, 'SPEED');%A:9x7xMeta.instance.trianglesNum    %time costy!!!!
            Q = reshape(Q, [3 3 Meta.instance.trianglesNum]);
        end
        %{
        function param = learnSParam(obj, varargin)
            if(isempty(varargin))
                ws = 10.^-3.5;
            else
                ws = varargin{1};
            end
            obj.S = obj.trainS(ws);
            param = (toRow(obj.S)-Meta.instance.u) / Meta.instance.U;
        end
        %}
        function learnS(obj, param)
            param = [param 1];
            obj.S = reshape(param*Meta.instance.U+Meta.instance.u, 3, 3, Meta.instance.trianglesNum);
        end
        
        function res = getJointAngles2(obj) %9*1*trianglesNum
            persistent s1 s2 s3 o;
            if isempty(s1)
                disp('init getJointAngle2.....');
                t1 = Meta.instance.t2bone;
                t2 = Meta.instance.t2bone2;
                t3 = Meta.instance.t2bone3;
                [s1, ~, s] = unique([t1 t2; t1 t3], 'rows');
                s2 = s(1:Meta.instance.trianglesNum);
                s3 = s(Meta.instance.trianglesNum+1:2*Meta.instance.trianglesNum);
                o = ones(1, 1, Meta.instance.trianglesNum);
            end
            RTR = mtimesx(obj.RR(:,:,s1(:,1)), 'T', obj.RR(:,:,s1(:,2)), 'SPEED');
            tmp1 = rotation3dToTwist3(RTR);
            res = [tmp1(:,:,s2); tmp1(:,:,s3); o];
        end
        
        function res = readSem(obj) %9*1*trianglesNum
            res = load([obj.path '.sem']);
            res = reshape(res, 1, []);
        end
        %{
        function res = readSem2(obj)
            res = load([obj.path '.sem']);
            res = res(Meta.instance.semIdx);
            res = toRow(res);
        end
        %}
    end
end
