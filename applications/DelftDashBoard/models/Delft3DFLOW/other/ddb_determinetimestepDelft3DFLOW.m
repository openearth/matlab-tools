function timestep = ddb_determinetimestepDelft3DFLOW(x,y,z)

%% Valid for projected grids
dxx=diff(x,1,1);
dxy=diff(x,1,2);
dyx=diff(y,1,1);
dyy=diff(y,1,2);
distx=sqrt(dxx.^2+dyx.^2);
disty=sqrt(dxy.^2+dyy.^2);
mindelta=min(distx(:,2:end),disty(2:end,:));
dep=z(2:end,2:end);
dep(dep>0)=NaN;
dep = dep*-1;

% Criteria 1: stability flooding
timestep1 = min(min(2*mindelta/5))/60;

% Criteria 2: barotropic mode
% Easy
timestep2a = min(min(5*mindelta./sqrt(dep*9.81)))/60;

% Hard
dxdyterm = power(distx(:,2:end),-2) + power(disty(2:end,:),-2);
term2 = power((9.81.*dep.*dxdyterm),0.5);
timesteps = 5./ term2;
timestep2b = min(min(timesteps)) / 60;

% Check
% figure; pcolor(courantnumbers); caxis([0 10]); colormap(jet); shading flat;
% courantnumbers = 2*120*term2;
% ;

% Output
out = min(timestep1, timestep2b);

timestep = round(out,0);
if timestep < 1
timestep = round(out,1);
end
    

