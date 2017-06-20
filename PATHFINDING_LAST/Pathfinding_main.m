clear
close all
res = 10;%resolution in cm
ploton = 0;                                     %set to 1 to plot all maps and stuff

%% Make map
run map.m        %read map
if ploton == 1
MapPlot(FIELD);  %plot map, obstacles
end
hold on

prompt = 'orientation [rad] = ';                %read the initial orientation in rad
start_ang = input(prompt);

%% A star 1 (Matlab)
bx = [];
by = [];
for i = 1:ch                                    %loop to get all checkpoints
    if i == 1
        Xg = Xgoal(1);
        Yg = Ygoal(1);
%         [orx, ory] = orientation(Xs, Ys, res);  %if everything works,
%         delete this line
    else
        Xs = Xgoal(i-1);
        Ys = Ygoal(i-1);
        Xg = Xgoal(i);
        Yg = Ygoal(i);
%         orx = Xs;                                 %same here
%         ory = Ys;
    end
run A_star.m                                        %find route

ax = Optimal_path(:,1);                             %this is the optimal path for current checkpoint
ay = Optimal_path(:,2);

optx = [ax; bx];                                    %total path
opty = [ay; by];
bx = optx;
by = opty;
end

%% Plot path 1
if ploton == 1
set(gca,'XTick',[0:100/(2*res):Xmax] );
set(gca,'XTickLabel',[0:0.5:Xmax/(100/res)] );
set(gca,'YTick',[0:100/(2*res):Ymax] );
set(gca,'YTickLabel',[0:0.5:Ymax/(100/res)] );
grid minor
end

%% A star 2 (C)
cpath = AnglePoint(Optimal_path);                              %reduce path to minimal points
n = length(cpath)-1;
cpathx = cpath(:,1);
cpathy = cpath(:,2);
pathout = [];
angpath = [];
for i = 1:n                                                    %run c code between points of prev. pathfinding
    start_x = cpathx(n);
    start_y = cparty(n);
    end_x = cpathx(n+1);
    end_y = cpathy(n+1);
 [x, y, ang, success, end_ang] = main([start_x, start_y], start_ang, [end_x, end_y], [0 Xmax 0 Ymax], Obstacles);    %save path to newpathout
 
 newpathout = [x y];
 pathout = [pathout; newpathout];                               %store the path
 newang = ang;
 angpath = [angpath; newang];                                   %store angle arrays
 start_ang = end_ang;                                           %set the new start angle (orientation)
 
 if success == 0                                                %in case there is no path
     disp('this doesnt work')
     break
 end
end

%% centralise the current path
pathx = pathout(1,:);
pathy = pathout(2,:);

pathx = pathx - Xmax;
pathy = pathy - Ymax;
KITTpath = [pathx pathy];

% clearvars -except KITTpath angpath                         %if you want to
% remove unnecessary variables
% run controlKITT
