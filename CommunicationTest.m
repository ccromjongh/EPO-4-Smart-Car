clear variables;
%% Script settings
comport = '\\.\COM9';       % Name of the port to be opened
re_open_port = false;       % Close and open port
max_distance = 70;          % Distance to brake before the object
delay_time = 0.7;        % Delay time in seconds
doTurn = false;             % Start with the turn or not
EstimationThreshold = 400;  % cm
samples = 5;    

% Create instance of control class
KITT = testClass;

if (re_open_port)
    KITT.openPort(comport);
end

% Set audio beacon settings
KITT.setupBeacon(30000, 5000, 50, '983BD2C4');

KITT.getStatus();   % Get status from KITT
KITT.status         % Print status message



%% Structs for the position estimation
left = struct('d', 999, 't', 0);
right = struct('d', 999, 't', 0);

index = 1;
leftMeasurements = repmat(left, 1, 9999);
rightMeasurements = repmat(right, 1, 9999);


%% Turn
if (doTurn)
    KITT.setSteerDirection(0);
    KITT.setMotorSpeed(26);
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
    KITT.setMotorSpeed(30);
    KITT.setSteerDirection(4);
end



tic
%% Brakingloop
while (true)
    % Get distance information from KITT
    KITT.getDistance();
    
    left.d = KITT.leftDistance;
    left.t = toc;
    right.d = KITT.rightDistance;
    right.t = toc;
    
    % Ignore previous sensor values that are out of range to keep speed realistic
    if (left.d >= EstimationThreshold)
        if (exist('old_left', 'var'))
            left.d = old_left.d;
        else
            continue
        end
    end;
    if (right.d >= EstimationThreshold)
        if (exist('old_right', 'var'))
            right.d = old_right.d;
        else
            continue
        end
    end
    
    
    
    
%     % If we got new data, calculate new speed
%     if (left.d ~= left.dOld)
%         left = calcSpeed(left, time);
%     % Else, interpolate position using previously calculated speed
%     else
%         left = calcVirtualPos(left, time);
%     end
%     
%     % If we got new data, calculate new speed
%     if (right.d ~= right.dOld)
%         right = calcSpeed(right, time);
%     else
%     % Else, interpolate position using previously calculated speed
%         right = calcVirtualPos(right, time);
%     end
    


    % Store data in array
    leftMeasurements(index) = left;
    rightMeasurements(index) = right;
    
    % fitting
    
    if (index>samples)
        dr = transpose([rightMeasurements(index-samples:index).d]);
        dl = transpose([leftMeasurements(index-samples:index).d]);
        tr = transpose(double([rightMeasurements(index-samples:index).t]));
        tl = transpose(double([leftMeasurements(index-samples:index).t]));
        fr = fit(tr,dr,'poly1');
        if (fr.p1<0)
            zr = ((max_distance - fr.p2) / fr.p1) - tr(end); % time to collision
        else 
            zr = 0;
        end
        fl = fit(tl,dl,'poly1');
        if (fl.p1<0)
            zl = ((max_distance - fl.p2) / fl.p1) - tl(end); % time to collision
        else
            zl = 0;
        end
    else
        zr = 0;
        zl = 0;
    end
    
    if ((zr > 0 && zr < delay_time) || (zl > 0 && zl < delay_time))
        break;        
    else
        % Print current status, such as position, speed, virt. pos, etc
        %printStatus(left, right);
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
%printStatus(left,right);


% Set motor to neutral
KITT.setMotorSpeed(15);

KITT.getDistance();
%printStatus(left,right);

% Close port to free usage
% KITT.closePort();

%% Plot results
N = index - 1;
x = [leftMeasurements(1:N).d; rightMeasurements(1:N).d];
y = double([leftMeasurements(1:N).t]);
figure(1);
plot(y, x);
title('Time vs place plot');
xlabel('Time (s)');
ylabel('Distance from object (cm)');
legend('Left sensor', 'Right sensor');

figure(2);
subplot(2,1,1);
plot(fl,tl,dl);
title('Left Sensor Fitting');
xlabel('Time (s)');
ylabel('Distance from object (cm)');
subplot(2,1,2);
plot(fr,tr,dr);
title('Right Sensor Fitting');
xlabel('Time (s)');
ylabel('Distance from object (cm)');