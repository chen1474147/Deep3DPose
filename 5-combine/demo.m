

clear
clc;

%%
% models
modellist = '../4-render/model_objs.txt';
folderpath = '../data/rawimages';

a = importdata(modellist, ' ', 1000000);

%backgrounds
backfolder = '../data/background';
blacknum = 3;

% results
picfolder = '../data/resultsimages';

%%
% matlabpool local 24;

for i = 1:size(a, 1)
    
    % disp(i);
    b = strsplit(a{i}, ' ');
    
    if size(b, 2) ~= 2
        disp(a{i})
        continue
    end
    
    % index, folder name
    id = b{1};
    % model name
    mname = b{2};
    % 3d skeleton name
    data3dpath = [mname(1:end-4) '.txt'];
    if exist(data3dpath, 'file')
        data3d = load(data3dpath);
    else
        continue
    end
    
    % detect if exist results
    repicpath = [picfolder '/' id '_' num2str(0) '.png'];
    if exist(repicpath, 'file')
        continue
    end
    
    % render folder, 2d folder and cam folder
    mre = [folderpath '/' id];
    
    % more than one results
    txts = dir([mre '/*_cam.txt']);
    
    for j = 1:size(txts, 1)
        
        disp([i, j]);
        % camera set path
        campath = [folderpath '/' id '/' txts(j).name];
        camdata = load(campath);
        
        c = camdata(1, 1:3);
        q = camdata(2, :);
        
        data3d2 = blenmder_points(data3d, c, q, 15);
        
        near = 0.01;
        far = 4;
        top = near*tan(28.8418/2/180*pi);
        right = top/540*960;
        
        promatr = [near/right, 0, 0, 0;0, near/top, 0, 0;...
            0, 0, -(far+near)/(far-near), -2*far*near/(far-near);...
            0, 0, -1, 0];
        data2d3 = promatr*[data3d2; ones(1, 15)];
        data2d4 = data2d3./repmat(data2d3(3, :), 4, 1);
        data2d4 = data2d4(1:2, :);
        data2d4 = (data2d4+1)/2;
        data2d = data2d4';
        
        imgpath = campath(1:end-8);
        tmoimpath = [imgpath '.png'];
        if exist(tmoimpath, 'file')
            [tmpim, ~, tmpalpha] = imread([imgpath '.png']);
            tmpim = double(tmpim)/255;
            tmpalpha = double(tmpalpha)/255;
        else
            continue
        end
        
        % crop image
        [ tmpalpha2, tmpim2, data2d2 ] = crop(tmpalpha, 0, tmpim, data2d);
        % shwo
        % show( tmpim2, data2d2 )
        
        % background
        im_backname = [ backfolder '/' num2str(randi(blacknum)) '.png'];
        im_back = imread(im_backname);
        
        [ re_im ] = combine_crop1( tmpalpha2, tmpim2, im_back );
        if re_im == 0
            continue
        end
        
        
        % put path
        repicpath = [picfolder '/' id '_' num2str(j) '.png'];
        re2dpath = [picfolder '/' id '_' num2str(j) '_2d.txt'];
        re3dpath = [picfolder '/' id '_' num2str(j) '_3d.txt'];
        
        % write
        imwrite(re_im, repicpath);
        fid = fopen(re2dpath, 'w');
        for k = 1:15
            fprintf(fid, '%f %f\n', data2d2(k, :));
        end
        fclose(fid);
        
        data3d2 = data3d2';
        fid = fopen(re3dpath, 'w');
        for k = 1:15
            fprintf(fid, '%f %f %f\n', data3d2(k, :));
        end
        fclose(fid);
    end
end

