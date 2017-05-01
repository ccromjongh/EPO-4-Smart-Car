function obj = calcVirtualPos (obj, time)
    obj.t = time;                               % Set current time
    obj.dt = double(obj.t - obj.tOld)*10^(-6);	% Calculate dt
    obj.dVirt = obj.d + obj.v * obj.dt;         % Calculae virtual distance (speed * dt)
end