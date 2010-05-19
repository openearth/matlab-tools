function ddb_moveMouseChangeCoordinates(imagefig, varargins)

pos = get(gca, 'CurrentPoint');
posx=pos(1,1);
posy=pos(1,2);
xlim=get(gca,'xlim');
ylim=get(gca,'ylim');

if posx<=xlim(1) || posx>=xlim(2) || posy<=ylim(1) || posy>=ylim(2)
    ddb_updateCoordinateText([NaN NaN]);
else
    ddb_updateCoordinateText([posx posy]);
end
