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

function [sts,msg]=copyfile_check(source_f,destin_f)

    messageOut(NaN,sprintf('starting to copy file: %s',source_f));
    [sts,msg]=copyfile(source_f,destin_f);
    if ~sts
        fprintf('%s \n',msg);
    else
        messageOut(NaN,sprintf('file copied to: %s',destin_f));
    end
    
end %function
