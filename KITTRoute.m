%[TODO]
% - field boundary
% - KITT model [+]

clear FIELD
Xs = 2;  Ys = 2;   %location KITT, to be measured [EDIT]
r = 0.8;           %turn radius x
% %test
Xmax = 5; Ymax =5;

%boundaries
prompt = 'maximum x = ';
Xmax = input(prompt);
prompt = 'maximum y = ';
Ymax = input(prompt);

%location goal
prompt = 'x location goal = ';
Xg = input(prompt);
prompt = 'y location goal = ';
Yg = input(prompt);
% 
% FIELD = [zeros(10*Xmax+2,10*Ymax+2)];
FIELD = [ones(10*Xmax,10*Ymax)];
%obstacle locations
prompt = 'nr. of obstacles = ';
n = input(prompt);
for i = 1:n;
    prompt = sprintf('x location obstacle %d = ',i);
    Xb(i) = input(prompt);
    prompt = sprintf('y location obstacle %d = ',i);
    Yb(i) = input(prompt);
    Xtemp = 10*Xb(i);
    Ytemp = 10*Yb(i);
    for k = 0:4
        for j = 0:4;
    FIELD(Xtemp-2+k,Ytemp-2+j) = 0;
        end
    end
end


