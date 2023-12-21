%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision$
%$Date$
%$Author$
%$Id$
%$HeadURL$
%
%Compute size of a folder recursively. If a file identifier is passed, 
%and the size of the folder exceeds a given limit, the a Linux command 
%to erase the folder is written to file.
%
%INPUT:
%   -fdir = full path to the folder to analyze [char]
%
%OUTPUT:
%   -sz = size of the folder
%
%OPTIONAL (ordered input):
%   -2 = file identifier (generate valid file identifier with `fopen`) [double(1,1)]
%   -3 = size limit [bytes] [double(1,1)]

function sz=dir_size(fdir,varargin)

%% PARSE

if nargin>1
    fid=varargin{1,1};
else
    fid=NaN;
end

if nargin>2
    sz_lim=varargin{1,2};
else
    sz_lim=0;
end

%% CALC

dire=dir(fdir);
nf=numel(dire);

sz=0;
for kf=1:nf
    if any(strcmp(dire(kf).name,{'.','..'}))
        continue
    end

    if dire(kf).isdir
        sz_loc=dir_size(fullfile(dire(kf).folder,dire(kf).name),fid,sz_lim);
    else
        sz_loc=dire(kf).bytes;
    end
    sz=sz+sz_loc;
end %kf

%% WRITE

if ~isnan(fid) && sz>sz_lim
    fprintf(fid,'# folder: %s \r\n',fdir);
    fprintf(fid,'# size: %f MB, %f GB \r\n',sz/1e6,sz/1e9);
    fprintf(fid,'rm -rf %s \r\n',linuxify(fdir));
    fprintf(fid,' \r\n');
end

end %function