function [k] = RedCost(xcurrent, ycurrent, xparent, yparent, xnewnode, ynewnode)
k=0;
dx = xcurrent - xparent;
dy = ycurrent - yparent;
if (xnewnode ~= xcurrent + dx) || (ynewnode ~= ycurrent + dy)
k =30;
end