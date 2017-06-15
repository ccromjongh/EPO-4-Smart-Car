function MapPlot(FIELD)
[Ymax, Xmax] = size(FIELD);                          % Get the matrix size
for i = 1:Ymax
    for j =1:Xmax
        if FIELD(i,j) == 0
            FieldIm(i,j) = 1;
        else 
            FieldIm(i,j) = 0;
        end
    end
end

% for i = 1:Ymax
%     for j = 1:Xmax
%         FieldIm(i,j) = FieldTemp(Ymax+1-i,j);
%     end
% end
imagesc((1:Xmax)+0, (1:Ymax)+0, FieldIm);          % Plot the image
colormap(gray);                              % Use a gray colormap
axis equal                                   % Make axes grid sizes equal
set(gca, 'XTick', 1:(Xmax+1), 'YTick', 1:(Ymax+1), ...  % Change some axes properties
         'XLim', [1 Xmax+1], 'YLim', [1 Ymax+1], ...
         'GridLineStyle', '-', 'XGrid', 'on', 'YGrid', 'on');
     set(gca,'Ydir','reverse')
xlim([0.5 Xmax+0.5]);
ylim([0.5 Ymax+0.5]);
