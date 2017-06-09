function initialise_audio_box(reInit)

% Default to not resetting device
if (nargin == 0); reInit = false; end

if (reInit)
    % Reset if already initialised
    if (playrec('isInitialised'))
        playrec('reset');
    end
end

% Check if device needs to be initialised
if (reInit || ~playrec('isInitialised'))
    devId = findAudioDevice();

    % Initialise PlayRec
    playrec('init', Fs, -1, devId);
end

% Throw error if that is not the case
if ~playrec('isInitialised')
    error ('Failed to initialise device at any sample rate');
end