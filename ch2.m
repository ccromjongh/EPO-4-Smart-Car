function h = ch2 (x, y)

Ny = length(y); Nx = length(x); L = Ny - Nx + 1;
x = x(:); y = y(:); % ensure column vectors
xr = flipud(x); % reverse the sequence x (assuming a col vector)
h = filter(xr,1,y); % matched filtering
h = h(Nx:end); % skip the first Nx samples, so length(h) = L
alpha = x'*x; % estimate scale
h = h/alpha; % scale down

end