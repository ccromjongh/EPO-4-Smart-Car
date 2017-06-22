clear variables;

Fs = 96000;
nchan = 5;
max_samples = 1700;
min_distance = 50;
checkpoint = 1;
Vs = 340.29;
latency = 0.05;
demo_mode = false;
KITT = testClass;
algorithm = 2;

plotstuff = false;

% p = gcp('nocreate'); % If no pool, do not create new one.
% if isempty(p)
%     p = gcp();
% end

JSON = fileread('field.json');
field_data = jsondecode(JSON);
clear JSON;

load audiodata_96k2.mat;
Nrp = Nrp - 2;


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

% Get expected values of the distances
radii = sqrt((field_data.marks(checkpoint).x - [field_data.mics.x]).^2 + (field_data.marks(checkpoint).y - [field_data.mics.y]).^2);
expected = radii/(100*Vs);
x_ref = field_data.marks(checkpoint).x;
y_ref = field_data.marks(checkpoint).y;

%% Plot recorded data
figure(1);

% Plot soundwave
subplot(2,1,1);

%[L, ~] = size(y);
y_max = max(abs(y));
signal_start = zeros(1, nchan);
start_threshold = 0.5;

for i = 1:nchan
    % Normalize vector
    y(:, i) = y(:, i)/y_max(i);


    eps = 0.1;
    ii = abs(y(:, i)) <= eps;
    y(ii, i) = 0;
    
    
    % Find first element greater than 
    signal_start(i) = find(abs(y(:, i)) > start_threshold, 1);
end
abs_start = min(signal_start) - 20;
if (abs_start < 1); abs_start = 1; end

signal_start = signal_start - abs_start;
clear start_threshold eps;

% Create time axis
t = (0:(length(y) - 1))/Fs;
plot(t, y);

% Set properties of plot
title(['Recording with Fs = ', num2str(Fs), ' Hz']);
xlabel('Time [t]');
ylabel('Amplitude');
axis([0, length(y)/Fs, -1.1, 1.1]); % Set axis limits

subplot(2,1,2);                     % Plot frequency data
Y = fft(y, 9*length(y));            % Calculate Fourier transform of y
plot_amplitude(Y, 'Y', 'Amplitude of recording', '');

figure(2);
for i = 1:nchan
    subplot(nchan, 1, i);
    plot(t, y(:, i));
    title(['Microphone ' num2str(i)]);
end


 
%% Do channel estimation
tic;
if (algorithm == 3)
    h = channelEst(y, x, max_samples, false);
    
    %{
    [maxH, maxHIndex] = max(h(min_distance:end, :));
    maxHIndex = maxHIndex + min_distance;

    [psor,lsor] = findpeaks(h(:, 2), 'SortStr', 'descend');
    distance = maxHIndex * Vs * 100 / Fs;
    time = maxHIndex / Fs;
    Performace = toc;
    expectedIndex = round(expected*Fs);

    %% Plot impulse response

    %endH = min(2 * maxHIndex, length(h));   % Endpoint of time axis to give a sensible plot
    endH = repmat(max_distance, 1, 5);
    for i = 1:nchan
        th = (0:(endH(i) - 1))/Fs;          % Create h time axis
        subplot(nchan, 1, i);
        hold off;
        stem(th, h(1:endH(i), i));          % Plot impulse response
        hold on;

        p = stem((maxHIndex(i)-1)/Fs, maxH(i));
        p.LineWidth = 1.05;
        ylim([0 1.1]);
        plot([expected(i) expected(i)], [0 2], '--', 'LineWidth', 1.05);

        title_str = sprintf('Mic %d with relative distance %.2f cm', mic(i), distance(i));
        title(title_str);
        ylabel('Amplitude');
        xlabel('Time [s]');
    end
    clear title_str;
    %}
else
    for i = 1:nchan
        % Get channel estimation
        temp_h = abs(ch2(x,y(:,i), true));
        % Normalize values
        if (length(temp_h) > 7800)
            h(:, i) = temp_h(2000:5800)/max(temp_h(2000:5800));
        else
            h(:, i) = temp_h(2000:end)/max(temp_h(2000:end));
        end
    end
end

Hmax = h_peak_finder(h);
%}

Hdist = Hmax-Hmax(1);
% Do TDOA estimation and stuff
[x_calc y_calc z_calc] = tdoa2([field_data.mics.x; field_data.mics.y; field_data.mics.z]', Hdist,Fs); %#ok<NCOMMA>

% Calculate error based on what we expected
error_distance = sqrt((x_ref - x_calc)^2 + (y_ref - y_calc)^2);
Performace = toc;

figure(3);
for i = 1:nchan
    th = (0:(length(h) - 1))/Fs;
    
    subplot(5,1,i);
    
    hold off;
    stem(th, h(:,i), '.');
    
    title(sprintf('Channel estimation mic %d', i));
    if (i == nchan); xlabel('Time (s)'); end
    
    hold on;
    
    p = plot((Hmax(i)-1)/Fs, h(Hmax(i), i), 'x');
    p.LineWidth = 1.5;
    p.MarkerSize = 8;
end

distance = zeros(1,5);
mics = 1:5;
playfield_plot(distance, 1:5, x_calc, y_calc, field_data);

fprintf('Calculated a position of x = %.2f; y = %.2f, resulting in an error of %.2f cm\n', x_calc, y_calc, error_distance);