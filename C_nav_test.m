r1 = 0.10;  % meter
start_x = -0.235;
start_y = -1.325;
start_ang = -pi/2;
end_x = 2.38;
end_y = -0.7;

tic;
[x, y, ang] = main(start_x, start_y, start_ang, end_x, end_y);
completion_time = toc;

hold off;

plot(x, y);

hold on;

p = plot(start_x, start_y, 'x');
p.LineWidth = 1.5;
p.MarkerSize = 8;


p = plot(end_x, end_y, 'o');
p.LineWidth = 1.5;
p.MarkerSize = 8;

axis([-2.5 2.5 -2.5 2.5]); pbaspect([1 1 1]);

title('KITT navigation using vertex pathfinding');
xlabel('X axis (m)');
ylabel('Y axis (m)');

radius_arr = zeros(1, length(ang));

for i = 1:length(ang)
    if (abs(ang(i)) > 0.0001)
        radius_arr(i) = 0.5 * r1 * tan(0.5 * (pi - ang(i)));
    end
end

% Formula to calculate the max angle for in the algorithm:
% 2*atan(2*R / r1)-pi