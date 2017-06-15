clear FIELD
r = 5;           %car radius [cm]

%boundaries
prompt = 'maximum x [cm] = ';
Xmax = ceil(input(prompt)/res);
prompt = 'maximum y [cm] = ';
Ymax = ceil(input(prompt)/res);

%start location
prompt = 'start x [cm] = ';
Xs = ceil(input(prompt)/res);
prompt = 'start y [cm] = ';
Ys = ceil(input(prompt)/res);

%location goal
prompt = 'nr. of Checkpoints = ';
ch = input(prompt);
for i = 1:ch
prompt = 'x location checkpoint [cm] = ';
Xgoal(i) = ceil(input(prompt)/res);
prompt = 'y location checkpoint [cm] = ';
Ygoal(i) = ceil(input(prompt)/res);
end
FIELD = [zeros(Ymax,Xmax)];
for i = 1:Ymax
    FIELD(i,1) = 1;
    FIELD(i,Xmax) = 1;
end
for i = 1:Xmax
    FIELD(1,i) = 1;
    FIELD(Ymax,i) = 1;
end
%obstacle locations
prompt = 'nr. of obstacles = ';
n = input(prompt);
FIELD = Obstacle(FIELD,r,n,res);