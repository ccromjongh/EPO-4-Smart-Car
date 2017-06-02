%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Playrec - an alternative to pa_wavrecord(.)
% This example script shows how to use playrec to record upto 5 mics.
% Source files can be downloaded from this link below
% http://www.playrec.co.uk/index.html
% 
% We recommend to compile the source files yourself. Nevertheless,
% the precompiled binary files (e.g., for windows use the *.mexw64 file) 
% from the link below
% https://github.com/Janwillhaus/Playrec-Binaries
%
%- for the list of commands for playrec, call playrec without any options      
%- for more detailed explanation of a command use playrec('help','command')
%  
% EPO-4 project, 27-05-2016, TU Delft.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all; close all;clc;
%% Find device ID

if playrec('isInitialised')
    playrec('reset');
end
devs = playrec('getDevices');
for id=1:size(devs,2)
    if(strcmp('ASIO4ALL v2',devs(id).name))
        break;
    end
end
devId=devs(id).deviceID;
%% initialization
Fs = 48000;
N = 9600; % # samples (records 100ms)
maxChannel = 5;% # mics

playrec('init', Fs, -1, devId);

if ~playrec('isInitialised')
    error ('Failed to initialise device at any sample rate');
end

%% initilize the communication ports and audiobeacon parameters

% start of the recording main loop
while (1)
    page = playrec('rec', N, 1 : maxChannel); % start recording in 
                                           % a new buffer page
    while(~playrec('isFinished')) % Wait till recording is done 
                             %(can also be done by turning on the block option)
    end
    y = double(playrec('getRec',page)); % get the data

    playrec('delPage'); % delete the page (can be done every few cycle)
    % end of the recording main loop

    % Here comes the localization and control code
    % We just plot the data here ...
    
    figure(1)
    plot(y)
    drawnow;
    in=input('','s');
    if (in=='q')
        break;
    end
    
    % to  be removed, for the final challenge
end

%% Reset the playrec object
playrec('reset')