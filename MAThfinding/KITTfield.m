%--------------------------------------------------------------------%
%--------------FIELD-------------------------------------------------%
%--------------------------------------------------------------------%
clf
%% TESTVALUES-------------------
xloc = 1;                   %-
yloc = 1;                   %-
angle = 0;                  %-
xmax = 5;
ymax = 5;
Yg =3;
Xg =3;
%% ------------DATA-----------------
angle = (angle/360)*2*pi;
r = 0.775;                    %turnradius in [m]
r2 = 0.25;                  %radius KITT [m]
rg = 0.1;                   %radius goal
KITTloc = [xloc, yloc];     %current location KITT
orient = angle;             %angle to positive x-axis

op(1) = r2*cos(angle);
op(2) = r2*(sin(angle));

%% boundaries
% prompt = 'maximum x = ';
% xmax = input(prompt);
% prompt = 'maximum y = ';
% ymax = input(prompt);

%% goal
% prompt = 'x location goal = ';
% Xg = input(prompt);
% prompt = 'y location goal = ';
% Yg = input(prompt);
circle(Xg,Yg,rg, 'b')
hold on

%% obstacle locations
prompt = 'nr. of obstacles = ';
n = input(prompt);
for i = 1:n;
    prompt = sprintf('x location obstacle %d = ',i);
    Xb(i) = input(prompt);
    prompt = sprintf('y location obstacle %d = ',i);
    Yb(i) = input(prompt);
    plot(Xb(i),Yb(i),'xk')
    circle(Xb(i),Yb(i),r2,'k')
    hold on
end

%% plots
plot(KITTloc(1),KITTloc(2), 'xr');
circle(KITTloc(1),KITTloc(2),r2,'r');
axis equal
grid on
ylim([0 ymax])
xlim([0 xmax])
hold on
quiver(xloc,yloc,op(1),op(2),0);