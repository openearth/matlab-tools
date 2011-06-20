function ax2=relaxes(ax1,pos),
% RELAXES create a axes with relative position
%
%   NewAxesHandle=relaxes(AxesHandle,RelativePosition)

ax1pos=get(ax1,'position');
ax1unt=get(ax1,'units');
ax2pos=[ax1pos(1)+pos(1)*ax1pos(3) ax1pos(2)+pos(2)*ax1pos(4) ...
        ax1pos(3)*pos(3)           ax1pos(4)*pos(4)];
ax2=axes('parent',get(ax1,'parent'), ...
         'units',ax1unt, ...
         'position',ax2pos);
