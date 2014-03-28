function [xb_sg] = xb_shipgeom(iship,varargin)
OPT.L            = 0.825*280;
OPT.B            = 1.14*28;
OPT.D            = 15;
OPT.shipdep      = 'mooredship.dep';
OPT.nx           = 280;
OPT.ny           = 28;
OPT.dx           = 0.825;
OPT.dy           = 1.14;
OPT.track        = sprintf('track%03d.txt', iship);
OPT.flying       = 0;
OPT = setproperty(OPT,varargin{:});

% Read ship depfile
dsh = wldep('read',OPT.shipdep,[OPT.nx+2,OPT.ny+2]);
dsh(dsh==-999) = NaN;
dsh = dsh*OPT.D/max(dsh(:));  

% Compute ship grid
OPT.dx = OPT.L/OPT.nx;
OPT.dy = OPT.B/OPT.ny;

xb_sg = xs_empty;
xb_sg = xs_meta(xb_sg, mfilename, 'ship', 'allships.txt');
xb_sg = xs_set(xb_sg, 'nx', OPT.nx);
xb_sg = xs_set(xb_sg, 'ny', OPT.ny);
xb_sg = xs_set(xb_sg, 'dx', OPT.dx);
xb_sg = xs_set(xb_sg, 'dy', OPT.dy);
xb_sg = xs_set(xb_sg, 'shipgeom', OPT.shipdep);
xb_sg = xs_set(xb_sg, 'shiptrack', OPT.track);
xb_sg = xs_set(xb_sg, 'flying', OPT.flying);