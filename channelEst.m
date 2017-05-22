function h = channelEst(gy, use_reference, L_cap, filter)
    if nargin < 3
        L_cap = false;
    end

    if nargin < 4
        filter = false;
    end
    
    %gx = gpuArray(x);
    %gy = gpuArray(y);
    
    % Get lengths of arrays
    [Ny, dim] = size(gy);

    % Used for filtering out low-energy noise
    if (filter)
        eps = 0.1;
        ii = abs(gy) <= eps;
        gy(ii) = 0;
    end

    if (isnumeric(L_cap))
        L = L_cap;
    else
        L = 1000;
    end
    
    % Execute FFT
    Y = fft(gy);
    
    
    %Y = fft(gy + 2);
    %X = fft([gx; zeros(Ny - Nx,1)] + 2); % zero padding to length Ny

    % frequency domain deconvolution
    H = complex(zeros(Ny,  1));
    gh = zeros(Ny,  dim);
    
    for i = 1:dim
        H = rdivide(Y(:, use_reference), Y(:, i));
        gh(:, i) = ifft(H);
    end
    
    if (L < length(gh))
        gh = abs(gh(1:L, :));
    end
    %wait(gpuDevice(1));
    
    h = gather(gh);
end