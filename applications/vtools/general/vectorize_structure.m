%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18945 $
%$Date: 2023-05-15 14:17:04 +0200 (Mon, 15 May 2023) $
%$Author: chavarri $
%$Id: plot_map_2DH_01.m 18945 2023-05-15 12:17:04Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/plot_map_2DH_01.m $
%
%
%All arrays in a structure are turned into a column vector. 

function stru_out=vectorize_structure(stru_in)

%% PARSE

if ~isstruct(stru_in)
    error('Input is not a structure.')
end

%% CALC

stru_out=stru_in;
fn=fieldnames(stru_out);
nf=numel(fn);
for kf=1:nf
    if isnumeric(stru_out.(fn{kf}))
        stru_out.(fn{kf})=reshape(stru_out.(fn{kf}),1,[]);
    end
end

end %function