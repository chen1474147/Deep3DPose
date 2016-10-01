classdef Meta < handle
    %META Summary of this class goes here
    %   Detailed explanation goes here

    properties(Constant)
        template_path = 'myData/SCAPE Template/0';
        instance = Meta();
        template = Body(Meta.template_path);
    end
    properties
        triangles;  %trianglesNum * 3
        triAdj;     
        weight;     %pointsNum    * bonesNum
        weightTri;  %trianglesNum * bonesNum
        p2bone;
        t2bone, t2bone2, t2bone3;
        trisurfCData;
        
        A;
        
        U,u;            %eigenvectors and means
        pcsNum = 30;    %number of principles that keeps
        
        currentFolder;
		is_daz_m_srf;
		is_daz_m_ext;
        is_daz_m_int;
		is_daz_f_srf;
		is_daz_f_ext;
		is_daz_f_int;
        
        sem_num;
        sem_label;
        sem_default;
    end
    
    methods (Access = private)  %constructer
        function meta = Meta()
            disp('reading meta...');
			[~, meta.currentFolder, ~] = fileparts(pwd);
			meta.is_daz_m_srf = strcmpi(meta.currentFolder, 'matlab_daz_m_srf');
			meta.is_daz_m_ext = strcmpi(meta.currentFolder, 'matlab_daz_m_ext');
			meta.is_daz_m_int = strcmpi(meta.currentFolder, 'matlab_daz_m_int');
			meta.is_daz_f_srf = strcmpi(meta.currentFolder, 'matlab_daz_f_srf');
			meta.is_daz_f_ext = strcmpi(meta.currentFolder, 'matlab_daz_f_ext');
			meta.is_daz_f_int = strcmpi(meta.currentFolder, 'matlab_daz_f_int');
			
            if(meta.is_daz_m_srf),disp(['is_daz_m_srf = ' num2str(meta.is_daz_m_srf)]),end;
            if(meta.is_daz_m_ext),disp(['is_daz_m_ext = ' num2str(meta.is_daz_m_ext)]),end;
            if(meta.is_daz_m_int),disp(['is_daz_m_int = ' num2str(meta.is_daz_m_int)]),end;
            if(meta.is_daz_f_srf),disp(['is_daz_f_srf = ' num2str(meta.is_daz_f_srf)]),end;
            if(meta.is_daz_f_ext),disp(['is_daz_f_ext = ' num2str(meta.is_daz_f_ext)]),end;
            if(meta.is_daz_f_int),disp(['is_daz_f_int = ' num2str(meta.is_daz_f_int)]),end;
            
            if(meta.is_daz_m_srf || meta.is_daz_m_ext || meta.is_daz_m_int)
                fid = fopen('myData/meta/semMeta_m.txt');
            else
                fid = fopen('myData/meta/semMeta_f.txt');
            end
            meta.sem_num = fscanf(fid, '%d', 1);
            meta.sem_label = cell(1,meta.sem_num);
            for i=1 : meta.sem_num
                meta.sem_label{i} = fscanf(fid, '%s', 1);
            end
            meta.sem_default = fscanf(fid, '%f', [1 meta.sem_num]);
            fclose(fid);
            meta.triangles = load('myData/meta/triangles.txt');
            meta.triAdj = load('myData/meta/triAdj.txt');
            
            meta.weight = load('myData/meta/weight.txt');
            [~,meta.p2bone] = max(meta.weight,[],2);
            meta.weightTri = ...
                (meta.weight(meta.triangles(:,1),:) + ...
                meta.weight(meta.triangles(:,2),:) + ...
                meta.weight(meta.triangles(:,3),:)) / 3;
            [~,IX] = sort(meta.weightTri, 2);
            meta.t2bone = IX(:, meta.bonesNum);
            meta.t2bone2 = IX(:, meta.bonesNum-1);
            meta.t2bone3 = IX(:, meta.bonesNum-2);
            
            colors = hsv(meta.bonesNum);
            meta.trisurfCData = zeros(meta.pointsNum, 1, 3);
            meta.trisurfCData(:,1,:) = colors(meta.p2bone,:);
        end
    end
    
    methods
       %get number
        function res = trianglesNum(obj)
            res = size(obj.triangles, 1);
        end
        function res = triAdjNum(obj)
            res = size(obj.triAdj, 1);
        end
        function res = bonesNum(obj)
            res = size(obj.weight, 2);
        end
        function res = pointsNum(obj)
            res = size(obj.weight, 1);
        end
        function res = isTriAdj(obj, a, b)
            ta = obj.triangles(a, :);
            tb = obj.triangles(b, :);
            res = 0;
            for i=1:3
                for j=1:3
                    if(ta(i)==tb(j))
                        res = 1;
                        return;
                    end
                end
            end
        end
        function trainA(obj, bodys, varargin)
            if(isempty(varargin))
                ws = 10.^-3.5;
            else
                ws = varargin{1};
            end
            bodysNum = length(bodys);
            fprintf('trainA: bodysNum=%d, ws = %s\n', bodysNum, ws);
            
            %compute jointAngles, Qs
            jointAngles = zeros(7, bodysNum, obj.trianglesNum);
            Qs = zeros(9, bodysNum, obj.trianglesNum);
            
            for i=1:bodysNum
                jointAngles(:, i, :) = bodys{i}.getJointAngles2();
                Qs(:, i, :) = bodys{i}.trainQ(ws);
            end
            %compute A      A(:,:,j)*jointAngles(:,:,j) = Qs(:,:,j);
            obj.A = zeros(9, 7, obj.trianglesNum);
            for j=1:obj.trianglesNum
                obj.A(:,:,j) = Qs(:,:,j) / jointAngles(:,:,j);
            end
            whos obj.A;
            obj.writeA();
        end
        
        function rate = trainPCA(obj, bodys, varargin)
            if(isempty(varargin))
                ws = 10.^-3.5;
            else
                ws = varargin{1};
            end
            bodysNum = length(bodys);
            
            fprintf('trainPCA: bodysNum=%d, ws = %d\n', bodysNum, ws);
            
            Ss = zeros(bodysNum, 3*3*Meta.instance.trianglesNum);
            for i=1:bodysNum
                Ss(i,:) = reshape(bodys{i}.trainS(ws), [], 1);
            end
            
            global D
            if(Meta.instance.is_daz_m_srf || Meta.instance.is_daz_f_srf)
                [V, D, M, dataMeaned] = pca(Ss);
                V = V(1:obj.pcsNum, :);
                sems = zeros(bodysNum, Meta.instance.sem_num+1);
                for i=1:bodysNum
                    sems(i,:) = [bodys{i}.readSem() 1];
                end
                WB = (sems\(dataMeaned/V)) * (V/dataMeaned);
                rate = sum(D(1:obj.pcsNum)) / sum(D);
                if(Meta.instance.is_daz_m_srf)
                    save 'model/WB.mat' WB rate;
                else
                    save 'model/WB.mat' WB rate;
                end
            else
                if(Meta.instance.is_daz_m_ext || Meta.instance.is_daz_m_int)
                    load '../MATLAB_daz_m_srf/model/WB.mat' WB rate;
                else
                    load '../MATLAB_daz_f_srf/model/WB.mat' WB rate;
                end
                [M, dataMeaned] = meanData(Ss);
            end
            obj.U = WB * dataMeaned;
            obj.u = M;
            obj.writePCA();
            fprintf('trainPCA over, dimension reduce from %d to %d, %f%% energy keeps.\n', size(obj.U,2), size(obj.U,1), rate*100.0);
        end
        
        function writeA(obj)
            A = obj.A;
            save 'model/A.mat' A;
        end
        function readA(obj)
            A = load('model/A.mat');
            obj.A = A.A;
        end
        
        function writePCA(obj)
            U = obj.U;
            u = obj.u;
            save 'model/PCA.mat' U u;
        end
        
        function readPCA(obj)
            PCA = load('model/PCA.mat');
            obj.U = PCA.U;
            obj.u = PCA.u;
            
        end
    end
end
