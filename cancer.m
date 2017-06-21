global perimeter location loc_index demo_record demo_drive;

demo_record = true;
demo_drive = true;

%% Setup
JSON = fileread('field_K.json');
field_data = jsondecode(JSON);
clear JSON;

close all;

KITT = testClass;

if (~demo_drive)
    % Open port
    KITT.openPort('COM3');

    % Setup the beacon
    load audiodata_96k2.mat;
    KITT.setupBeacon(Timer0, Timer1, Timer3, code);
end
if (~demo_record); initialise_audio_box(Fs, true); end

r1 = 0.1;
%p = gcp();

% Set start and end location
start_location = [2 -1];
start_angle = -pi/2;
final_location = [-2 2];

% Plot the field
distance = zeros(1,5);
mic = 1:5;
playfield_plot(distance, mic, 100*start_location(1), 100*start_location(2), field_data);

perimeter = [field_data.field.x_min,field_data.field.x_max,field_data.field.y_min,field_data.field.y_max]/100;

% Do allocation for the location array
loc_index = 1;
location = zeros(1000, 2);
location(loc_index, :) = start_location;
record_started = false;
record_index = 1;

prev_instruction = 0;
start_rec = 0;
beacon_on = false;
last_instruction = false;

%% Control loop

fprintf('@t = 0.00: Starting control loop\n');
tic;

while true
	% Initial path
    [x_nav, y_nav, ang_nav, success] = main(location(loc_index, :), start_angle, final_location, perimeter);
    nav_steps = ceil(length(ang_nav)/2);
    fprintf('@t = %.2f: Path found, proceding to controlling KITT\n', toc);
    
    plot_route(x_nav, y_nav, location(loc_index, :), final_location);

    % Find array of radii from angles given by the navigator
    radius_arr = 0.5 * r1 * tan(0.5 * (pi - ang_nav));
    % Filter out infinite measurements
    radius_arr(radius_arr > 1E6) = 0;
    Diameter = 2*radius_arr;
    
    fprintf('@t = %.2f: Set motorspeed to 26\n', toc);
    if (~demo_drive)
        KITT.setMotorSpeed(26);
    end
    
    idx = 1;
    last_instruction = false;
    
    while true
        if (~record_started)
            printRecordMessage(sprintf('@t = %.2f: Start recording n. %d\n', toc, record_index));
            record_index = record_index + 1;
            [page, Trec, Tbeacon] = start_cancer_recording(demo_record, KITT);
            start_rec = toc;
            printBeaconMessage('Beacon turned on\n');
            record_started = true;
            beacon_on = true;
        end
        
        if (beacon_on && toc - start_rec > Tbeacon)
            printBeaconMessage('Beacon turned off\n');
            beacon_on = false;
            if (~demo_drive)
                KITT.toggleBeacon(false);
            end
        end
        
        record_started = endOfRecord(record_started);

        % Set the steering direction
        current_dia = Diameter(2*idx - 1);
        [steer_param, t] = Diameter2SteerDirection(current_dia, idx);
        
        if (toc - prev_instruction > 2*t)
            fprintf('@t = %.2f: Calculated a diameter of %.2f m and a steering param of %d\n', ...
                        toc, current_dia, round(steer_param));
            if (~demo_drive)
                KITT.setSteerDirection(steer_param);
            end
            if (idx == nav_steps)
                if (last_instruction)
                    break;
                else
                    last_instruction = true;
                    prev_instruction = toc;
                end
            else
                prev_instruction = toc;
                idx = idx + 1;
            end
        end
    end
    
    if (~demo_drive)
        KITT.setMotorSpeed(0); pause(0.3); KITT.setMotorSpeed(15);
    end
    
    while (record_started)
        record_started = endOfRecord(record_started);
    end
    
    % If within 30 cm of final location, break & brake
    final_radius = coord_radius(final_location, location(loc_index,:));
    printImportantMessage(sprintf('Final radius is %.2f\n', final_radius));
    if (final_radius < 0.3)
        if (~demo_drive)
            KITT.setMotorSpeed(15);
        end
        fprintf('YEAH Arrived at the destination\n\n');
        break; 
    else
        fprintf('Almost there I have to retry\n\n');
    end
end

if (~demo_drive)
   KITT.closePort(); 
end

function rad = coord_radius (arr1, arr2)
    x = arr1(1) - arr2(1);
    y = arr1(2) - arr2(2);
    rad = sqrt(x^2 + y^2);
    
end

function plot_route(x_nav, y_nav, start_location, final_location)
    global perimeter;
    
    figure();
    hold off;
    plot(x_nav, y_nav);
    hold on;
    
    p = plot(start_location(1), start_location(2), 'x');
    p.LineWidth = 1.5;
    p.MarkerSize = 8;
    
    p = plot(final_location(1), final_location(2), 'o');
    p.LineWidth = 1.5;
    p.MarkerSize = 8;
    
    axis(perimeter); pbaspect([1 1 1]);
    title('KITT navigation using vertex pathfinding');
    xlabel('X axis (m)');
    ylabel('Y axis (m)');
end

function [record_started] = endOfRecord(record_started)

global perimeter location loc_index demo_record;

    if (~demo_record)
        if(record_started && playrec('isFinished'))
            printRecordMessage(sprintf('Processing recording n. %d\n', record_index-1));
            Hdist = process_cancer_recording(page, nchan);
            [x, y, z] =  tdoa2(100*perimeter', Hdist, Fs);
            fprintf('@t = %.2f: Location should be x: %.2f\ty: %.2f\tz: %.2f meter\n', toc, x, y, z);
            record_started = false;

            location(loc_index, :) = [x, y];
            loc_index = loc_index + 1;

            %{
            hold on; p = plot(x, y, '.');
            p.LineWidth = 2;
            p.MarkerSize = 14;
            p.MarkerFaceColor = 'white'; 
            hold off;
            %}
            %fprintf('Got result with index: %d.\n', completedIdx);
        end
    else
        if (record_started && toc - start_rec > Trec)
            x = x_nav(idx*2-1);
            y = y_nav(idx*2-1);
            z = 0;

            location(loc_index, :) = [x, y];
            loc_index = loc_index + 1;
            fprintf('@t = %.2f: Location should be x: %.2f\ty: %.2f\tz: %.2f meter\n', toc, x, y, z);
            record_started = false;
            pause(0.1);
        end
    end
end

function string = timeString()
    string = sprintf('@t = %.2f: ', toc);
end

function printBeaconMessage(message)
    cprintf('yellow', [timeString() message]);
end

function printRecordMessage(message)
    cprintf('red', [timeString() message]);
end

function printImportantMessage(message)
    disp(' ');
    cprintf('*green', [timeString() message]);
end