%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%$Revision$
%$Date$
%$Author$
%$Id$
%$HeadURL$
%

function stru_out=D3D_write_crs(fname, stru_in, varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'ver',1)

parse(parin,varargin{:})

ver=parin.Results.ver;

if ver == 1; 
    delft3d_io_crs('write',fname,stru_in);
elseif ver == 2; 
    S.m = [stru_in.M1,  stru_in.M2].'; 
    S.n = [stru_in.N1,  stru_in.N2].'; 
    for k = 1:height(stru_in); 
        S.DATA(k).name = stru_in.Name{k};
    end
    delft3d_io_crs('write',fname,S);
else
    error('Unknown "ver" provided to D3D_write_crs.m')
end

end