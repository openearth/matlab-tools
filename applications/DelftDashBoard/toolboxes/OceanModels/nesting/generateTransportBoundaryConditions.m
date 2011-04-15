function openBoundaries=generateTransportBoundaryConditions(flow,openBoundaries,opt,par,ii,dplayer)

t0=flow.startTime;
t1=flow.stopTime;
dt=opt.bccTimeStep;

switch lower(opt.(par)(ii).BC.source)
    case{'constant'}
        pars=[0 opt.(par)(ii).BC.constant]';
    case{'profile'}
        pars=opt.(par)(ii).BC.profile';
end

switch lower(opt.(par)(ii).BC.source)

    case{'constant','profile'}

        depths=pars(1,:);
        vals=pars(2,:);
        depths=[-100000 depths 100000];
        vals =[vals(1) vals vals(end)];
        val=interp1(depths,vals,dplayer);

        for j=1:length(openBoundaries)
            openBoundaries(j).(par)(ii).nrTimeSeries=2;
            openBoundaries(j).(par)(ii).timeSeriesT=[t0;t1];
            if flow.KMax>1
                openBoundaries(j).(par)(ii).profile='3d-profile';
            else
                openBoundaries(j).(par)(ii).profile='uniform';
            end
            ta=squeeze(val(j,1,:))';
            tb=squeeze(val(j,2,:))';
            ta=[ta;ta];
            tb=[tb;tb];
            if strcmpi(flow.vertCoord,'z')
                ta=fliplr(ta);
                tb=fliplr(tb);
            end
            openBoundaries(j).(par)(ii).timeSeriesA=ta;
            openBoundaries(j).(par)(ii).timeSeriesB=tb;
        end      
        
    case{'file'}
        
        for i=1:length(openBoundaries)
            x(i,1)=0.5*(openBoundaries(i).x(1) + openBoundaries(i).x(2));
            y(i,1)=0.5*(openBoundaries(i).y(1) + openBoundaries(i).y(2));
            x(i,2)=0.5*(openBoundaries(i).x(end-1) + openBoundaries(i).x(end));
            y(i,2)=0.5*(openBoundaries(i).y(end-1) + openBoundaries(i).y(end));
        end
        
        fname=opt.(par)(ii).BC.file;

        s=load(fname);

        times=s.time;
        
        it0=find(times<=t0, 1, 'last' );
        it1=find(times>=t1, 1, 'first' );

        if isempty(it0)
            it0=1;
        end
        if isempty(it1)
            it1=length(times);
        end

        s.lon=mod(s.lon,360);
        x=mod(x,360);
        
        nt=0;

        for j=1:length(openBoundaries)
            openBoundaries(j).(par)(ii).nrTimeSeries=0;
            openBoundaries(j).(par)(ii).timeSeriesT=[];
            openBoundaries(j).(par)(ii).profile='3d-profile';
            openBoundaries(j).(par)(ii).timeSeriesA=[];
            openBoundaries(j).(par)(ii).timeSeriesB=[];
        end

        for it=it0:it1
            
            disp(['      Time step ' num2str(it) ' of ' num2str(it1-it0+1)]);

            t=times(it);
            data=interpolate3D(x,y,dplayer,s,it);
            nt=nt+1;
            for j=1:length(openBoundaries)
                ta=squeeze(data(j,1,:))';
                tb=squeeze(data(j,2,:))';
                openBoundaries(j).(par)(ii).nrTimeSeries=nt;
                openBoundaries(j).(par)(ii).timeSeriesT=[openBoundaries(j).(par)(ii).timeSeriesT;t];
                openBoundaries(j).(par)(ii).timeSeriesA=[openBoundaries(j).(par)(ii).timeSeriesA;ta];
                openBoundaries(j).(par)(ii).timeSeriesB=[openBoundaries(j).(par)(ii).timeSeriesB;tb];
            end
        end

        t=t0:dt/1440:t1;
        for j=1:length(openBoundaries)
            ta=[];
            tb=[];
            for k=1:flow.KMax
                ta(:,k) = spline(openBoundaries(j).(par)(ii).timeSeriesT,openBoundaries(j).(par)(ii).timeSeriesA(:,k),t);
                tb(:,k) = spline(openBoundaries(j).(par)(ii).timeSeriesT,openBoundaries(j).(par)(ii).timeSeriesB(:,k),t);
            end
            openBoundaries(j).(par)(ii).timeSeriesT = t;
            openBoundaries(j).(par)(ii).timeSeriesA = ta;
            openBoundaries(j).(par)(ii).timeSeriesB = tb;
            openBoundaries(j).(par)(ii).nrTimeSeries=length(t);

            if strcmpi(flow.vertCoord,'z')
                openBoundaries(j).(par)(ii).timeSeriesA=flipdim(openBoundaries(j).(par)(ii).timeSeriesA,2);
                openBoundaries(j).(par)(ii).timeSeriesB=flipdim(openBoundaries(j).(par)(ii).timeSeriesB,2);
            end
        end
        
end


