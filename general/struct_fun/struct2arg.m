function A = struct2arg(S)
%struct2arg write structure as <field,value> pairs
%
%  A = struct2arg(S)
%
%    Example:
%      clear s, s.category = 'tree'; s.height = 37.4; s.name = 'birch';
%      args = struct2arg(s)
%      s2 = struct(args{:})
%      isequalwithequalnans(s, s2)
%
%See also cell2struct, fieldnames, setproperty, varargin, struct, mergestructs, cell2arg

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%%
% obtain values
v = struct2cell(S);
% obtain field names
n = fieldnames(S);

if ~isscalar(S)
    % get size; first dimension corresponds to the number of field names
    s = size(v);
    idx = repmat({':'}, 1, ndims(v)-1);
    % combine values as combined cell array for each field
    % reshape operation removes first dimension (squeeze is not suitable
    % because possible other singleton dimensions are also removed, which
    % might be not intended)
    v = cellfun(@(x) reshape(v(x, idx{:}), s(2:end)), num2cell(1:length(n)),...
        'UniformOutput', false);
end

% reshape to row vector of <field,value> pairs
A = reshape([n v(:)]', 1, []);