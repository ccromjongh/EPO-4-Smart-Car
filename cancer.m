global perimeter location loc_index demo_record demo_drive Trec Tbeacon x_nav y_nav;

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

idx_increment = 2;

status = struct('prev_instr_t', 0.0, 'rec_started_t', -1.0, 'beacon', false, 'record_index', 1, 'last_instruction', false);

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
    
    printInstructionMessage('Set motorspeed to 26\n');
    if (~demo_drive)
        KITT.setMotorSpeed(26);
    end
    
    idx = 1;
    status.last_instruction = false;
    
    while true
        if (status.rec_started_t < 0)
            printRecordMessage(sprintf('Start recording n. %d\n', status.record_index));
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
        
        status = endOfRecord(status, idx);

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
                    status.prev_instr_t = toc;
                end
            else
                status.prev_instr_t = toc;
                if (idx + 1 == nav_steps)
                    idx_increment = 1;
                else
                    idx_increment = 2;
                end
                idx = idx + idx_increment;
            end
        end
    end
    
    if (~demo_drive)
        KITT.setMotorSpeed(0); pause(0.3); KITT.setMotorSpeed(15);
    end
    
    while (status.rec_started_t >= 0)
        status = endOfRecord(status, idx);
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

function status = endOfRecord(status, idx)

global perimeter location loc_index demo_record Trec x_nav y_nav;

    if (~demo_record)
        if((status.rec_started_t >= 0) && playrec('isFinished'))
            printRecordMessage(sprintf('Processing recording n. %d\n', status.record_index-1));
            Hdist = process_cancer_recording(page, nchan);
            [x, y, z] =  tdoa2(100*perimeter', Hdist, Fs);
            fprintf('@t = %.2f: Location should be x: %.2f\ty: %.2f\tz: %.2f meter\n', toc, x, y, z);
            status.rec_started_t = -1;

            loc_index = loc_index + 1;
            location(loc_index, :) = [x, y];

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
        if ((status.rec_started_t >= 0) && (toc - status.rec_started_t > Trec))
            x = x_nav(idx);
            y = y_nav(idx);
            z = 0;

            loc_index = loc_index + 1;
            location(loc_index, :) = [x, y];
            fprintf('@t = %.2f: Location should be x: %.2f\ty: %.2f\tz: %.2f meter\n', toc, x, y, z);
            status.rec_started_t = -1;
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

function printInstructionMessage(message)
    cprintf('key', [timeString() message]);
end

function printImportantMessage(message)
    disp(' ');
    cprintf('*green', [timeString() message]);
end