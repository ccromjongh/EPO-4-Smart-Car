function save_reference(name)
global x  Timer0 Timer1 Timer3 code Fs Nrp Trec; %#ok<*NUSED>

save(['audiodata_' name '.mat'], 'x', 'Timer0', 'Timer1', 'Timer3', 'code', 'Fs', 'Nrp', 'Trec', '-mat');