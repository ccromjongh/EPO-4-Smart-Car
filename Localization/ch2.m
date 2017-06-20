function h = ch2 (x, y, GPU)
    if (nargin < 3)
        GPU = false;
    end
    
    if (~GPU)
        Ny = length(y); Nx = length(x); L = Ny - Nx + 1;
        xr = flipud(x);     % reverse the sequence x (assuming a col vector)
        h = filter(xr,1,y); % matched filtering
        h = h(Nx:end);      % skip the first Nx samples, so length(h) = L
        alpha = x'*x;       % estimate scale
        h = h/alpha;        % scale down
    else
        gx = gpuArray(single(x)); gy = gpuArray(single(y));
        Ny = length(gy); Nx = length(gx);
        gxr = flipud(gx);     % reverse the sequence x (assuming a col vector)
        gh = filter(gxr,1,y); % matched filtering
        gh = gh(Nx:end);      % skip the first Nx samples, so length(h) = L
        alpha = x'*x;       % estimate scale
        gh = gh/alpha;        % scale down
        h = double(gather(gh));
    end

end