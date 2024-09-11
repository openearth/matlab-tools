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
addOptional(parin,'empty2NaN',1)

parse(parin,varargin{:})

ver=parin.Results.ver;
empty2NaN=parin.Results.empty2NaN;

%%

tek=tekal('read',fname,'loaddata');

Data={tek.Field.Data};
if empty2NaN
    for i = 1:numel(Data)
        Data{i}( (Data{i}(:,1)==999.999) & (Data{i}(:,2)==999.999) ,:)=NaN;
    end
end

switch ver
    case 1
        stru_out.name={tek.Field.Name};
        stru_out.val=Data;
    case 2
        stru_out=struct('name',{tek.Field.Name},'xy',Data);
    case {3,4}
    %     stru_out=tek.Field.Data;
        stru_out=polcell2nan(Data');
    otherwise
        error('Unknonw version')
end

                
end %function