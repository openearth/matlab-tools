function setTextPosition(tx,pos,textpos)

ext=get(tx,'Extent');
hgt=15;
switch lower(textpos)
    case{'left'}
        txtpos=[pos(1)-ext(3)-5 pos(2)+1 ext(3) hgt];
        horal='right';
    case{'right'}
        txtpos=[pos(1)+pos(3)+5 pos(2)+1 ext(3) hgt];
        horal='left';
    case{'above-left'}
        txtpos=[pos(1) pos(2)+pos(4)+1 ext(3) hgt];
        horal='left';
    case{'above-right'}
        txtpos=[pos(1)+pos(3)-ext(3) pos(2)+pos(4)+1 ext(3) hgt];
        horal='right';
    case{'above-center'}
        txtpos=[pos(1)+0.5*pos(3)-0.5*ext(3) pos(2)+pos(4)+1 ext(3) hgt];
        horal='center';
end
set(tx,'Position',txtpos,'HorizontalAlignment',horal);
