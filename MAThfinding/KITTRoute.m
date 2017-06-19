%[TODO]
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
%test
Xmax = 32; Ymax =32;

%boundaries
prompt = 'maximum x = ';
Xmax = 10*input(prompt)+2;
prompt = 'maximum y = ';
Ymax = 10*input(prompt)+2;

%location goal
prompt = 'x location goal = ';
Xg = input(prompt);
prompt = 'y location goal = ';
Yg = input(prompt);

FIELD = [ones(Xmax,Ymax)];
for i = 1:Xmax
    FIELD(i,1) = 0;
    FIELD(i,Ymax) = 0;
end
for i = 1:Ymax
    FIELD(1,i) = 0;
    FIELD(Xmax,i) = 0;
end

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


