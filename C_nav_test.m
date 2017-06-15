tic;
[x, y, ang] = main(-0.235, 2.325, -pi/2, 2.38, 1.7);
completion_time = toc;

plot(x, y);

axis([-2.5 2.5 -2.5 2.5]); pbaspect([1 1 1]);

title('KITT navigation using vertex pathfinding');
xlabel('X axis (m)');
ylabel('Y axis (m)');