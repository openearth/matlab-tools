function [x0,y0,t0]=cyclonestats_cyclogenesis(cyclones_per_year_in_basin,xg,yg,pgenesis,tgenesis,nyears)
disp('Start cyclonestats_cyclogenesis.m')

seedrng = rng;
disp(['   used Matlab seed by TCWiSE is: ',num2str(seedrng.Seed)])

% Find matching times
numberperyear = TC_poisson(cyclones_per_year_in_basin,nyears);
countTCs      = 0;
for ii = 1:length(numberperyear)
    for jj = 1:numberperyear(ii)
        dayofyear=round(hit_and_mis(tgenesis.f, tgenesis.x));
        if dayofyear < 1; x1 = 1; end
        if dayofyear > 365; x1 = 356; end
        countTCs = countTCs+1;
        t0(countTCs) = datenum(1900+ii,1,1) + dayofyear;
    end
end
t0 = sort(t0);

% Get a certain amount of tracks
ntracks=length(t0);
P=reshape(pgenesis,[1 size(pgenesis,1)*size(pgenesis,2)]);
X = randp(P,[1 ntracks]);
[m,n] = ind2sub(size(pgenesis),X);
x0=zeros(1,ntracks);
y0=zeros(1,ntracks);
dxg=xg(1,2)-xg(1,1);
dyg=yg(2,1)-yg(1,1);
for ic=1:ntracks    
    x0(ic)=xg(m(ic),n(ic))+dxg*(rand(1)-0.5);
    y0(ic)=yg(m(ic),n(ic))+dyg*(rand(1)-0.5); 
end