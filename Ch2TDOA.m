clear variables;
Fs = 48000;

nchan = 5;
max_distance = 500;
min_distance = 50;
use_measurement = ;
checkpoint = floor((use_measurement+1)/2);
Vs = 340.29;
do_absolute = true;

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
figure(3);
for i = 1:nchan
    h(:,i) = ch2(x,y(:,i));
    subplot(5,1,i);
    stem(abs(h(:,i))/max(h(:,i)), '.');
    hold on;
    [pk,lc] = findpeaks(abs(h(:,i))/max(h(:,i)),'Minpeakheight',0.5);
    plot(lc(1),pk(1),'x')
    hold off;
    Hmax(:,i) = lc(1);
end
[x y z] = tdoa2(mic, Hmax-Hmax(1));