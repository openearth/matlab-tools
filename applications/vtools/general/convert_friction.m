%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18596 $
%$Date: 2022-12-05 11:26:15 +0100 (ma, 05 dec 2022) $
%$Author: chavarri $
%$Id: plot_1D_01.m 18596 2022-12-05 10:26:15Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/plot_1D_01.m $
%
%

function Cf=convert_friction(conv,C_in,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'g',9.81,@isnumeric);

parse(parin,varargin{:});

g=parin.Results.g;

%% CALC

switch conv
    case 'C2Cf'
        Cf=g./C_in.^2;
    otherwise
        error('do')
end

end