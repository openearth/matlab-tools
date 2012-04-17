function varargout = ncgen_writeFcn_memory(OPT,data,varargin)
% funtion meant to use ncgen functions to read datafiles to matlab (and not
% write to nc)

% Call this function as
% writeFcn = @(OPT,data) memWriteFcn(OPT,data,'method','Append')

OPT.method = 'Append'


if ~exist(DATA)
    DATA= persistent
end
varname = fieldnames(data);
switch OPT.method
    case 'Append'
        for in= 1:numel(varname)
        DATA.(varname{in}) = [DATA.(varname{in}) data.(varname{in})];
        end
    case 'ReturData'
        varagout = DATA
        clear DATA
end
    
        