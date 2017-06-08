function save_reference(name)

save(['audiodata_' name '.mat'], 'y', 'Timer0', 'Timer1', 'Timer3', 'code', 'Fs', 'Nrp', 'Trec', '-mat');