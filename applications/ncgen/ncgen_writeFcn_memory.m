function varargout = ncgen_writeFcn_memory(method,data)
% function meant to use ncgen functions to read datafiles to matlab (and not
% write to nc)

% Call this function as
% writeFcn = @(OPT,data) memWriteFcn(OPT,data)


if isstruct(method)
    method = 'append';
end

persistent DATA

switch method
    case 'append'
        if isempty(DATA)
            DATA = data;
        else
            varname = fieldnames(data);
            for in= 1:numel(varname)
                DATA.(varname{in}) = [DATA.(varname{in}); data.(varname{in})];
            end
        end
    case 'initialize'
        clear DATA
    case 'return'
        varargout = {DATA};
        clear DATA
    otherwise
        error('Invalid method: %s',OPT.method);
end

