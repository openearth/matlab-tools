function Icon=MakeIcon(file,sz)

a=imread(file);
[r,c,d] = size(a);
r_skip = ceil(r/sz);
c_skip = ceil(c/sz);
% Create the thinxthin icon (RGB data)
Icon = a(1:r_skip:end,1:c_skip:end,:);
Icon(Icon==255) = 255;

