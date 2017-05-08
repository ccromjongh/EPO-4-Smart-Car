function h = channelEst(gx, gy, L_cap, filter)
    if nargin < 3
        L_cap = false;
    end

    if nargin < 4
        filter = false;
    end
    
    %gx = gpuArray(x);
    %gy = gpuArray(y);

    % Used for filtering out low-energy noise
    if (filter)
        max_singal_val = max(gx);
        eps = max_singal_val * 0.01;
        ii = abs(gx) <= eps;
        gx(ii) = 0;
    end

    % Get lengths of arrays
    Ny = length(gy); Nx = length(gx);
    if (isnumeric(L_cap))
        L = L_cap;
    else
        L = Ny - Nx + 1;
    end
    
    % Execute FFT
    Y = fft(gy);
    X = fft([gx; zeros(Ny - Nx,1)]); % zero padding to length Ny

    % frequency domain deconvolution
    % H = mrdivide(Y, X);
    H = rdivide(Y, X);
    gh = ifft(H);
    if (L < length(gh))
        gh = gh(1:L);
    end
    
    h = gather(gh);
end