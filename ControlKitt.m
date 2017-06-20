
JSON = fileread('field_K.json');
field_data = jsondecode(JSON);
clear JSON;

% Open port
KITT = testClass;
% KITT.openPort('//./COM12');

% Setup the beacon
load audiodata_96k.mat;
KITT.setupBeacon(Timer0, Timer1, Timer3, code);

r1 = 0.1;
p = gcp();

% Set start and end location
start_location = [-2 -2];
start_angle = pi/2;
final_location = [2 2];

% Plot the field
distance = zeros(1,5);
mic = 1:5;
playfield_plot(distance, mic, start_location(1), start_location(2), field_data);

location = start_location;

while true
    %Initial path
    location = start_location;
    [x_nav, y_nav, ang_nav] = main(location(end,:), start_angle, final_location, [field_data.field.x_min,field_data.field.x_max,field_data.field.y_min,field_data.field.y_max]/100);

    for idx = 1:(length(ang_nav)/2)
      f(idx) = parfeval(p,@RecordLive,2,true,5,false); % Square size determined by idx
    end
    % Collect the results as they become available.
    magicResults = cell(1,length(ang_nav));
    KITT.setMotorSpeed(26);
    for idx = 1:(length(ang_nav)/2)
      tic;
      % fetchNext blocks until next results are available.
      [completedIdx,Hdist,Fs] = fetchNext(f,0.1);
      % When new location is available plot it
      if Hdist
          [x, y, z] =  tdoa2([field_data.mics.x; field_data.mics.y; field_data.mics.z ]', Hdist, Fs);
          location = [location; x*100, y*100];
          hold on; p = plot(x, y, '.');
          p.LineWidth = 2;
          p.MarkerSize = 14;
          p.MarkerFaceColor = 'white'; 
          hold off;
          fprintf('Got result with index: %d.\n', completedIdx);
      end
      clear Hdist;
      
      % Filter out infinite measurements
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
