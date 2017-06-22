function [est, theta] = last_location(current_position, prev_position, td)

v = 1;

v1 = current_position - prev_position;  % Make vectors out of the points
x1 = v1(1);
y1 = v1(2);

theta = atan2(y1, x1);                  % Determine direction

H = 0.2;

h = td * v;                             % Length of travelled path in delay
xe = cos(theta)*(h + H);
ye = sin(theta)*(h + H);
est = [xe ye] + prev_position;          % Estimation of current position