function Flow=GenerateTransportBoundaryConditions(Flow,par,ii,dplayer)

t0=Flow.StartTime;
t1=Flow.StopTime;
dt=Flow.BccTimeStep;

switch lower(Flow.(par)(ii).BC.Source)
    case{'constant'}
        pars=[0 Flow.(par)(ii).BC.Constant]';
    case{'profile'}
        pars=Flow.(par)(ii).BC.Profile';
end

switch lower(Flow.(par)(ii).BC.Source)

    case{'constant','profile'}

        depths=pars(1,:);
        vals=pars(2,:);
        depths=[-100000 depths 100000];
        vals =[vals(1) vals vals(end)];
        val=interp1(depths,vals,dplayer);

        for j=1:Flow.NrOpenBoundaries
            Flow.OpenBoundaries(j).(par)(ii).NrTimeSeries=2;
            Flow.OpenBoundaries(j).(par)(ii).TimeSeriesT=[t0;t1];
            Flow.OpenBoundaries(j).(par)(ii).Profile='3d-profile';
            ta=squeeze(val(j,1,:))';
            tb=squeeze(val(j,2,:))';
            ta=[ta;ta];
            tb=[tb;tb];
            if strcmpi(Flow.VertCoord,'z')
                ta=fliplr(ta);
                tb=fliplr(tb);
            end
            Flow.OpenBoundaries(j).(par)(ii).TimeSeriesA=ta;
            Flow.OpenBoundaries(j).(par)(ii).TimeSeriesB=tb;
        end      
        
    case{'file'}
        
        nr=Flow.NrOpenBoundaries;
        for i=1:nr
            x(i,1)=0.5*(Flow.OpenBoundaries(i).X(1) + Flow.OpenBoundaries(i).X(2));
            y(i,1)=0.5*(Flow.OpenBoundaries(i).Y(1) + Flow.OpenBoundaries(i).Y(2));
            x(i,2)=0.5*(Flow.OpenBoundaries(i).X(end-1) + Flow.OpenBoundaries(i).X(end));
            y(i,2)=0.5*(Flow.OpenBoundaries(i).Y(end-1) + Flow.OpenBoundaries(i).Y(end));
        end
        
        fname=Flow.(par)(ii).BC.File;

        load(fname);

        times=s.time;
        
        it0=find(times<=t0, 1, 'last' );
        it1=find(times>=t1, 1, 'first' );

        s.lon=mod(s.lon,360);
        
        nt=0;

        for j=1:nr
            Flow.OpenBoundaries(j).(par)(ii).NrTimeSeries=0;
            Flow.OpenBoundaries(j).(par)(ii).TimeSeriesT=[];
            Flow.OpenBoundaries(j).(par)(ii).Profile='3d-profile';
            Flow.OpenBoundaries(j).(par)(ii).TimeSeriesA=[];
            Flow.OpenBoundaries(j).(par)(ii).TimeSeriesB=[];
        end

        for it=it0:it1
            
            disp(['      Time step ' num2str(it) ' of ' num2str(it1-it0+1)]);

            t=times(it);
            data=Interpolate3D(Flow,x,y,dplayer,s,it);
            nt=nt+1;
            for j=1:nr
                ta=squeeze(data(j,1,:))';
                tb=squeeze(data(j,2,:))';
                Flow.OpenBoundaries(j).(par)(ii).NrTimeSeries=nt;
                Flow.OpenBoundaries(j).(par)(ii).TimeSeriesT=[Flow.OpenBoundaries(j).(par)(ii).TimeSeriesT;t];
                Flow.OpenBoundaries(j).(par)(ii).TimeSeriesA=[Flow.OpenBoundaries(j).(par)(ii).TimeSeriesA;ta];
                Flow.OpenBoundaries(j).(par)(ii).TimeSeriesB=[Flow.OpenBoundaries(j).(par)(ii).TimeSeriesB;tb];
            end
        end

        t=t0:dt/1440:t1;
        for j=1:nr
            ta=[];
            tb=[];
            for k=1:Flow.KMax
                ta(:,k) = spline(Flow.OpenBoundaries(j).(par)(ii).TimeSeriesT,Flow.OpenBoundaries(j).(par)(ii).TimeSeriesA(:,k),t);
                tb(:,k) = spline(Flow.OpenBoundaries(j).(par)(ii).TimeSeriesT,Flow.OpenBoundaries(j).(par)(ii).TimeSeriesB(:,k),t);
            end
            Flow.OpenBoundaries(j).(par)(ii).TimeSeriesT = t;
            Flow.OpenBoundaries(j).(par)(ii).TimeSeriesA = ta;
            Flow.OpenBoundaries(j).(par)(ii).TimeSeriesB = tb;
            Flow.OpenBoundaries(j).(par)(ii).NrTimeSeries=length(t);

            if strcmpi(Flow.VertCoord,'z')
                Flow.OpenBoundaries(j).(par)(ii).TimeSeriesA=flipdim(Flow.OpenBoundaries(j).(par)(ii).TimeSeriesA,2);
                Flow.OpenBoundaries(j).(par)(ii).TimeSeriesB=flipdim(Flow.OpenBoundaries(j).(par)(ii).TimeSeriesB,2);
            end

        
        end
        for j=1:nr

% if strcmpi(par,'Temperature')
%     Flow.OpenBoundaries(j).(par)(ii).TimeSeriesA=zeros(size(Flow.OpenBoundaries(j).(par)(ii).TimeSeriesA))+50;
%     Flow.OpenBoundaries(j).(par)(ii).TimeSeriesB=zeros(size(Flow.OpenBoundaries(j).(par)(ii).TimeSeriesB))+50;
% end
        end
end


