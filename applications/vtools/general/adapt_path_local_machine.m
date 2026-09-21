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
function fpath=adapt_path_local_machine(fpath)

if iscell(fpath)
    for kp=1:numel(fpath)
        fpath{kp}=adapt_path_local_machine_char(fpath{kp});
    end
elseif isstruct(fpath)
    fn=fieldnames(fpath);
    fpath=cellfun(@adapt_path_local_machine_char,struct2cell(fpath),'UniformOutput',false);
    fpath=cell2struct(fpath,fn);
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