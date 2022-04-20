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

function save_check(fpath_mat,str_save,varargin)

%% PARSE

% parin=inputParser;
% 
% addOptional(parin,'version',[]);
% 
% parse(parin,varargin{:});
% 
% time_dnum=parin.Results.tim;

%% CALC

[fdir,fname,fext]=fileparts(fpath_mat);
mkdir_check(fdir);
if isempty(fname)
    fpath_mat=fullfile(fdir,sprintf('matfile_%f.mat',datenum(datetime('now'))));
end
if strcmp(fext,'.mat')==0
    messageOut(NaN,'extension is not .mat and has been changed')
end

aux_var=evalin('caller',str_save); %variable value in the main function corresponding to the variable name
feval(@()assignin('caller',str_save,aux_var)) %rename such that the variable name goes with its variable value
wh=whos(str_save);
if wh.bytes>2e9
    save(fpath_mat,str_save,'-v7.3')
    ver_str='7.3';
else
    save(fpath_mat,str_save)
    ver_str='7';
end
messageOut(NaN,sprintf('file saved in format version %s: %s',ver_str,fpath_mat));

end