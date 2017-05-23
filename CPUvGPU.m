clear variables;
load train

%gpuDevice(1);

gx = gpuArray(single(y));
n = 100;

test = gpuArray(single(rand(1, 10)));
prep = fft(test);
%wait(gpuDevice(1));

tic
cx = repmat(y, n, 1);
ch = ch3(cx, cx, false, true);
cTime = toc;

tic
ggx = repmat(gx, n, 1);
gh = channelEst(ggx, ggx, false, true);
gTime = toc;

gTime/cTime


% n = 100;
% gx = gpuArray(repmat(single(y), n, 1));
% cx = repmat(y, n, 1);
% 
% bc = @() fft(cx);
% tc = gputimeit(bc);
% 
% bg = @() fft(gx);
% tg = gputimeit(bg);