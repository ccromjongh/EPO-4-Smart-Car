function [Hmax] = h_peak_finder(h)

[L, nchan] = size(h);
Hmax = zeros(1, nchan);

for i = 1:nchan
    % Find all peaks that are higher than 0.5
    [~, lc] = findpeaks(h(:,i), 'Minpeakheight', 0.5);
    if (length(lc) > 0)
        firstPeak = lc(1);

        % Find the maximum value within 50 samples from the initial peak, to
        % really get the maximum peak
        if (length(h) > firstPeak + 300)
            [~, lc] = max(h(firstPeak:firstPeak + 300, i));

            % Location of the peak is the index of the max + the offset where we
            % looked - 1 because of stupid matlab indexing
            lc = lc + firstPeak - 1;
        end
        Hmax(i) = lc;
    else
        Hmax(i) = 250;
    end
end
    
end