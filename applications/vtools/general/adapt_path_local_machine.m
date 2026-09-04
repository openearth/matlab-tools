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
%
function fpath=adapt_path_local_machine(fpath,varargin)

if iscell(fpath)
    for kp=1:numel(fpath)
        fpath{kp}=adapt_path_local_machine_char(fpath{kp});
    end
else
    fpath=adapt_path_local_machine_char(fpath);
end

end %function

%%
%% FUNCTIONS
%%

function fpath=adapt_path_local_machine_char(fpath)
if isunix
    fpath=linuxify(fpath);
else
    fpath=winify(fpath);
end
end %function