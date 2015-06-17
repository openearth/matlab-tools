function filetype = det_filetype (filename)

% det_filetype : determines, based on name/extension, whether a file is a delft3d or simona file (or DFLOWFM)

filetype = 'none';

[~,name,extension] = fileparts(filename);
filename = lower([name extension]);

%
% input trih or SDS; output bct or timeser
%

if ~isempty(strfind(filename,'sds'   )) || ~isempty(strfind(filename,'timeser')) || ...
   ~isempty(strfind(filename,'points'))
    filetype = 'SIMONA';
end

if ~isempty(strfind(filename,'trih'  )) || ~isempty(strfind(filename,'bct'    )) || ...
   ~isempty(strfind(filename,'bcc'   )) || ~isempty(strfind(filename,'obs'    )) || ...
   ~isempty(strfind(filename,'bnd'   ))
    filetype = 'Delft3D';
end

if ~isempty(strfind(filename,'mdf'  ))
    filetype = 'mdf';
end

if ~isempty(strfind(filename,'mdu'  ))
    filetype = 'mdu';
end

if ~isempty(strfind(filename,'ext'  ))
    filetype = 'ext';
end

if ~isempty(strfind(filename,'siminp'))
    filetype = 'siminp';
end

if ~isempty(strfind(filename,'grd')) || ~isempty(strfind(filename,'rgf'))
     filetype = 'grd';
end

if ~isempty(strfind(filename,'net.nc')) || ~isempty(strfind(filename,'map.nc'))
    filetype = 'DFLOWFM';
end

[~,~,ext] = fileparts(filename);
if ~isempty(strfind(ext,'pli'))
    filetype = 'pli';
end

if ~isempty(strfind(filename,'.tim'))
    filetype = 'DFLOWFM';
end

if ~isempty(strfind(filename,'.xyn'))
    filetype = 'DFLOWFM';
end

if ~isempty(strfind(filename,'_his.nc'))
    filetype = 'DFLOWFM';
end
