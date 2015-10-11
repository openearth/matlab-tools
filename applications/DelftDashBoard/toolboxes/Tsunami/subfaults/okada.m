
function [X,Y,dZ,times] = okada(subfaults, x, y, varargin)
% okada   Calculate the deformation from a collection of subfaults
%
% [X,Y,dZ,times] = okada(subfaults, x, y)
%
% Inputs:
%       subfaults: a structure containing fault parameters read from a
%           subfault file.
%       x,y: 1-d arrays longitude (x) and latitude (y) that define the
%           rectilinear grid onto which deformation will be calculated.
%
% Outputs:
%       X,Y: arrays of longitude and latitude, derived from x and y
%       dZ: arrays of the vertical deformation calculated using Okada.
%           (M,N,K)
%       times: array of times (in seconds), corresponding to each
%           dZ array from 1:K
%   
%       
% See Okada 1985 [Okada85]_, or Okada 1992, Bull. Seism. Soc. Am.
%         
% This code was adapted from functions in CLawpack 5.3.0, which were 
% written in Python for GeoClaw by Dave George and Randy LeVeque. 
% See www.clawpack.org:
% M. J. Berger, D. L. George, R. J. LeVeque and K. M. Mandli, 
% The GeoClaw software for depth-averaged flows with adaptive refinement, 
% Advances in Water Resources 34 (2011), pp. 1195-1206.
% 
% Written in Matlab by SeanPaul La Selle, USGS102015
% Last updated 13 July, 2015

ifault1=1;
ifault2=numel(subfaults.dip);
for ii=1:length(varargin)
    if ischar(varargin{ii})
        switch lower(varargin{ii})
            case{'subfaultnumber'}
                ifault1=varargin{ii+1};
                ifault2=ifault1;
        end
    end
end

poisson = 0.25; % poisson ratio for okada
[X,Y] = meshgrid(x, y);   % use convention of upper case for 2d
dZ = zeros(size(X)); % initial empty array for deformation
reverseStr = ''; % initial empty string for progress text

% Loop through subfaults
for i=ifault1:ifault2
    
    % Display the progress
    percentDone = 100 * i / numel(subfaults.dip);
    
    if ifault2>ifault1
        msg = sprintf('calculating deformation for %i of %i subfaults', ...
            i,numel(subfaults.dip) );
        fprintf([reverseStr, msg]);
        reverseStr = repmat(sprintf('\b'),1, length(msg));
    end
    
    % Okada model assumes x,y are at bottom center:
    x_bottom = subfaults.centers{i,1}(3,1);
    y_bottom = subfaults.centers{i,1}(3,2);
    depth_bottom = subfaults.centers{i,1}(3,3);
    
    flength = subfaults.length(i);
    width = subfaults.width(i);
    depth = subfaults.depth(i);
    slip = subfaults.slip(i);
    
    halfL = 0.5*flength;
    w  =  width;
    
    % convert angles to radians:
    ang_dip = deg2rad(subfaults.dip(i));
    ang_rake = deg2rad(subfaults.rake(i));
    ang_strike = deg2rad(subfaults.strike(i));
    
    % Convert distance from (X,Y) to (x_bottom,y_bottom) from degrees to
    % meters:
    lat2meter = 6367.5e3 * (pi/180.); % radius of earth in meters
    xx = lat2meter * (cosd(Y) .* (X - x_bottom));
    yy = lat2meter * (Y - y_bottom);
    
    
    
    % Convert to distance along strike (x1) and dip (x2):
    x1 = (xx * sin(ang_strike)) + (yy * cos(ang_strike));
    x2 = (xx * cos(ang_strike)) - (yy * sin(ang_strike));
    
    % In Okada's paper, x2 is distance up the fault plane, not down dip:
    x2 = -x2;
    
    p = (x2 * cos(ang_dip)) + (depth_bottom * sin(ang_dip));
    q = (x2 * sin(ang_dip)) - (depth_bottom * cos(ang_dip));
    
    f1 = strike_slip(x1 + halfL, p,     ang_dip, q, poisson);
    f2 = strike_slip(x1 + halfL, p - w, ang_dip, q, poisson);
    f3 = strike_slip(x1 - halfL, p,     ang_dip, q, poisson);
    f4 = strike_slip(x1 - halfL, p - w, ang_dip, q, poisson);
    
    g1=dip_slip(x1 + halfL, p,     ang_dip, q, poisson);
    g2=dip_slip(x1 + halfL, p - w, ang_dip, q, poisson);
    g3=dip_slip(x1 - halfL, p,     ang_dip, q, poisson);
    g4=dip_slip(x1 - halfL, p - w, ang_dip, q, poisson);
    
    % Displacement in direction of strike and dip:
    ds = slip * cos(ang_rake);
    dd = slip * sin(ang_rake);
    
    us = (f1 - f2 - f3 + f4) * ds;
    ud = (g1 - g2 - g3 + g4) * dd;
    
    dZ1 = ud+us;
    dZ = dZ+dZ1;
    times = (0.);
end
end

%%
function y = deg2rad(x)
%Convert degrees to radians
y = x * (pi/180);
end

%%
function f = strike_slip(y1, y2, ang_dip, q, poisson)
% Used for Okada's model
% Methods from Yoshimitsu Okada (1985)
sn = sin(ang_dip);
cs = cos(ang_dip);
d_bar = (y2*sn) - (q*cs);
r = sqrt(y1.^2 + y2.^2 + q.^2);
xx = sqrt(y1.^2 + q.^2);
a4 = 2 * (poisson/cs) * (log(r+d_bar) - sn.*log(r+y2));
f = -(d_bar.*q./r./(r+y2) + (q.*sn./(r+y2)) + (a4.*sn))./(2.0*3.14159);
end

%%
function g = dip_slip(y1, y2, ang_dip, q, poisson)
% Used for Okada's model
% Methods from Yoshimitsu Okada (1985)
sn = sin(ang_dip);
cs = cos(ang_dip);
d_bar = y2*sn - q*cs;
r = sqrt(y1.^2 + y2.^2 + q.^2);
xx = sqrt(y1.^2 + q.^2);
a5 = 4.0*poisson/cs*atan((y2.*(xx+q.*cs)+xx.*(r+xx).*sn)./y1./(r+xx)./cs);
g = -(d_bar.*q./r./(r+y1) + sn*atan(y1.*y2./q./r) - a5.*sn.*cs)/(2.0*3.14159);
end
