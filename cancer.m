global perimeter location field_data loc_index demo_record demo_drive Trec Tbeacon x_nav y_nav processing_timer Fs;

demo_record = true;
demo_drive = false;

%% Setup
JSON = fileread('field_K.json');
field_data = jsondecode(JSON);
clear JSON;

close all;

KITT = testClass;

if (~demo_drive)
    % Open port
    %KITT.openPort('COM3');

    % Setup the beacon
    load audiodata_96k2.mat;
    KITT.setupBeacon(Timer0, Timer1, Timer3, code);
end
if (~demo_record); initialise_audio_box(Fs, true); end

r1 = 0.1;
%p = gcp();

% Set start and end location
start_location = [1.52 -2.275];
start_angle = pi/2;
final_location = [-1.525 1.275];

% Plot the field
distance = zeros(1,5);
mic = 1:5;
nchan = 5;
playfield_plot(distance, mic, 100*start_location(1), 100*start_location(2), field_data);

perimeter = [field_data.field.x_min,field_data.field.x_max,field_data.field.y_min,field_data.field.y_max]/100;

% Do allocation for the location array
loc_index = 1;
location = zeros(1000, 2);
location(loc_index, :) = start_location;

idx_increment = 2;

status = struct('prev_instr_t', 0.0, 'rec_started_t', -1.0, 'beacon', false, 'record_index', 1, 'last_instruction', false);
processing_timer = struct('start', 0, 'end', 0, 'time', []);

%% Control loop

tic;
printImportantMessage('Starting control loop\n');

while true
	% Initial path
    [x_nav, y_nav, ang_nav, success] = main(location(loc_index, :), start_angle, final_location, perimeter);
    nav_steps = length(ang_nav);
    fprintf('@t = %.2f: Path found, proceding to controlling KITT\n', toc);
    
    plot_route(x_nav, y_nav, location(loc_index, :), final_location);

    % Find array of radii from angles given by the navigator
    radius_arr = 0.5 * r1 * tan(0.5 * (pi - ang_nav));
    % Filter out infinite measurements
    radius_arr(radius_arr > 1E6) = 0;
    Diameter = 2*radius_arr;
    
    printInstructionMessage('Set motorspeed to 23\n');
    if (~demo_drive)
        KITT.setMotorSpeed(23);
    end
    
    idx = 1;
    status.last_instruction = false;
    
    while true
        if (status.rec_started_t < 0)
            %printRecordMessage(sprintf('Start recording n. %d\n', status.record_index));
            status.record_index = status.record_index + 1;
            [page, Trec, Tbeacon] = start_cancer_recording(demo_record, KITT);
            status.rec_started_t = toc;
            %printBeaconMessage('Beacon turned on\n');
            status.beacon = true;
        end
        
        if (status.beacon && toc - status.rec_started_t > Tbeacon)
            %printBeaconMessage('Beacon turned off\n');
            status.beacon = false;
            if (~demo_drive)
                KITT.toggleBeacon(false);
            end
        end
        
        [status, new_data] = endOfRecord(page, nchan, status, idx);
        
        %{
        if (new_data)
            [estimation, theta] = last_location(location, loc_index, toc - processing_timer.end);
            %theta = (theta + ang_nav(idx)) / 2;
            [x_nav, y_nav, ang_nav, success] = main(estimation, theta, final_location, perimeter);
            idx = 1;
            
            % Find array of radii from angles given by the navigator
            radius_arr = 0.5 * r1 * tan(0.5 * (pi - ang_nav));
            % Filter out infinite measurements
            radius_arr(radius_arr > 1E6) = 0;
            Diameter = 2*radius_arr;
        end
        %}

        % Set the steering direction
        current_dia = Diameter(idx);
        [steer_param, t] = Diameter2SteerDirection(current_dia, idx);
        
        if (toc - status.prev_instr_t > idx_increment*t)
            printInstructionMessage(sprintf('Instruction %d\tCalculated diameter: %.2f m\tSteering param: %d\n', ...
                        idx, current_dia, round(steer_param)));
            if (~demo_drive)
                KITT.setSteerDirection(steer_param);
            end
            if (idx == nav_steps)
                if (status.last_instruction)
                    break;
                else
                    status.last_instruction = true;
                    idx_increment = 1;
                end
            else
                if (idx + 1 == nav_steps)
                    idx_increment = 1;
                else
                    idx_increment = 2;
                end
                idx = idx + idx_increment;
            end
            status.prev_instr_t = status.prev_instr_t + idx_increment*t;
        end
    end
    
    if (~demo_drive)
        KITT.setMotorSpeed(0); pause(0.3); KITT.setMotorSpeed(15);
    end
    
    while (status.rec_started_t >= 0)
        status = endOfRecord(page, nchan, status, idx);
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

        %%          Functions           %%

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

% Process record function
function [status, new_data] = endOfRecord(page, nchan, status, idx)

    global field_data location loc_index demo_record Trec x_nav y_nav processing_timer Fs;
    new_data = false;

    if (~demo_record)
        if((status.rec_started_t >= 0) && playrec('isFinished'))
            processing_timer.start = toc;
            printRecordMessage(sprintf('Processing recording n. %d\n', status.record_index-1));
            Hdist = process_cancer_recording(page, nchan, Fs);
            [x, y, z] =  tdoa2([field_data.mics.x; field_data.mics.y; field_data.mics.z]', Hdist, Fs);
            
            x = x/100;
            y = y/100;
            z = z/100;
            
            new_data = true;
        end
    else
        if ((status.rec_started_t >= 0) && (toc - status.rec_started_t > Trec))
            processing_timer.start = toc;
            x = x_nav(idx);
            y = y_nav(idx);
            z = 0;
            %pause(0.05);
            
            new_data = true;
        end
    end
    
    if (new_data)
        fprintf('@t = %.2f: Location should be x: %.2f\ty: %.2f\tz: %.2f meter\n', toc, x, y, z);

        loc_index = loc_index + 1;
        location(loc_index, :) = [x, y];
        status.rec_started_t = -1;
        processing_timer.end = toc;
        
        processing_timer.time(end+1) = processing_timer.end - processing_timer.start;
        
        %{
        hold on; p = plot(x, y, '.');
        p.LineWidth = 2;
        p.MarkerSize = 14;
        p.MarkerFaceColor = 'white'; 
        hold off;
        %}
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

function printInstructionMessage(message)
    cprintf('key', [timeString() message]);
end

function printImportantMessage(message)
    disp(' ');
    cprintf('*green', [timeString() message]);
end
