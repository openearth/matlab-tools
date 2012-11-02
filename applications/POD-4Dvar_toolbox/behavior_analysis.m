function [tbeh] = behavior_analysis(varargin)
  
d3dRun = varargin{1};

for iTime = 1:1:length(d3dRun.info.Uvel)-1
  tbeh.Uvel(iTime,1) = d3dRun.info.Uvel{iTime,1};
  tbeh.Uvel(iTime,2) = norm(d3dRun.info.Uvel{iTime+1,2}-d3dRun.info.Uvel{iTime,2},'fro');
end

for iTime = 1:1:length(d3dRun.info.Vvel)-1
  tbeh.Vvel(iTime,1) = d3dRun.info.Vvel{iTime,1};
  tbeh.Vvel(iTime,2) = norm(d3dRun.info.Vvel{iTime+1,2}-d3dRun.info.Vvel{iTime,2},'fro');
end

for iTime = 1:1:length(d3dRun.info.dps)-1
  tbeh.dps(iTime,1) = d3dRun.info.dps{iTime,1}; 
  tbeh.dps(iTime,2) = norm(d3dRun.info.dps{iTime+1,2}-d3dRun.info.dps{iTime,2},'fro');
end