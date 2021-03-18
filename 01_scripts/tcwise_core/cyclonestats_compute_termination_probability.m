function [ptermination,vmax_avg]=cyclonestats_compute_termination_probability(s,xg,yg,range)

t       = ~isnan(s.lon);
for i=1:size(t,1)
    ii          = find(t(i,:)==1,1,'last');
    lon0(i)     = s.lon(i,ii);
    lat0(i)     = s.lat(i,ii);
    vmax0(i)    = s.vmax(i,ii);
end

% Compute area of search cells
maxrangetermination = range;
areatermination     = pi*maxrangetermination^2;
nearby              = zeros(size(xg));
ptermination        = zeros(size(xg));
vmax_avg            = zeros(size(xg));
ntracks             = size(s.vmax(:,1),1);


for ii=1:size(xg,1)
    for jj=1:size(xg,2)
        % Compute distance in kilometres from each grid point
        dst                 = sqrt((111.0*cos(yg(ii,jj)*pi/180)*(lon0-xg(ii,jj))).^2 + (111.0*(lat0-yg(ii,jj))).^2);
        inrange             = find(dst<maxrangetermination);
        nearby(ii,jj)       = length(inrange);
        ptermination(ii,jj) = nearby(ii,jj)/s.nryears/areatermination; % Probability (occurences per year per km sq)
        vmax_avg(ii,jj)     = nanmean(vmax0(inrange));
    end
end
ptotal          = sum(sum(ptermination));
ptermination    = ptermination/ptotal;

