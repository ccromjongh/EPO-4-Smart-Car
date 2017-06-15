clear FIELD
r = 5;           %car radius [cm]

%boundaries
prompt = 'maximum x [cm] = ';
Xmax = input(prompt)/5;
prompt = 'maximum y [cm] = ';
Ymax = input(prompt)/5;

%start location
prompt = 'start x [cm] = ';
Xs = input(prompt)/5;
prompt = 'start y [cm] = ';
Ys = input(prompt)/5;

%location goal
prompt = 'nr. of Checkpoints = ';
ch = input(prompt);
for i = 1:ch
prompt = 'x location checkpoint [cm] = ';
Xgoal(i) = input(prompt)/5;
prompt = 'y location checkpoint [cm] = ';
Ygoal(i) = input(prompt)/5;
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
FIELD = Obstacle(FIELD,r,n);