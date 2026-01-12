function [X,Y,rgbimage]=digimage(picname)
% DIGIMAGE  Digitize an image file to create X and Y coordinate arrays

close all
rgbimage=imread(picname);

for i=1:3
    rgbimage(:,:,i)=flipud(rgbimage(:,:,i));
end
image(rgbimage);
set(gca,'ydir','normal')

disp("Zoom to desired location in figure and press a key when ready.");
pause

disp("Click two points for the lower left and upper right corner.");

x_input = NaN*zeros(2,1);
y_input = NaN*zeros(2,1);

for i=1:2
   [xi,yi,~]=ginput(1);
   x_input(i)=xi;
   y_input(i)=yi;
   hold on;
   plot3(xi,yi,5,'marker','o','MarkerEdgeColor','y','MarkerFaceColor','r');
   fprintf(1,'   x_input =  %7.2f, y_input =  %7.2f\n',xi,yi);
end

disp("Provide the locations in the reference coordinate system.");

[llc] =input('lower left corner coordinate [x_llc yllc] :  ');
[ruc] =input('upper right corner coordinate [x_ruc yruc] : ');

fac_x=(ruc(1)-llc(1))./(x_input(2)-x_input(1));
if ruc(2)-llc(2)~=0
    fac_y=(ruc(2)-llc(2))./(y_input(2)-y_input(1));
else
    fac_y=fac_x;    
end


[LX LY LZ]=size(rgbimage);

Y=fac_y*((1:LX)-y_input(1))+llc(2);
X=fac_x*((1:LY)-x_input(1))+llc(1);


figure(2)
image(X,Y,rgbimage);
set(gca,'ydir','normal');
axis on
matname = fullfile(filepathstr(picname), [filename(picname), '.mat']);
save(matname, "X","Y","rgbimage", "llc", "ruc", "x_input", "y_input");




