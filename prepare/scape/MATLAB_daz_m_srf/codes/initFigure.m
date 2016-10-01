hold on;
axis equal;
set(gcf, 'renderer', 'opengl');
light('Position',[1000 1000 1000],'Style','infinite');
light('Position',[-1000 -1000 -1000],'Style','infinite');
view(30,30)
rotate3d on

xlabel('x');
ylabel('y');
zlabel('z');