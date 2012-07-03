function bnd=findboundarysectionsonregulargrid(xg,yg)

br=0;
% Find first boundary
for ii=1:size(xg,1)
    for jj=1:size(xg,2)
        if ~isnan(xg(ii,jj))
            ii1=ii;
            jj1=jj;
            br=1;
            break
        end
    end
    if br
        break
    end
end

% Now find boundaries going counter clockwise
dr='right';
nbnd=0;
ii=ii1;
jj=jj1;
while 1
    switch dr
        case 'right'
            drc{1}='down';
            drc{2}='right';
            drc{3}='up';
        case 'up'
            drc{1}='right';
            drc{2}='up';
            drc{3}='left';
        case 'left'
            drc{1}='up';
            drc{2}='left';
            drc{3}='down';
        case 'down'
            drc{1}='left';
            drc{2}='down';
            drc{3}='right';
    end
    br=0;
    for idr=1:3
        switch drc{idr}
            case{'right'}
                if ii<size(xg,1)
                    if ~isnan(xg(ii+1,jj))
                        nbnd=nbnd+1;
                        ii2=ii+1;
                        jj2=jj;
                        dr=drc{idr};
                        br=1;
                    end
                end
            case{'up'}
                if jj<size(xg,2)
                    if ~isnan(xg(ii,jj+1))
                        nbnd=nbnd+1;
                        ii2=ii;
                        jj2=jj+1;
                        dr=drc{idr};
                        br=1;
                    end
                end
            case{'left'}
                if ii>1
                    if ~isnan(xg(ii-1,jj))
                        nbnd=nbnd+1;
                        ii2=ii-1;
                        jj2=jj;
                        dr=drc{idr};
                        br=1;
                    end
                end
            case{'down'}
                if jj>1
                    if ~isnan(xg(ii,jj-1))
                        nbnd=nbnd+1;
                        ii2=ii;
                        jj2=jj-1;
                        dr=drc{idr};
                        br=1;
                    end
                end
        end
        if br
            break
        end
    end
    switch dr
        case{'up','right'}
            bnd(nbnd).m1=ii;
            bnd(nbnd).n1=jj;
            bnd(nbnd).m2=ii2;
            bnd(nbnd).n2=jj2;
        case{'down','left'}
            bnd(nbnd).m1=ii2;
            bnd(nbnd).n1=jj2;
            bnd(nbnd).m2=ii;
            bnd(nbnd).n2=jj;
    end
    ii=ii2;
    jj=jj2;
    if ii2==ii1 && jj2==jj1
        % Went around, so break
        break
    end
end
