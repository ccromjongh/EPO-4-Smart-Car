%% Script settings
comport = '\\.\COM5';       % Name of the port to be opened
re_open_port = false;       % Close and open port
max_dist = 120;             % Distance to brake before the object
doTurn = false;             % Start with the turn or not
EstimationThreshold = 200;  % cm

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
    tic;
    KITT.setMotorSpeed(30);
    KITT.setSteerDirection(2);
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
    if (left.dOld >= 600); left.dOld = left.d; end;
    if (right.dOld >= 600); right.dOld = right.d; end;
    
    % If we got new data, calculate new speed
    if (left.d ~= left.dOld)
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
    
    % If we did not yet reach the wall
    if (left.dVirt > max_dist && right.dVirt > max_dist)
        % Print current status, such as position, speed, virt. pos, etc
        printStatus(left, right);
        
        % Store data in array
        leftMeasurements(index) = left;
        rightMeasurements(index) = right;
        index = index + 1;
    % If we DID reach the wall, break out of loop an stop the car
    else
        break;
    end
    
    old_left = left;
    old_right = right;
end


%% Brake!
timer = toc;
KITT.setMotorSpeed(0);
pause(0.3);

%% Final measurement
KITT.getDistance();
printStatus(left, right);

% Wait and drive back
KITT.setMotorSpeed(15);
pause(2);
%KITT.setMotorSpeed(8);
%pause(2);

% Set motor to neutral
KITT.setMotorSpeed(15);

KITT.getDistance();
printStatus(left, right);

% Close port to free usage
% KITT.closePort();

%% Plot results
N = index - 1;
x = [leftMeasurements(1:N).d; rightMeasurements(1:N).d; leftMeasurements(1:N).dVirt; rightMeasurements(1:N).dVirt];
t = double([leftMeasurements.t] - leftMeasurements(1).t) * 10^-6;
t = t(1:N)./2;

figure(1);
plot(t, x);
ylim([0, 350]);
title('Time vs place plot');
xlabel('Time (s)');
ylabel('Distance from object (cm)');
legend('Left sensor', 'Right sensor', 'Virtual left distance', 'Virtual right distance');
