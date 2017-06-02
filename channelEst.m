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
        eps = 0.5;
        ii = abs(gy) <= eps;
        gy(ii) = 0;
    end

    if (isnumeric(L_cap))
        L = L_cap;
    else
        L = 1000;
    end
    
    % Execute FFT
    Ny = 1E6;
    Y = complex(zeros(Ny, dim));
    for ii = 1:dim
        Y(:, ii) = fft(gy(:, ii), Ny);
    end
    
    [Nx, refDim] = size(use_reference);
    if (Nx > 1)
        if (Nx > Ny)
            use_reference = use_reference(1:Ny, :);
        elseif (Nx < Ny)
            use_reference = cat(1, use_reference, zeros(Ny - Nx, refDim));
        end
    end
    
    X = [];
    if (Nx > 1)
        X = complex(zeros(Ny, refDim));
        for ii = 1: refDim
            X(:, ii) = fft(use_reference(:, ii), Ny);
        end
    end

    % frequency domain deconvolution
    H = complex(zeros(Ny,  1));
    gh = zeros(Ny,  dim);
    
    for i = 1:dim
        % Multidimensional reference
        if (refDim == dim)
            H = rdivide(X(:, i), Y(:, i));
            gh(:, i) = abs(ifft(H));
        % Single reference
        elseif (Nx > 1)
            H = rdivide(X, Y(:, i));
            gh(:, i) = abs(ifft(H));
        % Reference as selection of data (relative)
        else
            H = rdivide(Y(:, use_reference), Y(:, i));
            gh(:, i) = abs(ifft(H));
        end
    end
    
    if (L < length(gh))
        gh = gh(1:L, :);
    end
    
    for i = 1:dim
       gh(:, i) = gh(:, i)/max(gh(:, i)); 
    end
    
    if (filter)
        eps = 0.35;
        ii = gh <= eps;
        gh(ii) = 0;
    end
    %wait(gpuDevice(1));
    
    h = gather(gh);
end