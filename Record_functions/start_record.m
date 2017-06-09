function page = start_record (Fs, record_time, nMicrophones, reInit)

if nargin < 3
   nMicrophones = 5; 
end
if nargin < 4
   reInit = false; 
end


if ~isnumeric(Fs), error('Fs must be a real'); end
if ~isnumeric(nMicrophones), error('nMicrop must be an integer'); end

initialise_audio_box(Fs, reInit);

if ~playrec('isInitialised')
    error ('Audio device must be initialised');
end

% Calculate samples to record
if (record_time < 50)
    sampleCount = round(record_time * Fs);
else
    sampleCount = round(record_time);
end

% Start recording in a new buffer page
page = playrec('rec', sampleCount, 1 : nMicrophones);