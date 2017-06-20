r1 = 0.10;  % Meter per segement
r2 = 0.40;  % Meter to stay away from obstacles
dy = -0.6;
%dy = 0;

start_x = -0.235;
start_y = -1.325 + dy;
start_ang = pi/2;
end_x = 2.38;
end_y = -0.7 + dy;

obstacles = [0.9, -1.44];
%obstacles = [];

tic;
try
    %[x, y, ang] = main(start_x, start_y, start_ang, end_x, end_y);
    [x, y, ang, success] = main_broken([start_x, start_y], start_ang, [end_x, end_y], [-2.5 2.5 -2.5 2.5], obstacles);
catch
    disp('Well, something went wrong, apparently');
end
completion_time = toc;

hold off;

if (success)
    plot(x, y);
else
    plot(x, y, '+');
end

hold on;

p = plot(start_x, start_y, 'x');
p.LineWidth = 1.5;
p.MarkerSize = 8;


p = plot(end_x, end_y, 'o');
p.LineWidth = 1.5;
p.MarkerSize = 8;

[nObstacles, ~] = size(obstacles);
for i=1:nObstacles
   circle(obstacles(i, 1), obstacles(i, 2), r2);
end

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