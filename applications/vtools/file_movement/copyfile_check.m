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
%copy file with check

function [sts,msg]=copyfile_check(source_f,destin_f,varargin)

switch numel(varargin)
    case 0
        do_break=false;
    case 1
        do_break=varargin{1,1};
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
