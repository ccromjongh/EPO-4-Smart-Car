clear variables;
%Fs = 37800;    % A more standard sampling rate
Fs = 34029;     % Exactly speed of sound in cm/s
Fs_TX = 44100;  % Standard CD sample rate
nrep = 10;      % Repetitions of training signal
[y, x, xx, x0] = send_refsignal(nrep, Fs, 1);


%% Plot one period of the reference signal
figure(1);

subplot(2,1,1);

t = (0:(length(x) - 1))/Fs_TX;
stem(t, x, 'o');

title_str = ['Transmit signal with Fs = ', num2str(Fs_TX), ' Hz'];
title(title_str);
xlabel('Time [s]');
ylabel('Amplitude');
axis([0, length(x)/Fs_TX, -1, 1]);

subplot(2,1,2);
X = fft(x, 9*length(x));
%X = fft(x);
plot_amplitude(X, 'X', 'Amplitude of transmitted signal', '', Fs_TX);


%% Plot recorded data
figure(2);

subplot(2,1,1);             % Plot soundwave

t = (0:(length(y) - 1))/Fs; % Create time axis
maxY1 = max(y(:, 1));       % Find max value first recording
maxY2 = max(y(:,2));        % Find max value second recording
Yratio = maxY1/maxY2;       % Calculate ratio between signals
plot(t, y, t, y(:,2)*Yratio);

% Set properties of plot
title_str = ['Recording with Fs = ', num2str(Fs), ' Hz and ', num2str(nrep), ' repetitions'];
title(title_str);
xlabel('Time [t]');
ylabel('Amplitude');
axis([0, length(y)/Fs, -maxY1*1.1, maxY1*1.1]); % Set axis limits

subplot(2,1,2);             % Plot frequency data
Y = fft(y, 9*length(y));    % Calculate Fourier transform of y
plot_amplitude(Y, 'Y', 'Amplitude of recording', '');


%% Plot calculated impulse response
figure(3);
% h = ch3(x, y);
h = ch3(y(:, 1), y(:, 2));  % Calculate imulse response from recording
[maxH, maxHIndex] = max(abs(h));
endH = min(2 * maxHIndex, length(h));   % Endpoint of time axis to give a sensible plot
th = (0:(endH - 1))/Fs;     % Create h time axis
stem(th, h(1:endH));        % Plot impulse response
title(['Recovered Impulse response with calc. distance of ', num2str(maxHIndex), ' cm']);
xlabel('Amplitude');
ylabel('Time [s]');


%% Plot input signal convoluted with calculated impulse response
% figure(4);
% y2 = conv(x, h);
% 
% subplot(2,1,1);
% 
% t = (0:(length(y2) - 1))/Fs;
% plot(t, y2);
% 
% title_str = 'Convolution of x and recovered impulse response';
% title(title_str);
% xlabel('Time [t]');
% ylabel('Amplitude');
% axis([0, length(y2)/Fs, -1, 1]);
% 
% subplot(2,1,2);
% Y2 = fft(y2, 9*length(y2));
% plot_amplitude(Y2, 'Y', 'Amplitude of convolution', '');


