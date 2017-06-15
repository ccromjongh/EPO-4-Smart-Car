function [orx ory] = orientation(xs, ys)

prompt = 'orientation dx [-1,0,1] = ';
dx = input(prompt);
prompt = 'orientation dy [-1,0,1] = ';
dy = input(prompt);

orx = xs - dx;
ory = ys - dy;