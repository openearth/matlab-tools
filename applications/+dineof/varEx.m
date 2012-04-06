function [varex,labels] = varEx(fname)
%varEx read explained variance
%
% varex = dineof.varEx(fname)
%
%See also: dineof

[labels]=textread(fname,'%s','whitespace','\n');
try
  [number,varex,~]=textread(fname,'Mode %d=%f %s');
  for i=1:length(varex)
    labels{i} = ['Mode ',num2str(i,'%d'),' = ',num2str(varex(i),'%0.1f'),' %'];
  end
catch
  varex(1:length(labels)) = nan; % in case of ***
end
