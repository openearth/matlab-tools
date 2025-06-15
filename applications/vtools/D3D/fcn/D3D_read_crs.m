%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%$Revision:  $
%$Date:  $
%$Author:  $
%$Id: $
%$HeadURL:  $
%

function stru_out=D3D_read_crs(fname, G, varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'ver',1)

parse(parin,varargin{:})

ver=parin.Results.ver;

stru_out=delft3d_io_crs('read',fname,G);
if ver == 2; 
    wkt = {}; 
    for k = 1:stru_out.NTables; 
        Ttemp = sprintf(' %f %f,', [stru_out.x{k}(1:end-1); stru_out.y{k}(1:end-1)]);
        wkt{k} = ['MultiLineString (( ',Ttemp(1:end-1), '))'];
    end
    stru_out = table(deblank({stru_out.DATA.name}).', stru_out.m(1,:).', stru_out.n(1,:).', stru_out.m(2,:).', stru_out.n(2,:).', wkt.', 'VariableNames', {'Name', 'M1', 'N1', 'M2', 'N2', 'WKT'});
end

end