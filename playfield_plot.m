function playfield_plot (distance, order)
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
axis([0, field_data.field.x, 0, field_data.field.y]);
p.LineWidth = 2;
p.MarkerSize = 10;
p.MarkerFaceColor = 'white';

grid on;
title('Playfield');
xlabel('X-axis (cm)');
xlabel('Y-axis (cm)');

hold on;

for i = 1:5
    circle(field_data.mics(order(i)).x, field_data.mics(order(i)).y, distance(i));
end
% circle(field_data.mics(1).x, field_data.mics(1).y, 56);
% circle(field_data.mics(2).x, field_data.mics(2).y, 268);
% circle(field_data.mics(3).x, field_data.mics(3).y, 247);
% circle(field_data.mics(4).x, field_data.mics(4).y, 87);
% circle(field_data.mics(5).x, field_data.mics(5).y, 96);
