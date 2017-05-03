%% Script settings
comport = '\\.\COM3';       % Name of the port to be opened
re_open_port = false;       % Close and open port
max_dist = 100;             % Distance to brake before the object
delay_time = 1.5e6          % Delay time in microseconds
doTurn = false;             % Start with the turn or not
EstimationThreshold = 300;  % cm

% Create instance of control class
KITT = testClass;

if (re_open_port)
    KITT.openPort(comport);
end

% Set audio beacon settings
KITT.setupBeacon(30000, 5000, 50, '983BD2C4');

KITT.getStatus();   % Get status from KITT
KITT.status         % Print status message

%% Turn
if (doTurn)
    KITT.setSteerDirection(0);
    KITT.setMotorSpeed(22);
    pause(1);
    KITT.setSteerDirection(-50);
    pause(1);
    KITT.setSteerDirection(50);
    pause(1.7);
    KITT.setSteerDirection(-50);
    pause(0.8);
    KITT.setSteerDirection(0);
    pause(1);
    KITT.setMotorSpeed(15);
else
    KITT.setMotorSpeed(25);
    KITT.setSteerDirection(0);
end

%% Structs for the position estimation
left = struct('d', 999, 'dOld', 999, 'dVirt', 0, 'v', double(0), 't', 0, 'tOld', 0, 'dt', double(0), 'dx', 0);
right = struct('d', 999, 'dOld', 999, 'dVirt', 0, 'v', double(0), 't', 0, 'tOld', 0, 'dt', double(0), 'dx', 0);

index = 1;
leftMeasurements = repmat(left, 1, 99);
rightMeasurements = repmat(right, 1, 99);


%% Brakingloop
while (true)
    % Get distance information from KITT
    KITT.getDistance();
    time = tic;
    left.d = KITT.leftDistance;
    right.d = KITT.rightDistance;
    
    % Ignore previous sensor values that are out of range to keep speed realistic
    if (left.dOld >= EstimationThreshold); left.dOld = left.d; end;
    if (right.dOld >= EstimationThreshold); right.dOld = right.d; end;
    
    % If we got new data, calculate new speed
    if (left.d ~= left.dOld)fit
        left = calcSpeed(left, time);
    % Else, interpolate position using previously calculated speed
    else
        left = calcVirtualPos(left, time);
    end
    
    % If we got new data, calculate new speed
    if (right.d ~= right.dOld)
        right = calcSpeed(right, time);
    else
    % Else, interpolate position using previously calculated speed
        right = calcVirtualPos(right, time);
    end
    
    % Store data in array
    leftMeasurements(index) = left;
    rightMeasurements(index) = right;
    
    % fitting
    if (index>samples)
        y = transpose([rightMeasurements(index-samples:index).d,leftMeasurements(N-10:N).d]);
        x = transpose(double([rightMeasurements(index-samples:index).t, leftMeasurements(index-samples:index).t] - rightMeasurements(1).t));
        f = fit(x,y,'poly1');
        z = (max_distance - f.p2) / f.p1; % time to collision
    end
    
    if (z > 0 && z < delay_time)
        break;        
    else
        % Print current status, such as position, speed, virt. pos, etc
        printStatus();
    end
    index = index + 1;
    old_left = left;
    old_right = right;
end

%% Brake!
KITT.setMotorSpeed(0);
pause(0.3);

%% Final measurement
KITT.getDistance();
printStatus();

% Wait and drive back
KITT.setMotorSpeed(15);
pause(2);
KITT.setMotorSpeed(8);
pause(2);

% Set motor to neutral
KITT.setMotorSpeed(15);

KITT.getDistance();
printStatus();

% Close port to free usage
% KITT.closePort();

%% Plot results
N = index - 1;
x = [leftMeasurements(1:N).d; rightMeasurements(1:N).d; leftMeasurements(1:N).dVirt; rightMeasurements(1:N).dVirt];
t = double([leftMeasurements.t] - leftMeasurements(1).t) * 10^-6 /2;
figure(1);
plot(t, x);
title('Time vs place plot');
xlabel('Time (s)');
ylabel('Distance from object (cm)');
legend('Left sensor', 'Right sensor', 'Virtual left distance', 'Virtual right distance');