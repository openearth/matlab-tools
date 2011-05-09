function M_out = mconvert(M_in)
% Convert MATLAB 5.3 movie format to MATLAB 5.2
% movie format.  There may be some loss of quality due to the
% fact that 5.2 format movies can not support more than
% 256 colors.  Set the colormap to M_in(1).colormap if the 
% original movie is indexed.

vers = version;
oldformat = 0;
if (str2num(vers(1:3)) > 5.2)
oldformat = feature('newmovieformat');
   feature('newmovieformat', 0);
end 
len = length(M_in);

[h w] = size(M_in(1).cdata);
f = figure('pos', [0 0 w h]);
set(gca, 'units', 'norm', 'pos', [0 0 1 1], 'vis', 'off');
M_out = moviein(len);
drawnow;
for i = 1:len
   if ~isempty(M_in(i).colormap)
      colormap(M_in(i).colormap);
   end
   image(M_in(i).cdata);
   set(gca,'vis','off');
   drawnow;
   M_out(:, i) = getframe;
end

close(f);

if oldformat
   feature('newmovieformat', oldformat);
end