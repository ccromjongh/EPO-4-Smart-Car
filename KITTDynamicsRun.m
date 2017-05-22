clf;
Vi=0;
Fin = 80;

mod = sim('KITTDynamicsFinal','SimulationMode','normal');  %start modulation
v = mod.get('vout');
assignin('base','v',v);

x = mod.get('xout');
assignin('base','x',x);

%plot
v1 = v.Data;
x1 = x.Data;
plot(x1,v1)
ylabel('Velocity (m/s)')
xlabel('Position (m)')
ylim([0,14]);
xlim([0,7]);
hold

%braking
Vi=60/3.6;  %starting velocity
Fin = -120;
dx = -8.7;  %offset

mod = sim('KITTDynamicsFinal','SimulationMode','normal');  %start modulation
v = mod.get('vout');
assignin('base','v',v);

x = mod.get('xout');
assignin('base','x',x);
%plot
v2 = v.Data;
x2 = x.Data + dx;
plot(x2,v2)

%calculate intersection (braking distance
[xs,vs]=polyxpoly(x1,v1,x2,v2);
xs