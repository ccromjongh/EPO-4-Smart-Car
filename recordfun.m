function record_data = recordfun (reclength, channels)
    Fs = 34029;
    n = reclength * Fs;
    record_data = pa_wavrecord(1, channels, n, Fs, 1, 'win');
end