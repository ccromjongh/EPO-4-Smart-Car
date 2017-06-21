function [est, theta] = last_location(location,loc_index, td)

v = 1;

current_position = location(loc_index,:);
prev_position = location(loc_index-1,:);

v1 = current_position - prev_position;  % Make vectors out of the points
x1 = v1(1);
y1 = v1(2);
theta = atan(y1/x1);                    % Determine direction
H = y1/sin(theta);

h = td * v;                             % Length of travelled path in delay
xe = cos(theta)*(h + H);
ye = sin(theta)*(h + H);
est = [xe ye] + prev_position;          % Estimation of current position