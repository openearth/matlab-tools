function shpstr=muppet_findRawDataShape(sz)

% Makes shape string of data size vector

shpmat=[0 0 0 0 0];
% Time
if sz(1)>0
%     if timestep==0 || length(timestep)>1
%         shpmat(1)=2;
%     else
        shpmat(1)=1;
%     end
end
% Stations
if sz(2)>0
%     if istation==0 || length(istation)>1
%         shpmat(2)=2;        
%     else
        shpmat(2)=1;        
%     end
end
% M
if sz(3)>0
%     if m==0 || length(m)>1
%         shpmat(3)=2;        
%     else
        shpmat(3)=1;        
%     end
end
% N
if sz(4)>0
%     if n==0 || length(n)>1
%         shpmat(4)=2;        
%     else
        shpmat(4)=1;        
%     end
end
% K
if sz(5)>0
%     if k==0 || length(k)>1
%         shpmat(5)=2;        
%     else
        shpmat(5)=1;        
%     end
end

for ii=1:5    
    shpstr(ii)=num2str(shpmat(ii));
end
