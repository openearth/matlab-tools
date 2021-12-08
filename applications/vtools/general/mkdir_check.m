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

function mkdir_check(path_dir,varargin)

switch numel(varargin)
    case 0
        fid_log=NaN;
    case 1
        fid_log=varargin{1,1};
end

if exist(path_dir,'dir')~=7
    [status,msg]=mkdir(path_dir);
    if status==1
        messageOut(fid_log,sprintf('folder created: %s',path_dir))
    else
        messageOut(fid_log,sprintf('Could not create folder %s because %s \n',path_dir,msg));
    end
end

end