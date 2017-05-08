clear variables;
load train

gpuDevice(1);

gx = gpuArray(y);

tic
cx = repmat(y, 1000, 1);
ch = ch3(cx, cx, false, true);
cTime = toc;

tic
ggx = repmat(gx, 1000, 1);
gh = channelEst(ggx, ggx, false, true);
gTime = toc;

gTime/cTime