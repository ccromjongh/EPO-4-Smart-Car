function playfield_plot (distance, order)
distance_between = 20;
circles = 5;
base_expansion = 120;

if (nargin < 2)
   order = 1:5; 
end

JSON = fileread('field.json');

field_data = jsondecode(JSON);
clear JSON;

figure(4);
hold off;
subplot(1,1,1);

p = plot([field_data.mics.x], [field_data.mics.y], 'o');
axis([field_data.field.x_min, field_data.field.x_max, field_data.field.y_min, field_data.field.y_max]);
p.LineWidth = 2;
p.MarkerSize = 14;
p.MarkerFaceColor = 'white';
text([field_data.mics.x] - 2, [field_data.mics.y], num2str((1:numel(field_data.mics))'), 'FontWeight', 'bold');

hold on;

p = plot([field_data.marks.x], [field_data.marks.y], 'x');
p.LineWidth = 2;
p.MarkerSize = 14;
p.MarkerFaceColor = 'white';
text([field_data.marks.x] - 3, [field_data.marks.y] + 12, {field_data.marks.label}, 'FontWeight', 'bold');

grid on;
title('Playfield');
xlabel('X-axis (cm)');
xlabel('Y-axis (cm)');

colours = {[0.957, 0.263, 0.212]; [0.612, 0.153, 0.690];...
           [0.129, 0.588, 0.953]; [0.298, 0.686, 0.314];...
           [1.000, 0.922, 0.231]};

for i = 1:5
    p = circle(field_data.mics(order(i)).x, field_data.mics(order(i)).y, distance(i));
    p.Color = colours{i};
    for j = 1:circles
        p = circle(field_data.mics(order(i)).x, field_data.mics(order(i)).y,...
            distance(i) + distance_between*j + base_expansion, '--');
        p.Color = colours{i};
    end
end
% circle(field_data.mics(1).x, field_data.mics(1).y, 56);
% circle(field_data.mics(2).x, field_data.mics(2).y, 268);
% circle(field_data.mics(3).x, field_data.mics(3).y, 247);
% circle(field_data.mics(4).x, field_data.mics(4).y, 87);
% circle(field_data.mics(5).x, field_data.mics(5).y, 96);
