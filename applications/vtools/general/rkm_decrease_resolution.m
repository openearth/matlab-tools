%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18475 $
%$Date: 2022-10-24 11:56:13 +0200 (Mon, 24 Oct 2022) $
%$Author: chavarri $
%$Id: plot_map_2DH_01.m 18475 2022-10-24 09:56:13Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/plot_map_2DH_01.m $
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
%     rkm_br=cat(1,rkm_br,{'BR'});
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