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

function stru_out=D3D_read_polys(fname,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'ver',2)

parse(parin,varargin{:})

ver=parin.Results.ver;

%%

tek=tekal('read',fname,'loaddata');

switch ver
    case 1
        stru_out.name={tek.Field.Name};
        stru_out.val={tek.Field.Data};
    case 2
        stru_out=struct('name',{tek.Field.Name},'xy',{tek.Field.Data});
    case {3,4}
    %     stru_out=tek.Field.Data;
        stru_out=polcell2nan({tek.Field.Data}');
    otherwise
        error('Unknonw version')
end

                
end %function