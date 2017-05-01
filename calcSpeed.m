function obj = calcSpeed (obj, time)
    obj.dt = double(obj.t - obj.tOld)*10^(-6);  % Calculate dt
    obj.tOld = time;                            % Set t-old to t-new
    obj.t = time;                               % Set current time
    obj.dx = obj.d - obj.dOld;                  % Measure dx
    obj.dOld = obj.d;                           % Set old distance
    obj.dVirt = obj.d;                          % Virtual distance eq. to real distance
    obj.v = double(obj.dx) / obj.dt;            % Calculate speed
    if (abs(obj.v) > 300); obj.v = 0; end;      % Include guard to ignore unrealistic values
end