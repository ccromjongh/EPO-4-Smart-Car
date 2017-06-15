function [Hdist, Fs] = RecordLive(demo_mode, nchan);

KITT = testClass;

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

%% Sort signals based on amplitude time detection


for i = 1:nchan
    h(:,i) = abs(ch2(x,y(:,i)));
    h(:,i) = h(:,i)/max(h(:,i));
    th = (0:(length(h) - 1))/Fs;
    
%     subplot(5,1,i);
%     stem(th, h(:,i), '.');
%     
%     if (i == 1); title('Channel estimation'); end
%     if (i == nchan); xlabel('Time (s)'); end
%     
%     hold on;
    
    [~, lc] = findpeaks(h(:,i), 'Minpeakheight', 0.5);
    firstPeak = lc(1);
    [pk, lc] = max(h(firstPeak:firstPeak + 50, i));
    lc = lc + firstPeak - 1;
    
%     p = plot((lc-1)/Fs, pk, 'x');
%     p.LineWidth = 1.5;
%     p.MarkerSize = 8;
%     
%     hold off;
    Hmax(:,i) = lc(1);
end

clear firstPeak;
Hdist = Hmax-Hmax(1);