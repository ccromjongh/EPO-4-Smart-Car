global train perimeter location field_data loc_index demo_record demo_drive Trec Tbeacon x_nav y_nav processing_timer Fs log_file;

demo_record = true;
demo_drive = true;

%% Setup
JSON = fileread('field_K.json');
field_data = jsondecode(JSON);
clear JSON;

load 'train'
train = audioplayer(y,Fs);

%delete('log.txt');
log_file = fopen('log.txt', 'w');

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

r1 = 0.2;   % Vertex length
%p = gcp();  % Parrallel pool

% Set start and end location
start_location = [1.52 -2.275];
start_angle = pi/2;
extra_location = [];
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

status = struct('prev_instr_t', 0.0, 'rec_started_t', -1.0, 'beacon', false, 'record_index', 1, 'last_instruction', false);
processing_timer = struct('start', 0, 'end', 0, 'time', []);
instruction_timer = [];
re_path = struct('rec_started_t', 0.0, 'prev_rec_t', 0.0, 'prev_location', start_location, 'current_location', start_location, 'offset', 0, 'reset_timer', false);

%% Control loop

tic;
printImportantMessage('Starting control loop\n', log_file);

while true
    if extra_location
        end_location = extra_location;
    else
        end_location = final_location;
    end
	% Initial path
   [x_nav, y_nav, ang_nav, success, abs_ang_nav] = main(location(loc_index, :), start_angle, end_location, perimeter);
    nav_steps = length(ang_nav);
    printLogMessage('Path found, proceding to controlling KITT\n', log_file);
    
    plot_route(x_nav, y_nav, location(loc_index, :), end_location);

    % Find array of radii from angles given by the navigator
    radius_arr = 0.5 * r1 * tan(0.5 * (pi - ang_nav));
    % Filter out infinite measurements
    radius_arr(radius_arr > 1E6) = 0;
    Diameter = 2*radius_arr;
    
    printInstructionMessage('Set motorspeed to 23\n', log_file);
    if (~demo_drive)
        KITT.setMotorSpeed(23);
    end
    
    idx = 1;
    status.last_instruction = false;
    re_path.offset = 0;
    
    while true
        if (status.rec_started_t < 0)
            printRecordMessage(sprintf('Start recording n. %d\n', status.record_index), log_file, true);
            status.record_index = status.record_index + 1;
            [page, Trec, Tbeacon] = start_cancer_recording(demo_record, KITT);
            status.rec_started_t = toc;
            %printBeaconMessage('Beacon turned on\n', log_file);
            status.beacon = true;
            
            if (re_path.prev_rec_t == 0); re_path.prev_rec_t = toc; end
            re_path.rec_started_t = status.rec_started_t;
        end
        
        if (status.beacon && toc - status.rec_started_t > Tbeacon)
            %printBeaconMessage('Beacon turned off\n', log_file);
            status.beacon = false;
            if (~demo_drive)
                KITT.toggleBeacon(false);
            end
        end
        
        [status, new_data] = endOfRecord(page, nchan, status, idx);
        
        %
        if (new_data)
            % Only when location is valid, and not too close to the endpoint
            if ((coord_radius(location(loc_index, :), [x_nav(idx), y_nav(idx)]) < 0.5) && ...
                (coord_radius(final_location, location(loc_index,:)) > 0.4) && (re_path.prev_rec_t > 0))
            
                re_path.prev_rec_t = re_path.rec_started_t;
                re_path.prev_location = re_path.current_location;
                
                re_path.rec_started_t = status.rec_started_t;
                re_path.current_location(:) = location(loc_index,:);
                
                td = toc + 0.5*Tbeacon - re_path.prev_rec_t;
                [estimation, theta] = last_location(re_path.current_location, re_path.prev_location, td);
                theta = (theta + abs_ang_nav(idx)) / 2;
                
                printLogMessage(sprintf('\nEstimation: [%.2f, %.2f]; theta = %.3f\n', estimation(1), estimation(2), theta), ...
                    log_file);
                
                [x_nav_new, y_nav_new, ang_nav_new, success, abs_ang_nav_new] = main(estimation, theta, final_location, perimeter);
                
                % Only use new route if it actually worked
                if (success)
                    printLogMessage('\nSuccesfully corrected the path\n', log_file);
                    plot_route(x_nav, y_nav, location(loc_index, :), final_location);
                    
                    x_nav = x_nav_new;
                    y_nav = y_nav_new;
                    ang_nav = ang_nav_new;
                    abs_ang_nav = abs_ang_nav_new;
                    clear x_nav_new y_nav_new ang_nav_new abs_ang_nav_new;
                    
                    re_path.offset = re_path.offset + idx - 1;
                    idx = 1;

                    % Find array of radii from angles given by the navigator
                    radius_arr = 0.5 * r1 * tan(0.5 * (pi - ang_nav));
                    % Filter out infinite measurements
                    radius_arr(radius_arr > 1E6) = 0;
                    Diameter = 2*radius_arr;
                    
                    nav_steps = length(ang_nav);
                    
                    % Make sure that instructions will be executed correctly
                    re_path.reset_timer = true;
                    status.prev_instr_t = toc;
                end
            else
                useless = true;
                clear useless;
            end
            
        end
        %}

        % Set the steering direction
        current_dia = Diameter(idx);
        [steer_param, t] = Diameter2SteerDirection(current_dia, idx + re_path.offset);
        
        if ((toc - status.prev_instr_t > t) || re_path.reset_timer)
            printInstructionMessage(sprintf('Instruction %d\tCalculated diameter: %.2f m\tSteering param: %d\n', ...
                        idx, current_dia, round(steer_param)), log_file);
            
            re_path.reset_timer = false;
            
            if (~demo_drive)
                KITT.setSteerDirection(steer_param);
            end
            
            instruction_timer(end+1) = toc; %#ok<SAGROW>
            
            if (idx == nav_steps)
                if (status.last_instruction)
                    break;
                else
                    status.last_instruction = true;
                end
            else
                idx = idx + 1;
            end
            status.prev_instr_t = status.prev_instr_t + t;
        end
    end
    
    if (~demo_drive)
        KITT.setMotorSpeed(0); pause(0.3); KITT.setMotorSpeed(15);
    end
    
    while (status.rec_started_t >= 0)
        [status, new_data] = endOfRecord(page, nchan, status, idx);
    end
    
    % If within 30 cm of final location, break & brake
    final_radius = coord_radius(end_location, location(loc_index,:));
    printImportantMessage(sprintf('Final radius is %.2f\n', final_radius), log_file);
    if (final_radius < 0.3)
        if (~demo_drive)
            KITT.setMotorSpeed(15);
        end
        printLogMessage('YEAH Arrived at the destination\n\n', log_file);
        play(train);
        pause(5);
        if extra_location
            end_location = final_location; 
            extra_location = [];
        else
           break; 
        end
    else
        printLogMessage('Almost there I have to retry\n\n', log_file);
    end
end

if (~demo_drive)
   KITT.closePort(); 
end

fclose(log_file);



        %%          Functions           %%

function rad = coord_radius (arr1, arr2)
    rad = sqrt(sum((arr1 - arr2).^2));
end

function plot_route(x_nav, y_nav, start_location, end_location)
    global perimeter;
    
    figure();
    hold off;
    plot(x_nav, y_nav);
    hold on;
    
    p = plot(start_location(1), start_location(2), 'x');
    p.LineWidth = 1.5;
    p.MarkerSize = 8;
    
    p = plot(end_location(1), end_location(2), 'o');
    p.LineWidth = 1.5;
    p.MarkerSize = 8;
    
    axis(perimeter); pbaspect([1 1 1]);
    title('KITT navigation using vertex pathfinding');
    xlabel('X axis (m)');
    ylabel('Y axis (m)');
end

% Process record function
function [status, new_data] = endOfRecord(page, nchan, status, idx)

    global field_data location loc_index demo_record Trec x_nav y_nav processing_timer Fs log_file;
    new_data = false;

    if (~demo_record)
        if((status.rec_started_t >= 0) && playrec('isFinished'))
            processing_timer.start = toc;
            printRecordMessage(sprintf('Processing recording n. %d\n', status.record_index-1), log_file, true);
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
        printLogMessage(sprintf('Location should be x: %.2f\ty: %.2f\tz: %.2f meter\n', x, y, z), log_file);

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

function printBeaconMessage(message, log_file)
    cprintf('yellow', [timeString() message]);
    fprintf(log_file, [timeString() message]);
end

function printRecordMessage(message, log_file, to_terminal)
    if (nargin <3); to_terminal = true; end
    if (to_terminal)
        cprintf('red', [timeString() message]);
    end
    fprintf(log_file, [timeString() message]);
end

function printInstructionMessage(message, log_file)
    cprintf('key', [timeString() message]);
    fprintf(log_file, [timeString() message]);
end

function printImportantMessage(message, log_file)
    cprintf('*green', ['\n' timeString() message]);
    fprintf(log_file, ['\n' timeString() message]);
end

function printLogMessage(message, log_file)
    fprintf([timeString() message]);
    fprintf(log_file, [timeString() message]);
end
