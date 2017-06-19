clear variables;
% Fs = 96000;

nchan = 5;
max_distance = 500;
min_distance = 50;
checkpoint = 2;
Vs = 340.29;
do_absolute = true;
demo_mode = true;
KITT = testClass;

JSON = fileread('field_K.json');
field_data = jsondecode(JSON);
clear JSON;

load audiodata_96k.mat;
Nrp = Nrp - 1;


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
    y = get_record(page);
    
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

subplot(2,1,1);             % Plot soundwave

y_max = max(abs(y));
signal_start = zeros(1, nchan);
start_threshold = 0.5;

for i = 1:nchan
    % Normalize vector
    y(:, i) = y(:, i)/y_max(i);
    % Find first element greater than 
    signal_start(i) = find(abs(y(:, i)) > start_threshold, 1);
end
abs_start = min(signal_start) - 20;
if (abs_start < 1); abs_start = 1; end

signal_start = signal_start - abs_start;
if (~do_absolute)
    y = y(abs_start:end, :);
end
clear start_threshold;

% Create time axis
t = (0:(length(y) - 1))/Fs;
plot(t, y);

% Set properties of plot
title(['Recording with Fs = ', num2str(Fs), ' Hz']);
xlabel('Time [t]');
ylabel('Amplitude');
axis([0, length(y)/Fs, -1.1, 1.1]); % Set axis limits

subplot(2,1,2);             % Plot frequency data
Y = fft(y, 9*length(y));    % Calculate Fourier transform of y
plot_amplitude(Y, 'Y', 'Amplitude of recording', '');

figure(2);
for i = 1:nchan
    subplot(nchan, 1, i);
    plot(t, y(:, i));
    title(['Microphone ' num2str(i)]);
end


%% Sort signals based on amplitude time detection
tic;

original = signal_start;
mic = 1:nchan;
for i = 1:nchan
    for j = 1:nchan-i
        if (signal_start(j) > signal_start(j+1))
            holder = signal_start(j);
            signal_start(j) = signal_start(j+1);
            signal_start(j+1) = holder;

            holder = mic(j);
            mic(j) = mic(j+1);
            mic(j+1) = holder;
            
            temp = y(:, j);
            y(:, j) = y(:, j+1);
            y(:, j+1) = temp;
        end
    end
end
clear temp holder i j;


% %% Do channel estimation
% 
% % h = channelEst(x, y, max_distance, true);
% if (do_absolute)
%     % Calculate imulse response from recording using another recording as
%     % reference
%     h = channelEst(y, x, max_distance, true);
% else
%     % Calculate imulse response from recording, relatively
%     h = channelEst(y, 1, max_distance, true);
% end
% 
% if do_absolute
%     [maxH, maxHIndex] = max(h(min_distance:end, :));
%     maxHIndex = maxHIndex + min_distance;
% else
%     [maxH, maxHIndex] = max(h);
% end
% [psor,lsor] = findpeaks(h(:, 2), 'SortStr', 'descend');
% distance = maxHIndex * Vs * 100 / Fs;
% time = maxHIndex / Fs;
% Performace = toc;
% expectedIndex = round(expected*Fs);
% 
% %% Plot impulse response
% 
% %endH = min(2 * maxHIndex, length(h));   % Endpoint of time axis to give a sensible plot
% endH = repmat(max_distance, 1, 5);
% for i = 1:nchan
%     th = (0:(endH(i) - 1))/Fs;          % Create h time axis
%     subplot(nchan, 1, i);
%     hold off;
%     stem(th, h(1:endH(i), i));          % Plot impulse response
%     hold on;
%     
%     p = stem((maxHIndex(i)-1)/Fs, maxH(i));
%     p.LineWidth = 1.05;
%     ylim([0 1.1]);
%     plot([expected(i) expected(i)], [0 2], '--', 'LineWidth', 1.05);
%     
%     title_str = sprintf('Mic %d with relative distance %.2f cm', mic(i), distance(i));
%     title(title_str);
%     ylabel('Amplitude');
%     xlabel('Time [s]');
% end
% clear title_str;

figure(3);
for i = 1:nchan
    h(:,i) = abs(ch2(x,y(:,i)));
    h(1:end-2000,i) = h(2001:end, i);
    %h(1:2000, i) = 0;
    h(:,i) = h(:,i)/max(h(:,i));
    th = (0:(length(h) - 1))/Fs;
    
    subplot(5,1,i);
    stem(th, h(:,i), '.');
    
    if (i == 1); title('Channel estimation'); end
    if (i == nchan); xlabel('Time (s)'); end
    
    hold on;
    
    [~, lc] = findpeaks(h(:,i), 'Minpeakheight', 0.5);
    firstPeak = lc(1);
    [pk, lc] = max(h(firstPeak:firstPeak + 50, i));
    lc = lc + firstPeak - 1;
    
    p = plot((lc-1)/Fs, pk, 'x');
    p.LineWidth = 1.5;
    p.MarkerSize = 8;
    
    hold off;
    Hmax(:,i) = lc(1);
end
clear firstPeak;

Hdist = Hmax-Hmax(1);
[x_calc y_calc z_calc] = tdoa2(transpose(struct2cell(field_data.mics)),mic, Hdist,Fs); %#ok<NCOMMA>

error_distance = sqrt((x_ref - x_calc)^2 + (y_ref - y_calc)^2);
Performace = toc;

distance = zeros(1,5);
mics = 1:5;
playfield_plot(distance, mic, x_calc, y_calc, field_data);

fprintf('Calculated a position of x = %.2f; y = %.2f, resulting in an error of %.2f cm\n', x_calc, y_calc, error_distance);