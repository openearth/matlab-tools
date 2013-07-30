function plotparallel(G,D,varargin)
% parallel version of plotMAP

if ( iscell(G) )
    ndomains = length(G)
    for i=1:ndomains
        if ( nargin>2 )
            dflowfm.plotMap(G{i},D{i},varargin)
        else
            dflowfm.plotMap(G{i},D{i})
        end
        hold all
    end
else
end