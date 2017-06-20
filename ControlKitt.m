
JSON = fileread('field_K.json');
field_data = jsondecode(JSON);
clear JSON;

% Open port
KITT = testClass;
KITT.openPort('COM3');

% Setup the beacon
load audiodata_96k2.mat;
KITT.setupBeacon(Timer0, Timer1, Timer3, code);

r1 = 0.1;
%p = gcp();

% Set start and end location
start_location = [-2 -2];
start_angle = pi/2;
final_location = [2 2];

% Plot the field
distance = zeros(1,5);
mic = 1:5;
playfield_plot(distance, mic, start_location(1), start_location(2), field_data);

perimeter = [field_data.field.x_min,field_data.field.x_max,field_data.field.y_min,field_data.field.y_max]/100;

% Do allocation for the location array
loc_index = 1;
location = zeros(1000, 2);
location(loc_index, :) = start_location;

while true
	% Initial path
    [x_nav, y_nav, ang_nav] = main(location(loc_index,1), location(loc_index,2), start_angle, final_location(1), final_location(2));

    %for idx = 1:(length(ang_nav)/2)
        %f = parfeval(p, @RecordLive, 2, false, 5, false); % Square size determined by idx
    %end
    % Collect the results as they become available.
    
    KITT.setMotorSpeed(22);
    for idx = 1:(length(ang_nav)/2)
        tic;
        % fetchNext blocks until next results are available.
        %[completedIdx,Hdist,Fs] = fetchOutputs(f);
        [Hdist,Fs] = RecordLive(true, 5, false);
        % When new location is available plot it
        if Hdist
            [x, y, z] =  tdoa2([field_data.mics.x; field_data.mics.y; field_data.mics.z ]', Hdist, Fs);
            location(loc_index, :) = [x*100, y*100];
            loc_index = loc_index + 1;
            hold on; p = plot(x, y, '.');
            p.LineWidth = 2;
            p.MarkerSize = 14;
            p.MarkerFaceColor = 'white'; 
            hold off;
            fprintf('Got result with index: %d.\n', completedIdx);
        end
        clear Hdist;

        radius_arr = 0.5 * r1 * tan(0.5 * (pi - ang_nav));
        % Filter out infinite measurements
        radius_arr(radius_arr > 1E6) = 0;
        Diameter = 2*radius_arr(1);

        % Set the steering direction
        [dia,t] = Diameter2SteerDirection(Diameter);
        while (toc < 2*t)
            KITT.setSteerDirection(dia);
        end
    end
    
    KITT.setMotorSpeed(15);
    % If within 30 cm of final location, break
    if abs(final_location - location(end,:)) < 0.3
        KITT.setMotorSpeed(0);pause(0.3);KITT.setMotorSpeed(15);
        fprintf('YEAH Arrived at the destination');
        break; 
    else
        fprintf('Almost there I have to retry');
    end
end
