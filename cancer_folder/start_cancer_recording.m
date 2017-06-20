function [page, Trec, Tbeacon] = start_cancer_recording(demo_mode, KITT)

    if (nargin < 3)
       nchan = 5;
    end

    % To suppress MATLAB's itching
    Nrp = 4; Fs = 96000;
    load audiodata_96k.mat;
    Nrp = Nrp - 2;

    Trec = Nrp/Timer3 + 0.1;                % Record data segment length
    Tbeacon = (Nrp - 0.2)/Timer3;           % Time the beacon should stay on
    sampleCount = floor(Trec*Fs);           % The number of samples of the recorded data (one data segment)

    %% Initialise and start recording

    if (~demo_mode)
        % Set up beacon
        page = start_record(Fs, sampleCount);

        tic;
        % Turn on beacon
        KITT.toggleBeacon(true);
    else
        page = 0;
        pause(0.02);
    end
end