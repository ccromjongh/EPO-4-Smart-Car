function Hdist = process_cancer_recording (page, nchan, Fs)
    latency = 0.05;
    
    if (page)
        % Get data
        recorded = get_record(page);

        throwaway = round(latency*Fs);
        y = recorded(throwaway:end, :);
        clear recorded;

        % Save recording for later use in demo_mode
        save('Recordings/last_TDOA_rec.mat', 'y');
    else
        load('Recordings/last_TDOA_rec.mat');
    end
    
    load audiodata_96k2.mat;

    y_max = max(abs(y));
    for i = 1:nchan
        % Normalize vector
        y(:, i) = y(:, i)/y_max(i);


        eps = 0.2;
        ii = abs(y(:, i)) <= eps;
        y(ii, i) = 0;
    end

    %% Find channel estimations

    for i = 1:nchan
        % Get channel estimation
        temp_h = abs(ch2(x, y(:,i), true));
        % Normalize values
        if (length(temp_h) > 7800)
            h(:, i) = temp_h(2000:5800)/max(temp_h(2000:5800));
        else
            h(:, i) = temp_h(2000:end)/max(temp_h(2000:end));
        end
    end

    Hmax = h_peak_finder(h);

    clear firstPeak;
    Hdist = Hmax-Hmax(1);
end