function [Hdist, Fs] = RecordLive(demo_mode, nchan, plot_data)

if (nargin < 2)
   nchan = 5;
elseif (nargin < 3)
   plot_data = false;
end

KITT = testClass;

% To suppress MATLAB's itching
Nrp = 4; Fs = 96000;
load audiodata_96k.mat;
Nrp = Nrp - 1;
latency = 0.03;

Trec = Nrp/Timer3 + 0.1;                % Record data segment length
Tbeacon = (Nrp - 0.2)/Timer3;           % Time the beacon should stay on
sampleCount = floor(Trec*Fs);           % The number of samples of the recorded data (one data segment)

%% Initialise and start recording

if (~demo_mode)
    initialise_audio_box(Fs, true);

    % Set up beacon
    KITT.toggleBeacon(false);
    pause(0.1);
    KITT.setupBeacon(Timer0, Timer1, Timer3, code);

    pause(0.1);

    page = start_record(Fs, sampleCount);

    tic;
    % Turn on beacon
    KITT.toggleBeacon(true);

    % Wait till recording is done 
    while(~playrec('isFinished'))
        % Toggle beacon off when it has completed it's N cycles
        if (toc > Tbeacon)
           KITT.toggleBeacon(false); 
        end
        % Pause 5 milliseconds just because
        pause(0.005);
    end

    if (toc > Tbeacon)
       KITT.toggleBeacon(false); 
    end

    % Get data
    recorded = get_record(page);
    
    throwaway = round(latency*Fs);
    y = recorded(throwaway:end, :);
    clear recorded;
    
    % Save recording for later use in demo_mode
    save('Recordings/last_TDOA_rec.mat', 'y');
else
    load('Recordings/last_TDOA_rec.mat');
end

y_max = max(abs(y));
for i = 1:nchan
    % Normalize vector
    y(:, i) = y(:, i)/y_max(i);


    eps = 0.2;
    ii = abs(y(:, i)) <= eps;
    y(ii, i) = 0;
end

%% Find channel estimations

for i = 1:nchan
    % Get channel estimation
    temp_h = abs(ch2(x,y(:,i)));
    % Normalize values
    h(:, i) = temp_h(2000:end)/max(temp_h(2000:end));
end
    
Hmax = h_peak_finder(h);
    
for i = 1:nchan
    if (plot_data)
        % Create time axis
        th = (0:(length(h) - 1))/Fs;
        
        subplot(5,1,i);
        hold off;
        % Plot the estimation
        stem(th, h(:,i), '.');

        if (i == 1); title('Channel estimation'); end
        if (i == nchan); xlabel('Time (s)'); end

        hold on;

        % Plot the chosen peak
        p = plot((Hmax(i)-1)/Fs, h(Hmax(i), i), 'x');
        p.LineWidth = 1.5;
        p.MarkerSize = 8;
    end
end

clear firstPeak;
Hdist = Hmax-Hmax(1);