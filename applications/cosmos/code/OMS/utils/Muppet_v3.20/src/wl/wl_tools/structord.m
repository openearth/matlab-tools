function bar = structord(foo)
% STRUCTORD Sort structure fieldnames alphabetically
%      T=STRUCTORD(S)
%      sorts the fieldnames of S alphabetically giving
%      a new structure T.
%
%      Example:
%
%      S.b=1;
%      S.a=2
%      % S = 
%      %     b: 1
%      %     a: 2
%      T=STRUCTORD(S)
%      % T = 
%      %     a: 2
%      %     b: 1

% by nabeel@mathworks.com

Dimensions = size(foo);  
foo = foo(:);
[f,ix] = sort(fieldnames(foo));
v = struct2cell(foo);
bar = cell2struct(v(ix,:),f,1);  
bar = reshape(bar,Dimensions);
