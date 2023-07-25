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

function [strsoft_lin,strsoft_win]=D3D_bat(simdef,fpath_software,varargin)

%% 

dire_sim=simdef.D3D.dire_sim;
structure=simdef.D3D.structure;
% fname_mdu=simdef.runid.name; %runid does not have the extension!
if isfield(simdef.file,'mdfid') %this is the correct one. It is the mdf file name. 
    runid=simdef.file.mdfid;
else
    runid=simdef.runid.name; %backward compatibility
end
OMP_num=simdef.D3D.OMP_num;

%2DO: add option that if <structure> does not exist, it searches in the directory.

% [~,~,ext]=fileparts(fname_mdu);
% switch ext
%     case '.mdu'
%         structure=2;
%     case '.mdf'
%         structure=1;
%     otherwise
%         error('not sure what structure is file %s',fname_mdu)
% end

switch structure
    case 1
        ext='.mdf';
    case 2
        ext='.mdu';
    otherwise
        error('do something')
end
fname_mdu=sprintf('%s%s',runid,ext);

%% PARSE

parin=inputParser;

switch structure
    case 1 
        addOptional(parin,'dimr','config_d_hydro.xml');
    case 2
        addOptional(parin,'dimr','dimr_config.xml');
end
addOptional(parin,'check_existing',true)

parse(parin,varargin{:});

dimr_str=parin.Results.dimr;
check_existing=parin.Results.check_existing;

%%

if strcmp(fpath_software(end),'\') || strcmp(fpath_software(end),'/')
    fpath_software(end)='';
end

fpath_dimr=fullfile(dire_sim,dimr_str);

%% dimr

D3D_xml(fpath_dimr,fname_mdu,'check_existing',check_existing)

%% batch

[strsoft_lin,strsoft_win]=D3D_bat_write(dire_sim,fpath_software,dimr_str,structure,OMP_num);

end %function