clear all
close all
tic
run map.m        %read map

MapPlot(FIELD);  %plot map
hold on

for i = 1:ch
    if i == 1
        Xg = Xgoal(1);
        Yg = Ygoal(1);
        [orx, ory] = orientation(Xs, Ys);

    else
        Xs = Xgoal(i-1);
        Ys = Ygoal(i-1);
        Xg = Xgoal(i);
        Yg = Ygoal(i);
        orx = Xs;
        ory = Ys;
    end
run A_star.m     %find route
end
t = toc
set(gca,'XTick',[0:10:Xmax] );
set(gca,'XTickLabel',[0:0.5:Xmax/20] );
set(gca,'YTick',[0:10:Ymax] );
set(gca,'YTickLabel',[0:0.5:Ymax/20] );
grid minor