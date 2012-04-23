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
%See also cell2struct, fieldnames, setproperty, varargin, struct, mergestructs

v = struct2cell(S);
n = fieldnames(S);
A = {n{:};v{:}};
A = {A{:}};