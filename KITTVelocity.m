function [vdat,xdat] = KITTVelocity()

mod = sim('KITTRacing','SimulationMode','normal');  %start modulation
    
%retreive velocity, acceleration and position
v = mod.get('vout');
assignin('base','v',v);
ylabel('Velocity (m/s)')

% a = mod.get('aout');
% assignin('base','a',a);
% ylabel('Acceleration (m/s^2)')

x = mod.get('xout');
assignin('base','x',x);
ylabel('Position (m)')

%assign data
xdat = x.Data; %-dx
vdat = v.Data;
end