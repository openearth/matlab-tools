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
%Copy file with check
%
%copyfile_check(source_f,destin_f,0,1) %do not break, overwrite

function [sts,msg]=copyfile_check(source_f,destin_f,varargin)

switch numel(varargin)
    case 0
        do_break=false;
        overwrite=true;
    case 1
        do_break=varargin{1,1};
        overwrite=true;
    case 2
        do_break=varargin{1,1};
        overwrite=varargin{1,2};
end

if isfile(destin_f) 
    if ~overwrite
        messageOut(NaN,sprintf('File exist, not copying: %s',source_f));
        return
    else
        messageOut(NaN,sprintf('File exist, overwriting: %s',source_f));
    end
end

messageOut(NaN,sprintf('starting to copy file: %s',source_f));
[sts,msg]=copyfile(source_f,destin_f);
if ~sts
    if do_break
        error(msg)
    else
        fprintf('%s \n',msg);
    end
else
    messageOut(NaN,sprintf('file copied to: %s',destin_f));
end
    
end %function
    