function varargout = plotGoF_v2(STATS, varargin)
%PLOTGOF plots target diagram
%
% plots 'Goodness of Fit' target diagramas explained in:
% <a href="http://dx.doi.org/10.1016/j.jmarsys.2008.05.014">Jason K. Jolliff et al., 2009.</a> Summary diagrams for coupled hydrodynamic-
% ecosystem model skill assessment, Journal of Marine Systems 76 (2009) 64-82 .
%
%    plotGoF(STATS)
%
% where STATS is the result of GoFStats:
% STATS = GoFStats(D3DTimePoints, D3DValues, NetCDFTime, NetCDFValues, Info);
%
% Example:
% plotGoF(STATS, 'figure', 2);
%
%  Timeseries data definition:
%   * <a href="https://cf-pcmdi.llnl.gov/trac/wiki/PointObservationConventions">https://cf-pcmdi.llnl.gov/trac/wiki/PointObservationConventions</a> (full definition)
%   * <a href="http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#id2984788">http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#id2984788</a> (simple)
%
%See also: GOFSTATS, GOFTIMESERIES, http://dx.doi.org/10.1016/j.jmarsys.2008.05.014

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% Default values
load (['']) %load matfile from GoFStats_v2.m or when directly used after GoFStats_vs, no need and comment load.

OPT.figure   = 1;
OPT.R1       = 0.67;
OPT.R2       = 0.1; %radius innermost crcle
OPT.limfct   = 0.1;
OPT.tickvec  = -10:1:10; %default             tickvec=[-3:0.5:3];
OPT.colvec   = ['b', 'r', 'g', 'k'];
%OPT.markvec = ['x'];
OPT.markvec  = ['<'; '+'; 'o'; '*'; 'x'; 's'; 'd'; 'p'; 'h'; '^'; 'v'; '>'];
OPT.mrksiz   = [6; 7; 7; 7; 7; 7; 7; 7; 7; 6; 6; 6];
OPT.xmin     = -2; OPT.xmax = 2;
OPT.ymin     = -2; OPT.ymax = 2;


%% Plot statistics
figure(OPT.figure);
hold on;
axis([OPT.xmin OPT.xmax OPT.ymin OPT.ymax]);
set(gca, 'FontSize', 12);
plot(cos(0:0.1:2.1*pi), sin(0:0.1:2.1*pi), '-k', 'LineWidth', 0.5);
plot(0,0,'.k');
plot(sqrt(1-OPT.R1^2)*cos(0:0.1:2.1*pi), ...
    sqrt(1-OPT.R1^2)*sin(0:0.1:2.1*pi), '--k');
xlabel('RMSD''*');
ylabel('Bias*');
iCount = 1;
for iStation = 1:length(STATS)

if ((isreal(STATS(iStation).location.xTarget)) && ...
        (STATS(iStation).location.xTarget >= OPT.xmin) && ...
        (STATS(iStation).location.xTarget <= OPT.xmax) && ...
        (STATS(iStation).location.yTarget >= OPT.ymin) && ...
        (STATS(iStation).location.yTarget <= OPT.ymax))
    iCol = 1 + mod(ceil(iCount/length(OPT.colvec)), ...
        length(OPT.colvec));
    iMark = 1 + mod(iCount, length(OPT.markvec));
    plot(STATS(iStation).location.xTarget, STATS(iStation).location.yTarget, ...
        [OPT.colvec(iCol) OPT.markvec(iMark)], ...
        'MarkerFaceColor', OPT.colvec(iCol), ...
        'MarkerSize', OPT.mrksiz(iMark));
    text(STATS(iStation).location.xTarget, STATS(iStation).location.yTarget, ...
        ['  ' STATS(iStation).location.obs_name], ...
        'Color', OPT.colvec(iCol));
    iCount = iCount + 1;
end
end
hold off;

return;
% end
%% EOF
