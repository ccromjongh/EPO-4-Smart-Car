clear
close all
tic      %start timer
res = 10;%resolution in cm

%% Make map
run map.m        %read map
MapPlot(FIELD);  %plot map
hold on

%% A star 1 (Matlab)
bx = [];
by = [];
for i = 1:ch
    if i == 1
        Xg = Xgoal(1);
        Yg = Ygoal(1);
        [orx, ory] = orientation(Xs, Ys, res);

    else
        Xs = Xgoal(i-1);
        Ys = Ygoal(i-1);
        Xg = Xgoal(i);
        Yg = Ygoal(i);
        orx = Xs;
        ory = Ys;
    end
run A_star.m     %find route

ax = Optimal_path(:,1);
ay = Optimal_path(:,2);

optx = [ax; bx];
opty = [ay; by];
bx = optx;
by = opty;
% fitopt(Optimal_path,res,Xmax,Ymax);
end

%% Plot path 1
set(gca,'XTick',[0:100/(2*res):Xmax] );
set(gca,'XTickLabel',[0:0.5:Xmax/(100/res)] );
set(gca,'YTick',[0:100/(2*res):Ymax] );
set(gca,'YTickLabel',[0:0.5:Ymax/(100/res)] );
grid minor

%% A star 2 (C)
cpath = AnglePoint(Optimal_path);
n = length(cpath)-1;
cpathx = cpath(:,1);
cpathy = cpath(:,2);
for i = 1:n
    
end


t = toc;                                                    %end of timer