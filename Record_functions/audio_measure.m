function audio_measure(iMeasure, KITT, Timer0, Timer1, Timer3, code, Fs, nMicrop, nLoop, Nrp)
%--------------------------------------------------------------------------
% File        : audio_measure.m
% Project     : EPO-4
% Description : use sample card to record the audio signal, save the audio
% data and parameters as a .mat file
%--------------------------------------------------------------------------
% Input:iMeasure: ith measurement, e.g. iMeasure = 0, save audiodata0.mat
%       comport: bluetooth comport
%       f_c,f_b,c_r,code, as for 
%       Extension: If Timer0 == -1, then no carrier modulation
%       Fs: sample rate at which to generate the template (e.g., 48KHz)
%       nMicrop: number of microphones for measurement, e.g. 4
%       nLoop:   number of data segment to collect, e.g. 10 
%       Nrp:     number of repetition period (Timer 3) to collect, e.g. 1
%       or 2
%
% An example using audio_measure
%     audio_measure('1', KITT, 15000, 5000, 20, '983BD2C4', 48e3, 5, 8, 5);
%     squeeze(RXXr(1,:,:))  
% Output: save the audio data measured by different channels, RXXr is a 3D
%         array, of maximum size nLoop * (length of data segment) * nMicrop,
%         where length of data segment decided by Nrp, Timer3 and Fs
%         and corresponding parameters. e.g. iMeasure = 0, save audiodata0.mat
%   

close all

% first perform sanity checks on the input
if ~ischar(iMeasure), error('iMeasure must be a string '); end
if ~isnumeric(Timer0), error('f_c must be an integer '); end
if ~isnumeric(Timer1), error('f_b must be an integer'); end
if ~isnumeric(Timer3), error('c_r must be an integer'); end
if ~ischar(code), error('code must be a hex string'); end
if ~isnumeric(Fs), error('Fs must be a real'); end
if ~isnumeric(nMicrop), error('nMicrop must be an integer '); end
if ~isnumeric(nLoop), error('nLoop must be an integer '); end
if ~isnumeric(Nrp), error('Nrp must be a real '); end



KITT.toggleBeacon(false);
pause(0.1);
KITT.setupBeacon(Timer0, Timer1, Timer3, code);

% Convert hex code string into binary string
bincode = [];
for ii = 1:length(code)
    symbol = code(ii);
    bits = dec2bin(hex2dec(symbol), 4);	% 4 bits for a hex symbol
    bincode = strcat(bincode, bits);
end

% Length of data segment
Trec = Nrp/Timer3 + 0.1;                % Record data segment length
Tbeacon = (Nrp - 0.2)/Timer3;           % Time the beacon should stay on
sampleCount = floor(Trec*Fs);           % The number of samples of the recorded data (one data segment)


%% Initialise audio device
initialise_audio_box(Fs, true);

if ~playrec('isInitialised')
    error ('Audio device must be initialised');
end

RXXr = zeros(nLoop, sampleCount, nMicrop);


%% Repeatedly measure, save the measurements

for nRun = 1:nLoop
    reply = input('Press q to quit, any other key to continue the measurements.\n', 's');
    if reply == 'q'
        break;
    end
    
    fprintf('Measurement %d\n',nRun);

    % parameters for transmitting and receiving with the soundcard
%     playdevice = 0;
%     samplerate = Fs;
%     recfirstchannel = 1;
%     reclastchannel = recfirstchannel+nMicrop-1;
%     recdevice = 1;
%     devicetype = 'asio';
%     
%     KITT.toggleBeacon(true);	% switch on audio beacon
%     
%     % RXr: matrix which contains the signal received by each microphone, each
%     % column corresponse to one microphone
%     RXr = pa_wavrecord(recfirstchannel, reclastchannel, nSamplesRec, samplerate, recdevice); %, recdevice, devicetype);
%     KITT.toggleBeacon(false);   % switch off audio beacon
    
    
    % start recording in a new buffer page
    pause(0.1);
    page = start_record(Fs, sampleCount);
    
    tic;
    KITT.toggleBeacon(true);
    
    % Wait till recording is done 
    while(~playrec('isFinished'))
        % Toggle beacon off when it has completed it's Nrp cycles
        if (toc > Tbeacon)
           KITT.toggleBeacon(false); 
        end
        % Pause 5 milliseconds just because
        pause(0.005);
    end
    
    if (toc > Tbeacon)
       KITT.toggleBeacon(false); 
    end
    
    y = get_record(page);
    

    % Save the raw data in the data matrix, RXXr is a 3D matrix, RXXr(N_Loop, data_segment, nMicrop)
    RXXr(nRun,:,:) = y;  

    % Show the raw data
    for jj = 1:nMicrop
        figure(jj);
        plot(y(:, jj));
        grid on;
    end
end

%% Save all the data and parameters code,Fs,nMicrop,nLoop,Nrp 
save(['audiodata_' iMeasure '.mat'],'RXXr','Timer0','Timer1','Timer3','code','bincode','Fs','nMicrop','nRun','Nrp', 'Trec','-mat');

