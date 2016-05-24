clear all; close all;
inlet = 'AME';
cd(['d:\til\Afstuderen Documents\Data, Matlab\MUP_figures\basin\' char(inlet) '\'])
% years=[1933,1951,1965,1972,1977,1983,1986ic,1988,1991ic,1992ic,1993ic,1998ic,2000,2002ic,2003ic,2004ic,2006];
years=[1925,1926,1950,1967,1972,1978,1984,1989,1993,1999,200405,2005];
lt = length(years)

% read the polygon
tek =tekal('read',[char(inlet) '_binnen_tot.ldb'])
pol = tek.Field.Data;
xv = pol(:,1);
yv = pol(:,2);
Nv = length(xv);
tek =tekal('read',[char(inlet) '_binnen_tot.ldb'])
pol = tek.Field.Data;
xe = pol(:,1);
ye = pol(:,2);
Ne = length(xe);
% If (xv,yv) is not closed, close it.
if ((xv(1) ~= xv(Nv)) || (yv(1) ~= yv(Nv)))
    xv = [xv ; xv(1)];
    yv = [yv ; yv(1)];
    Nv = Nv + 1;
end
if ((xe(1) ~= xe(Ne)) || (ye(1) ~= ye(Ne)))
    xe = [xe ; xe(1)];
    ye = [ye ; ye(1)];
    Ne = Ne + 1;
end

reread = 1
if reread

    GRID = wlgrid('read',[char(inlet) '.grd'])
    x = GRID.X;
    y = GRID.Y;

    mme1 = size(x,1)
    mme2 = size(x,2)

    for jj = lt%1:lt
        fname = [char(inlet) num2str(years(jj)) '.dep']
        dp{jj} = wldep('read',char(fname),GRID);
        dp{jj}(dp{jj} < -200) = NaN;
        dp{jj}(dp{jj} > 0)    = NaN;
        yearname = num2str(years(jj))
        %get the data in the polygon
        % ***********************************************************
        %% create X, Y grids and select the points in the polygon
        %polygon1
        inbounds = x.*0;
        M = numel(x);
        block_length = 1e5;
        if M*Nv < block_length
            in = vec_inpolygon(Nv,x,y,xv,yv);
        else
            % Process at most N elements at a time
            N = ceil(block_length/Nv);
            in = false(1,M);
            n1 = 0;  n2 = 0; %#ok<NASGU>
            wH=waitbar(0,'Processing INPOLYGON2 request ...');
            while n2 < M,
                n1 = n2+1;
                n2 = n1+N;
                if n2 > M,
                    n2 = M;
                end

                waitbar(n2/M,wH,'Processing INPOLYGON2 request ...'); %#ok<NBRAK>
                in(n1:n2) = vec_inpolygon(Nv,x(n1:n2),y(n1:n2),xv,yv);
            end
            close(wH)
        end
        % Reshape output matrix.
        disp('        Reshaping output matrix of INPOLYGON2')
        in = reshape(in, size(x));
        disp('        Reshaping ready')
        % ***********************************************************
        dps{jj}= in.*dp{jj}(1:mme1,1:mme2);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        clear in M

        %polygon2
        inbounds = x.*0;
        M = numel(x);
        block_length = 1e5;
        if M*Nv < block_length
            in = vec_inpolygon(Ne,x,y,xe,ye);
        else
            % Process at most N elements at a time
            N = ceil(block_length/Ne);
            in = false(1,M);
            n1 = 0;  n2 = 0; %#ok<NASGU>
            wH=waitbar(0,'Processing INPOLYGON2 request ...');
            while n2 < M,
                n1 = n2+1;
                n2 = n1+N;
                if n2 > M,
                    n2 = M;
                end

                waitbar(n2/M,wH,'Processing INPOLYGON2 request ...'); %#ok<NBRAK>
                in(n1:n2) = vec_inpolygon(Ne,x(n1:n2),y(n1:n2),xe,ye);
            end
            close(wH)
        end
        % Reshape output matrix.
        disp('        Reshaping output matrix of INPOLYGON2')
        in = reshape(in, size(x));
        disp('        Reshaping ready')
        % ***********************************************************
        dpetd{jj}= in.*dp{jj}(1:mme1,1:mme2);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end

    %get sedero subsequent years
    for i = 1:lt-1
        se{i}.val  = dp{i+1} - dp{i};
        sc{i}.val  = dps{i+1} - dps{i};
        setd{i}.val  = dpetd{i+1} - dpetd{i};
        se{i}.yrs  = [num2str(years(i+1)) '-' num2str(years(i))]; sc{i}.yrs  = se{i}.yrs; setd{i}.yrs  = se{i}.yrs;

        % wldep('write',['se' num2str(years(i+1)) '_' num2str(years(i)) '.dep'],se{i}.val)
        wldep('write',['sc' num2str(years(i+1)) '_' num2str(years(i)) '.dep'],sc{i}.val)
        % wldep('write',['setd' num2str(years(i+1)) '_' num2str(years(i)) '.dep'],setd{i}.val)
    end

    %get sedero custom
    ys1 = [10];%1994-1971 %1971-1925 %2006-1994
    ys2 = [1]
    pln = {'se','sc','setd'};

    for tt = 1:length(ys1)
        i = i+1;
        se{i}.val = dp{ys1(tt)} - dp{ys2(tt)};
        sc{i}.val = dps{ys1(tt)} - dps{ys2(tt)};
        setd{i}.val = dpetd{ys1(tt)} - dpetd{ys2(tt)};


        se{i}.yrs  = [num2str(years(ys1(tt))) '-' num2str(years(ys2(tt)))];

        wldep('write',['se' num2str(years(ys1(tt))) '_' num2str(years(ys2(tt))) '.dep'],se{i}.val)
        wldep('write',['sc' num2str(years(ys1(tt))) '_' num2str(years(ys2(tt))) '.dep'],sc{i}.val)
        wldep('write',['setd' num2str(years(ys1(tt))) '_' num2str(years(ys2(tt))) '.dep'],setd{i}.val)
    end

    keep years x y se sc setd dp dps dpetd xv xe yv ye mme1 mme2 inlet
    save mdb_ame
else
    load('mdb_ame.mat');
end

%determine the sed-ero volumes
for i = 1:length(se)
    dvyears(i,:) = se{i}.yrs

    dv(i,1)  = nansum(nansum(se{i}.val))*40*40;
    dv(i,2)  = nansum(nansum(sc{i}.val))*40*40;
    dv(i,3)  = nansum(nansum(setd{i}.val))*40*40;
    %    dv=dv'

end
dv/1e6

%overview plot
step=10
lt = length(years)
figure(1)
for i =1:lt
    subplot(3,4,i)
    hold on
    pa=2;
    collim=[-25 5];
    plot(xv/1000,yv/1000,'r');
    plot(xe/1000,ye/1000,'r');

    a1=surf(x(1:step:mme1,1:step:mme2)/1000,y(1:step:mme1,1:step:mme2)/1000,dp{i}(1:step:mme1,1:step:mme2))
    shading flat%interp
    caxis([-25 5])
    axis equal
    view(2)
    title(num2str(years(i)));
end
md_paper('landscape');
print('-dpng','-zbuffer','-r300',['dp_' char(inlet) '.png'])
close

%complete bathy (1 plot/file)
step=10
lt = length(years)
for i =1:lt
    figure(i)
    hold on
    pa=2;
    collim=[-25 5];
    plot(xv/1000,yv/1000,'r');
    plot(xe/1000,ye/1000,'r');

    a1=surf(x(1:step:mme1,1:step:mme2)/1000,y(1:step:mme1,1:step:mme2)/1000,dp{i}(1:step:mme1,1:step:mme2))
    shading flat%interp
    caxis([-25 5])
    axis equal
    view(2)
    title(num2str(years(i)));

    md_paper('landscape');
    print('-dpng','-zbuffer','-r300',['dp_' char(inlet) num2str(years(i)) '.png'])
    close
end

%overview plot Sed-Ero
le = length(se)
figure(2)
for i = 1:le
    subplot(3,4,i)
    hold on
    pa=2;
    collim=[-5 5];
    plot(xv/1000,yv/1000,'r');
    plot(xe/1000,ye/1000,'r');

    a1=pcolor(x(1:step:mme1,1:step:mme2)/1000,y(1:step:mme1,1:step:mme2)/1000,se{i}.val(1:step:mme1,1:step:mme2))
    shading interp
    colormap(erosed)
    caxis([-5 5])
    axis equal
    title([num2str(se{i}.yrs)]);
end
md_paper('landscape');
print('-dpng','-zbuffer','-r300',['se_' char(inlet) '.png'])

%overview plot Sed-Ero 1 plot/file
le = length(se)
for i = 1:le
    figure(i)
    hold on
    pa=2;
    collim=[-5 5];
    plot(xv/1000,yv/1000,'r');
    plot(xe/1000,ye/1000,'r');

    a1=pcolor(x(1:step:mme1,1:step:mme2)/1000,y(1:step:mme1,1:step:mme2)/1000,se{i}.val(1:step:mme1,1:step:mme2))
    shading interp
    colormap(erosed)
    caxis([-5 5])
    axis equal
    title([num2str(se{i}.yrs)]);

    md_paper('landscape');
    print('-dpng','-zbuffer','-r300',['se_' char(inlet) num2str(se{i}.yrs) '.png'])
    close
end



figure(3)
for i = 1:lt
    subplot(3,4,i)
    hold on
    pa=2;
    collim=[-25 5];
    plot(xv/1000,yv/1000,'r');
    a1=pcolor(x(1:step:mme1,1:step:mme2)/1000,y(1:step:mme1,1:step:mme2)/1000,dps{i}(1:step:mme1,1:step:mme2))
    shading interp
    caxis([-25 5])
    axis equal
    title(num2str(years(i)));
end
md_paper('landscape');
print('-dpng','-zbuffer','-r300',['dps_' char(inlet) '.png'])
close

figure(4)
for i = 1:lt
    subplot(3,4,i)
    hold on
    pa=2;
    collim=[-25 5];
    plot(xe/1000,ye/1000,'r');
    a1=pcolor(x(1:step:mme1,1:step:mme2)/1000,y(1:step:mme1,1:step:mme2)/1000,dpetd{i}(1:step:mme1,1:step:mme2))
    shading interp
    caxis([-25 5])
    axis equal
    title(num2str(years(i)));
end
md_paper('landscape');
print('-dpng','-zbuffer','-r300',['dpetd_' char(inlet) '.png'])
close

