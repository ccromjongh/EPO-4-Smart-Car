function plot_amplitude (X, varname, title_amplitude, plot_args, Fs)

    if nargin < 4
        plot_args = '';
    end
    if nargin < 5
        Fs = false;
    end

    [N1, N2] = size(X);
    N = max(N1, N2);
    
    if (isnumeric(Fs))
        Omega = 0: 2*Fs/N : (N-1)*2*Fs/N;
    else
        Omega = 0: 2*pi/N : (N-1)*2*pi/N;
    end
    
    plot(Omega, abs(X), plot_args);
    ylabelName = strcat('Amplitude response (|', varname, '|)');
    ylabel(ylabelName);
    title(title_amplitude);
    if (isnumeric(Fs))
        xlim([0, 2*Fs]);
        xlabel('Frequency (Hz)');
    else
        xlim([0, 2*pi]);
        set(gca,'XTick', [0 0.5*pi pi 1.5*pi 2*pi]);
        set(gca,'XTickLabel',{'0','½ \pi','\pi','1½ \pi','2\pi'});
        xlabel('Frequency (\omega)');
    end
end