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
%Given a river-kilometer file, it decreases the resolution. 
%
%E.G.
%
% fpath_rkm='p:\11208034-014-kpp-vow-mor\07_data\01_rkm\rkm.csv';
% 
% rkm_v=854:2.5:867;
% nrkm=numel(rkm_v);
% rkm_br={};
% for krkm=1:nrkm
%     %by hand
%     rkm_br=cat(1,rkm_br,{'BR'});
%     %along rijntakken
%     br=branch_rijntakken(rkm_v(krkm),'WA');
%     rkm_br=cat(1,rkm_br,br);
% end
% 
% rkm_decrease_resolution(fpath_rkm,rkm_v,rkm_br)

function rkm_decrease_resolution(fpath_rkm,rkm_v,rkm_br,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'fpath_out','');

parse(parin,varargin{:});

fpath_out=parin.Results.fpath_out;

if isempty(fpath_out)
    [fdir,fname]=fileparts(fpath_rkm);
    fpath_out=fullfile(fdir,sprintf('%s_mod.csv',fname));
end

%%
xy=convert2rkm(fpath_rkm,reshape(rkm_v,[],1),reshape(rkm_br,[],1));

fid=fopen(fpath_out,'w');
nrkm=size(xy,1);
for krkm=1:nrkm
%     200267.031300008,431588.531300012,867.00_BR,867.0
    fprintf(fid,'%f,%f,%.2f_%s,%f \r\n',xy(krkm,1),xy(krkm,2),rkm_v(krkm),rkm_br{krkm},rkm_v(krkm));
end

fclose(fid);

end %function