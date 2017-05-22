clear variables;
%% Script settings
comport = '\\.\COM3';       % Name of the port to be opened
re_open_port = true;       % Close and open port
max_distance = 39;          % Distance to brake before the object
roll_distance = 70;
delay_time = 0.5;           % Delay time in seconds
EstimationThreshold = 400;  % cm
minimumSamples = 5;  
maximumSamples = 10;
fakeSamplesRemaining = minimumSamples;

% Create instance of control class
KITT = testClass;
rolling = false;

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

% Set speed and steering direction
KITT.setMotorSpeed(27);
KITT.setSteerDirection(6);


%% Fake measurement injection
KITT.getDistance();
leftTemp = KITT.leftDistance;
rightTemp = KITT.rightDistance;

% create some measurements to start approximating
for j = 1:minimumSamples
    leftMeasurements(index) = struct('d', leftTemp, 't', -j*0.1);
    leftMeasurements(index) = struct('d', rightTemp, 't', -j*0.1);
    index = index + 1;
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
    disp(['time is ' num2str(toc)]);
    
    % Ignore previous sensor values that are out of range to keep speed realistic
    if (left.d >= EstimationThreshold)
        if (exist('old_left', 'var'))
            left.d = old_left.d;
        else
            continue
        end
    end
    if (right.d >= EstimationThreshold)
        if (exist('old_right', 'var'))
            right.d = old_right.d;
        else
            continue
        end
    end
    


    % Store data in array
    leftMeasurements(index) = left;
    rightMeasurements(index) = right;
    
    % If we still got fake measurements, remove them
    if (fakeSamplesRemaining >= 1)
        disp(['Fakesamples = ' num2str(fakeSamplesRemaining)]);
        % Remove fake measurement
        leftMeasurements = leftMeasurements(2:end);
        rightMeasurements = rightMeasurements(2:end);
        
        % Update indices accordingly
        fakeSamplesRemaining = fakeSamplesRemaining - 1;
        index = index - 1;
    end
    
    % fitting
    
    if (index > minimumSamples)
        startIndex = index - maximumSamples;
        % If the start index is smaller than 1, set it to the first element
        if (startIndex < 1)
            startIndex = 1;
        end
        % We needn't take more samples than the maximum
        if (startIndex > maximumSamples)
            startIndex = maximumSamples;
        end
        
        dR = transpose([rightMeasurements(startIndex:index).d]);
        dL = transpose([leftMeasurements(startIndex:index).d]);
        tR = transpose(double([rightMeasurements(startIndex:index).t]));
        tL = transpose(double([leftMeasurements(startIndex:index).t]));
        
        zr = 0; zl = 0;
        
        %% Right Fitting
        
        [zr, fR] = fitFunction(tR, dR, max_distance);
        
        %% Left fitting
        
        [zl, fL] = fitFunction(tL, dL, max_distance);
        
        %% Roll out if closer than roll_distance
        if (~rolling && (polyval(fR, tR(end) + delay_time) < roll_distance || polyval(fL, tL(end) + delay_time) < roll_distance))
            KITT.setMotorSpeed(15);
            rolling = true;
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
brakeTime = toc;
KITT.setMotorSpeed(0);
pause(0.25);

%% Final measurement
endTime = toc;
KITT.getDistance();
%printStatus(left,right);


% Set motor to neutral
KITT.setMotorSpeed(15);

pause(0.25);

KITT.getDistance();
fprintf('\nFinal distance: L %d cm, R %d cm\nBrake time was %.2f s, final time %.2f s\n', KITT.leftDistance, KITT.rightDistance, brakeTime, endTime);

% Close port to free usage
KITT.closePort();

%% Plot results
tRAll = double([rightMeasurements(1:index).t]);
tLAll = double([leftMeasurements(1:index).t]);
dRAll = [rightMeasurements(1:index).d];
dLAll = [leftMeasurements(1:index).d];

N = index - 1;
x = [dLAll; dRAll];
y = double(tLAll);
figure(1);
plot(y, x);
ylim([0 400]);
title('Time vs place plot');
xlabel('Time (s)');
ylabel('Distance from object (cm)');
legend('Left sensor', 'Right sensor');

timeMin = min(tL(1), tR(1));
timeMax = min(tL(end), tR(end));
tFit = timeMin:0.05:timeMax;
fitR = polyval(fR, tFit);
fitL = polyval(fL, tFit);
velociR = polyval(polyder(fR), tFit);
velociL = polyval(polyder(fL), tFit);

figure(2);
subplot(2, 1, 1);
plot(tFit, fitL, tL, dL, 'X', tLAll, dLAll);
ylim([0 400]);
title('Left Sensor Fitting');
xlabel('Time (s)');
ylabel('Distance from object (cm)');

subplot(2, 1, 2);
plot(tFit, fitR, tR, dR, 'X', tRAll, dRAll);
ylim([0 400]);
title('Right Sensor Fitting');
xlabel('Time (s)');
ylabel('Distance from object (cm)');

figure(3);
subplot(2, 1, 1);
plot(tFit, velociL);
ylim([-160 0]);
title('Left Sensor Speed');
xlabel('Time (s)');
ylabel('Speed (cm/s)');
subplot(2,1,2);
plot(tFit, velociR);
ylim([-160 0]);
title('Right Sensor Speed');
xlabel('Time (s)');
ylabel('Speed (cm/s)');