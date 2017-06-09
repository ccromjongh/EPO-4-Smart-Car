function initialise_audio_box(Fs, reInit)

if (reInit)
    % Reset if already initialised
    if (playrec('isInitialised'))
        playrec('reset');
    end
end

% Check if device needs to be initialised
if (reInit || ~playrec('isInitialised'))
    devId = find_audio_device();

    % Initialise PlayRec
    playrec('init', Fs, -1, devId);
end

% Throw error if that is not the case
if ~playrec('isInitialised')
    error ('Failed to initialise device at any sample rate');
end