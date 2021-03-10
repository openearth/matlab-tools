function [outputvar] = shp2struct(fullfile)
%SHP2STRUCT  convert a shape file to a struct

  % addpath('c:\Program Files (x86)\Deltares\Delft3D 4.00.12\win32\delft3d_matlab\')
  SHP=qpfopen(fullfile);
  Q=qpread(SHP);
  objstr = {Q.Name};
  outputvar.xy=qpread(SHP,objstr{1},'griddata');
  for i=2:length(objstr)
    outputvar.val{i-1}=qpread(SHP,objstr{i},'data');
  end

