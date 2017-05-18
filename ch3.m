function h = ch3(x, y, L_cap, filter)
if nargin < 3
    L_cap = false;
end
 
if nargin < 4
    filter = false;
end
 
% Used for filtering out low-energy noise
if (filter)
    max_singal_val = max(x);
    eps = max_singal_val * 0.01;
    ii = abs(x) <= eps;
    x(ii) = 0;
end
 
Ny = length(y); Nx = length(x);
if (isnumeric(L_cap))
    L = L_cap;
else
    L = Ny - Nx + 1;
end
Y = fft(y);
X = fft([x; zeros(Ny - Nx,1)]); % zero padding to length Ny
  
H = Y ./ X; % frequency domain deconvolution
h = ifft(H);
if (L < length(h))
    h = h(1:L);
end
end