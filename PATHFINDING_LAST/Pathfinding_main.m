clear
close all
res = 10;%resolution in cm
ploton = 0;

%% Make map
run map.m        %read map
if ploton == 1
MapPlot(FIELD);  %plot map, obstacles
end
hold on

prompt = 'orientation dx [rad] = ';
start_ang = input(prompt);

%% A star 1 (Matlab)
bx = [];
by = [];
for i = 1:ch
    if i == 1
        Xg = Xgoal(1);
        Yg = Ygoal(1);
%         [orx, ory] = orientation(Xs, Ys, res);

    else
        Xs = Xgoal(i-1);
        Ys = Ygoal(i-1);
        Xg = Xgoal(i);
        Yg = Ygoal(i);
%         orx = Xs;
%         ory = Ys;
    end
run A_star.m     %find route

ax = Optimal_path(:,1);
ay = Optimal_path(:,2);

optx = [ax; bx];
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
cpath = AnglePoint(Optimal_path);
n = length(cpath)-1;
cpathx = cpath(:,1);
cpathy = cpath(:,2);
pathout = [];
fullang = [];
for i = 1:n
    start_x = cpathx(n);
    start_y = cparty(n);
    end_x = cpathx(n+1);
    end_y = cpathy(n+1);
 [x, y, ang, success] = main([start_x, start_y], start_ang, [end_x, end_y], [0 Xmax 0 Ymax], Obstacles);    %save path to newpathout
 newpathout = [x y];
 pathout = [pathout; newpathout];
 newang = ang;
 fullang = [fullang; newang];
 start_ang = fullang(length(fullang));
 
 if success == 0
     disp('this doesnt work')
     break
 end
end

% clearvars -except pathout fullang
% run controlKITT
