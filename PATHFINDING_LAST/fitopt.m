function fitopt(opt,res,Xmax,Ymax)
fitplot = fit(opt(:,1),opt(:,2),'smoothingspline');
plot(fitplot)

set(gca,'XTick',[0:100/(2*res):Xmax] );
set(gca,'XTickLabel',[0:0.5:Xmax/(100/res)] );
set(gca,'YTick',[0:100/(2*res):Ymax] );
set(gca,'YTickLabel',[0:0.5:Ymax/(100/res)] );
grid minor
hold on