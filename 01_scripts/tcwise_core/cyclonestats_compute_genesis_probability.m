function [pgenesis,vmax_avg,occ]=cyclonestats_compute_genesis_probability(s1,xg,yg,range)

% Get genesis coordinates
lon0    = squeeze(s1.lon(:,1));
lat0    = squeeze(s1.lat(:,1));
vmax0   = squeeze(s1.vmax(:,1));

% Determine heading
u0      = s1.u0(:,2);
v0      = s1.v0(:,2);
spd0    = sqrt(u0.^2+v0.^2);
phi0    = atan2(v0,u0);
phi0    = mod(phi0,2*pi);

% Compute area of search cells
maxrangegenesis     = range;
areagenesis         = pi*maxrangegenesis^2;
 
% Make space
nearby              = zeros(size(xg));
pgenesis            = zeros(size(xg));
vmax_avg            = zeros(size(xg));
occ(size(xg,1),size(xg,2)).vmax.occurrences=[];

% Get number of tracks
ntracks             = size(s1.vmax(:,1),1);

for ii=1:size(xg,1)
    for jj=1:size(xg,2)
        
        % Compute distance in kilometres from each grid point
        dst             = sqrt((111.0*cos(yg(ii,jj)*pi/180)*(lon0-xg(ii,jj))).^2 + (111.0*(lat0-yg(ii,jj))).^2);
        inrange         = find(dst<maxrangegenesis);
        nearby(ii,jj)   = length(inrange);
        pgenesis(ii,jj) = nearby(ii,jj)/s1.nryears/areagenesis; % Probability (occurences per year per km sq)
        vmax_avg(ii,jj) = nanmean(vmax0(inrange));
        
        % Save all variables (to sample from)
        occ(ii,jj).vmax.occurrences     = vmax0(inrange);
        occ(ii,jj).phi.occurrences      = phi0(inrange);
        occ(ii,jj).spd.occurrences      = spd0(inrange);

    end
end
ptotal      = sum(sum(pgenesis));
pgenesis    = pgenesis/ptotal;