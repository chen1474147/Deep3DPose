function animate(varargin)
%ANIMATE Summary of this function goes here
%   Detailed explanation goes here

for_each_times = 45;
sin_times = 1;
ifps = 0.05;
head_max_angle = 90;
upper_body_max_angle = 90;
upper_body_bend = 90;
whole_arm_max_angle = 90;
half_arm_max_angle = 145;
whole_arm_up_down_max_angle = 90;
whole_leg_apart_max_angle = 90;
whole_leg_forward_backward_max_angle = 90;
leg_raise_max_angle = 90;

Meta.instance.readA;
Meta.instance.readPCA;

if(isempty(varargin))
    shapeParam = Meta.instance.sem_default;
else
    shapeParam = varargin{1};
end

initFigure;
handle = Body(Meta.template.RR, shapeParam).drawMesh;
handle1 = Body(Meta.template.RR).drawMesh(1.5,0,0);
drawnow;
axis manual;

%alpha(0.3);
disp('click enter to begin animate...');
pause;

%animate head

for i=1 : for_each_times * sin_times
    theta = sin(i/for_each_times*pi*2) * head_max_angle / 180 * pi;
    poseParam = repmat(eye(3), [1 1 15]);
    tmp = createRotationOx(theta);
    poseParam(:,:,3) = tmp;
    body = Body(poseParam, shapeParam);
    set(handle, 'Vertices', body.points);
    set(handle1, 'Vertices', bsxfun(@plus, [1.5 0 0], Body(poseParam).points));
    drawnow;
    pause(ifps);
end

%animate upper body

for i=1 : for_each_times * sin_times
    theta = sin(i/for_each_times*pi*2) * upper_body_max_angle / 180 * pi;
    poseParam = repmat(eye(3), [1 1 15]);
    tmp = createRotationOz(theta);
    poseParam(:,:,[1 3 4 5 6 7 8 9]) = repmat(tmp, [1 1 8]);
    body = Body(poseParam, shapeParam);
    set(handle, 'Vertices', body.points);
    set(handle1, 'Vertices', bsxfun(@plus, [1.5 0 0], Body(poseParam).points));
    drawnow;
    pause(ifps);
end

%animate upper body bend

for i=1 : for_each_times * sin_times
    theta = sin(i/for_each_times*pi*2) * upper_body_bend / 180 * pi;
    poseParam = repmat(eye(3), [1 1 15]);
    tmp = createRotationOx(theta);
    poseParam(:,:,[1 3 4 5 6 7 8 9]) = repmat(tmp, [1 1 8]);
    body = Body(poseParam, shapeParam);
    set(handle, 'Vertices', body.points);
    set(handle1, 'Vertices', bsxfun(@plus, [1.5 0 0], Body(poseParam).points));
    drawnow;
    pause(ifps);
end

%animate whole arms

for i=1 : for_each_times * sin_times
    theta = sin(i/for_each_times*pi*2) * whole_arm_max_angle / 180 * pi;
    poseParam = repmat(eye(3), [1 1 15]);
    tmp = createRotationOz(theta);
    
    poseParam(:,:,[4 5 6]) = repmat(tmp, [1 1 3]);
    poseParam(:,:,[7 8 9]) = repmat(tmp',[1 1 3]);
    body = Body(poseParam, shapeParam);
    set(handle, 'Vertices', body.points);
    set(handle1, 'Vertices', bsxfun(@plus, [1.5 0 0], Body(poseParam).points));
    drawnow;
    pause(ifps);
end

%animate half arm

for i=1 : for_each_times * sin_times / 2
    theta = sin(i/for_each_times*pi*2) * half_arm_max_angle / 180 * pi;
    poseParam = repmat(eye(3), [1 1 15]);
    tmp = createRotationOz(theta);
    
    poseParam(:,:,[5 6]) = repmat(tmp, [1 1 2]);
    poseParam(:,:,[8 9]) = repmat(tmp',[1 1 2]);
    body = Body(poseParam, shapeParam);
    set(handle, 'Vertices', body.points);
    set(handle1, 'Vertices', bsxfun(@plus, [1.5 0 0], Body(poseParam).points));
    drawnow;
    pause(ifps);
end

%whole arm up down
for i=1 : for_each_times * sin_times
    theta = sin(i/for_each_times*pi*2) * whole_arm_up_down_max_angle / 180 * pi;
    poseParam = repmat(eye(3), [1 1 15]);
    tmp = createRotationOy(theta);
    
    poseParam(:,:,[4 5 6]) = repmat(tmp, [1 1 3]);
    poseParam(:,:,[7 8 9]) = repmat(tmp',[1 1 3]);
    body = Body(poseParam, shapeParam);
    
    set(handle, 'Vertices', body.points);
    set(handle1, 'Vertices', bsxfun(@plus, [1.5 0 0], Body(poseParam).points));
    drawnow;
    pause(ifps);
end

%whole leg apart

for i=1 : for_each_times * sin_times
    theta = sin(i/for_each_times*pi*2/2) * whole_leg_apart_max_angle / 180 * pi;
    poseParam = repmat(eye(3), [1 1 15]);
    tmp = createRotationOy(theta);
    
    poseParam(:,:,[10 11 12]) = repmat(tmp, [1 1 3]);
    poseParam(:,:,[13 14 15]) = repmat(tmp',[1 1 3]);
    body = Body(poseParam, shapeParam);
    set(handle, 'Vertices', body.points);
    set(handle1, 'Vertices', bsxfun(@plus, [1.5 0 0], Body(poseParam).points));
    drawnow;
    pause(ifps);
end

%whole leg forward/backward

for i=1 : for_each_times * sin_times
    theta = sin(i/for_each_times*pi*2) * whole_leg_forward_backward_max_angle / 180 * pi;
    poseParam = repmat(eye(3), [1 1 15]);
    tmp = createRotationOx(theta);
    
    poseParam(:,:,[10 11 12]) = repmat(tmp, [1 1 3]);
    poseParam(:,:,[13 14 15]) = repmat(tmp',[1 1 3]);
    body = Body(poseParam, shapeParam);
    set(handle, 'Vertices', body.points);
    set(handle1, 'Vertices', bsxfun(@plus, [1.5 0 0], Body(poseParam).points));
    drawnow;
    pause(ifps);
end

%leg raise
for i=1 : for_each_times * sin_times
    theta = sin(i/for_each_times*pi*2/2) * leg_raise_max_angle / 180 * pi;
    poseParam = repmat(eye(3), [1 1 15]);
    tmp = createRotationOx(-theta);
    
    poseParam(:,:,10) = tmp;
    poseParam(:,:,13) = tmp;
    body = Body(poseParam, shapeParam);
    set(handle, 'Vertices', body.points);
    set(handle1, 'Vertices', bsxfun(@plus, [1.5 0 0], Body(poseParam).points));
    drawnow;
    pause(ifps);
end


end

function trans = createRotationOx(theta)
    cot = cos(theta);
    sit = sin(theta);
    trans = [ ...
        1 0 0;...
        0 cot -sit;...
        0 sit cot];...
end
function trans = createRotationOy(theta)
    cot = cos(theta);
    sit = sin(theta);
    trans = [...
        cot  0  sit;...
        0    1    0;...
        -sit 0  cot];
end
function trans = createRotationOz(theta)
    cot = cos(theta);
    sit = sin(theta);
    trans = [...
    cot -sit 0;...
    sit  cot 0;...
    0 0 1];
end
