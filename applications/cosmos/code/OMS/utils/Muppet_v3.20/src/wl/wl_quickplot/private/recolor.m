function recolor(colit,FClr,TClr)
%RECOLOR Replaces one color by another color.
%   RECOLOR(Handle,FromColor,ToColor) replace the FromColor by the ToColor
%   for the graphics object represented by Handle and its child objects.
%
%   Example
%      L = plot(sin(0:.1:10));
%      recolor(gcf,get(L,'color'),[0.8 0 0.6])
%      recolor(gcf,get(gca,'xcolor'),[0.4 0 0.3])
%      recolor(gcf,get(gca,'color'),[1 0.8 0.95])
%      recolor(gcf,get(gcf,'color'),[0.9 0.5 0.8])

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
