clear variables;
%% Script settings
comport = '\\.\COM3';       % Name of the port to be opened
re_open_port = true;       % Close and open port
max_distance = 40;          % Distance to brake before the object
delay_time = 0.5;           % Delay time in seconds
EstimationThreshold = 400;  % cm
minimumSamples = 5;  
maximumSamples = 10;
fakeSamplesRemaining = minimumSamples;

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

% Set speed and steering direction
KITT.setMotorSpeed(30);
KITT.setSteerDirection(4);


%% Fake measurement injection
KITT.getDistance();
leftTemp = KITT.leftDistance;
rightTemp = KITT.rightDistance;

% create some measurements to start approximating
for j = 1:minimumSamples
    leftMeasurements(index) = struct('d', leftTemp, 't', -j*0.1);
    leftMeasurements(index) = struct('d', rightTemp, 't', -j*0.1);
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
        
        %% Right Fitting
        
        %fR = fit(tR,dR,'poly2', 'Robust', 'Bisquare');
        fR = polyfit(tR, dR, 2);
        derivR = polyder(fR);
        totalDistance = max_distance + polyval(derivR, tR(end))^2/500;
        
        %fR.p1 = fR.p1 - totalDistance;
        fR(end) = fR(end) - totalDistance;
        rootsR = roots(fR);
        % Only take real values
        rootsR = rootsR(real(rootsR)>0&imag(rootsR)==0);
        
        if (~isempty(rootsR) && rootsR(2) > 0.5)
            zr = rootsR(2) - tR(end);
        else 
            zr = 0;
        end
        
        %% Left fitting
        
        %fL = fit(tL,dL,'poly2', 'Robust', 'Bisquare');
        fL = polyfit(tL, dL, 2);
        derivL = polyder(fL);
        totalDistance = max_distance + polyval(derivL, tL(end)^2/500);
        
        %fL.p1 = fL.p1 - totalDistance;
        fL(end) = fL(end) - totalDistance;
        rootsL = roots(fL);
        % Only take real values
        rootsL = rootsL(real(rootsL)>0&imag(rootsL)==0);
        
        if (~isempty(rootsL) && rootsL(2) > 0.5)
            zr = rootsR(2) - tR(end);
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

%KITT.getDistance();
%printStatus(left,right);

% Close port to free usage
KITT.closePort();

%% Plot results
N = index - 1;
x = [leftMeasurements(1:N).d; rightMeasurements(1:N).d];
y = double([leftMeasurements(1:N).t]);
figure(1);
plot(y, x);
ylim([0 400]);
title('Time vs place plot');
xlabel('Time (s)');
ylabel('Distance from object (cm)');
legend('Left sensor', 'Right sensor');

figure(2);
subplot(2,1,1);
plot(fL,tL,dL);
title('Left Sensor Fitting');
xlabel('Time (s)');
ylabel('Distance from object (cm)');
subplot(2,1,2);
plot(fR,tR,dR);
title('Right Sensor Fitting');
xlabel('Time (s)');
ylabel('Distance from object (cm)');