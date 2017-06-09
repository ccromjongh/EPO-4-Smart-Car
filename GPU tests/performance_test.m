function [tc, tg] = performance_test
    %clear variables;
    %close all;
    profile on
    a = imread('D:\afbeeldingen\Image.jpg');
    b = @() imrotate(a, 40, 'bilinear', 'loose');
    tc = timeit(b);
    %subplot(1, 2, 1);
    %imshow(b);
    
    ag = gpuArray(a);
    bg = @() imrotate(ag, 40, 'bilinear', 'loose');
    wait (gpuDevice);
    tg = gputimeit(bg);
    %subplot(1, 2, 2);
    %imshow(bg);
    profile viewer
end