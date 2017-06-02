clear variables;
Fs = 48000;

nchan = 5;
max_distance = 500;
min_distance = 50;
use_measurement = 4;
checkpoint = floor((use_measurement+1)/2);
Vs = 340.29;
do_absolute = true;


JSON = fileread('field.json');
field_data = jsondecode(JSON);
clear JSON;

% % Get reference audio
% load 'audiodata_reference.mat';
% x = zeros(length(RXXr), nchan);
% for i = 1:nchan
%     x(:, i) = RXXr(i,:,i)';
% end

load 'new_reference.mat';

% Get audio from point
load 'audiodata_playrec.mat';
y = squeeze(RXXr(use_measurement, :, :));
clear RXXr;

radii = sqrt((field_data.marks(checkpoint).x - [field_data.mics.x]).^2 + (field_data.marks(checkpoint).y - [field_data.mics.y]).^2);
expected = radii/(100*Vs);


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

figure(3);
for i = 1:nchan
    subplot(nchan, 1, i);
    plot(t, y(:, i));
    title(['Microphone ' num2str(i)]);
end


%% Sort signals based on amplitude time detection
tic;
figure(2);

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


%% Do channel estimation

% h = channelEst(x, y, max_distance, true);
if (do_absolute)
    % Calculate imulse response from recording using another recording as
    % reference
    h = channelEst(y, x, max_distance, true);
else
    % Calculate imulse response from recording, relatively
    h = channelEst(y, 1, max_distance, true);
end

if do_absolute
    [maxH, maxHIndex] = max(h(min_distance:end, :));
    maxHIndex = maxHIndex + min_distance;
else
    [maxH, maxHIndex] = max(h);
end
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

playfield_plot(distance, mic);