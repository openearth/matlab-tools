function [ladiff] = convergence2intialconditions(varargin)

if nargin~=1, error('Matlab:Whatyadoing','Too many input arguments'); end
restartRun = varargin{1};

% SpUpend = find([restartRun.info.Uvel{:,1}]==0,1,'last');
SpUpend = length(restartRun.info.dps);

for i=0:1:SpUpend-1
%   ladiff.uvel{i,1} = restartRun.info.Uvel{1+i,1};
%   ladiff.uvel{i,3} = restartRun.info.Uvel{1+i,2}-restartRun.info.Uvel{1,2};
%   ladiff.uvel{i,2} = norm(ladiff.uvel{i,3}); 
%   ladiff.uvel{i,4} = i;
%   
%   ladiff.vvel{i,1} = restartRun.info.Vvel{1+i,1};
%   ladiff.vvel{i,3} = restartRun.info.Vvel{1+i,2}-restartRun.info.Vvel{1,2};
%   ladiff.vvel{i,2} = norm(ladiff.vvel{i,3}); 
%   ladiff.vvel{i,4} = i; 
  
  ladiff.dps{i+1,1} = restartRun.info.dps{1+i,1};
  ladiff.dps{i+1,3} = restartRun.info.dps{1+i,2}-restartRun.info.dps{1,2};
  ladiff.dps{i+1,2} = norm(ladiff.dps{i+1,3}); 
  ladiff.dps{i+1,4} = i;
end