function [orx ory] = orientation(xs, ys,res)

prompt = 'orientation dx [-1,0,1] = ';
dx = res*input(prompt);
prompt = 'orientation dy [-1,0,1] = ';
dy = res*input(prompt);

orx = xs - dx;
ory = ys - dy;