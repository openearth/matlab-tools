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

function stru_out=D3D_read_obs(fname, G, varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'ver',1)

parse(parin,varargin{2:end})

ver=parin.Results.ver;

stru_out=delft3d_io_obs('read',fname,G);

if ver == 2; 
    wkt = {}; 
    for k = 1:stru_out.NTables; 
        Ttemp = sprintf('Point ( %f %f )', [stru_out.x(k), stru_out.y(k)]);
        wkt{k} = Ttemp;
    end

    stru_out = table(cellstr(stru_out.namst), stru_out.m(:), stru_out.n(:), wkt.', 'VariableNames', {'Name', 'M', 'N', 'WKT'});
end

end