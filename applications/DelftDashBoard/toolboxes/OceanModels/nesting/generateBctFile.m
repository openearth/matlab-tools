function openBoundaries=generateBctFile(flow,openboundaries,opt)

GenWLAstro=0;
GenWLHarmo=0;
GenWLConst=0;
GenWL3D=0;

GenVelHarmo=0;
GenVel4D=0;
GenVelConst=0;
GenVelTS=0;
GenVelAstro=0;

if isfield(opt.Current.BC,'AstroVelFile')
    GenVelAstro=1;
end

if isfield(opt.Current.BC,'AstroFile')
    GenWLAstro=1;
end

% if isfield(Flow.Current.BC,'AstroTanVelFile')
%     GenTanVelAstro=1;
% end

nr=length(openBoundaries);

for i=1:nr
    dp(i,1)=-openBoundaries(i).depth(1);
    dp(i,2)=-openBoundaries(i).depth(2);
end

% Check which time series need to be generated
for i=1:nr
    switch lower(openBoundaries(i).type)
        case{'n'}

        case{'c'}
            switch lower(opt.Current.BC.Source)
                case{'file'}
                    GenVel4D=1;
                case{'astro'}
                    GenVelAstro=1;
            end
        case{'z'}
            switch lower(opt.WaterLevel.BC.Source)
                case{'astro'}
                    GenWLAstro=1;
                case{'harmo'}
                    GenWLHarmo=1;
                case{'file'}
                    GenWL3D=1;
            end
        case{'r','x','p'}
            switch lower(opt.WaterLevel.BC.Source)
                case{'astro'}
                    GenWLAstro=1;
                case{'harmo'}
                    GenWLHarmo=1;
                case{'constant'}
                    GenWLConst=1;
                case{'file'}
                    GenWL3D=1;
            end
            switch lower(opt.Current.BC.Source)
                case{'file'}
                    GenVel4D=1;
                case{'harmo'}
                    GenVelHarmo=1;
                case{'constant'}
                    GenVelConst=1;
                case{'timeseries'}
                    GenVelTS=1;
            end
    end
end

% Water level time series
if GenWLAstro
    disp('   Water levels from astro ...');
    [twlastro,wlastro]=generateWaterLevelsFromAstro(flow,openBoundaries,opt);
end
if GenWLHarmo
    disp('   Water levels from harmo ...');
    [twlharmo,wlharmo]=GenerateWaterLevelsFromHarmo(Flow);
end
if GenWLConst
    disp('   Water levels from constant ...');
    [twlconst,wlconst]=GenerateWaterLevelsFromConstantValue(Flow);
end
if GenWL3D
    disp('   Water levels from file ...');
    [twl3d,wl3d]=GenerateWaterLevelsFromFile(Flow);
end

% Current time series
if GenVelHarmo
    disp('   Velocities from harmo ...');
    [tvelharmo,velharmo]=GenerateVelocitiesFromHarmo(Flow);
end
if GenVelAstro
    disp('   Velocities from astro ...');
    [tvelastro,velastro,tanvelastro]=GenerateVelocitiesFromAstro(Flow);
end
if GenVel4D
    disp('   Velocities from file ...');
    [tvel4d,vel4d,tanvel4d]=GenerateVelocitiesFromFile(Flow);
end
if GenVelConst
    disp('   Velocities from constant ...');
    [tvelconst,velconst]=GenerateVelocitiesFromConstantValue(Flow);
end
if GenVelTS
    disp('   Velocities from timeseries ...');
    [tvelts,velts]=GenerateVelocitiesFromTimeSeries(Flow);
end

for n=1:nr
    if Flow.OpenBoundaries(n).Forcing=='T'
        switch lower(Flow.OpenBoundaries(n).Type)
            case{'n'}
%                 Flow.OpenBoundaries(n).TimeSeriesT=[Flow.StartTime Flow.StopTime];
%                 Flow.OpenBoundaries(n).TimeSeriesA=[gradient gradient];
%                 Flow.OpenBoundaries(n).TimeSeriesB=[gradient gradient];
            case{'z'}
                switch lower(Flow.WaterLevel.BC.Source)
                    case{'astro'}
                        twl=twlastro;
                        wl=wlastro;
                    case{'harmo'}
                        twl=twlharmo;
                        wl=wlharmo;
                    case{'file'}
                        twl=twl3d;
                        wl=wl3d;
                end

                % Water levels from astro
                if isfield(Flow.Current.BC,'AstroFile') && ~strcmpi(Flow.WaterLevel.BC.Source,'astro')
                    wla=squeeze(wlastro(n,1,:));
                    wlb=squeeze(wlastro(n,2,:));
                else
                    wla=0;
                    wlb=0;
                end


                Flow.OpenBoundaries(n).TimeSeriesT=twl;
                Flow.OpenBoundaries(n).TimeSeriesA=squeeze(wl(n,1,:)) + wla;
                Flow.OpenBoundaries(n).TimeSeriesB=squeeze(wl(n,2,:)) + wlb;

            case{'r','x'}
                switch lower(Flow.WaterLevel.BC.Source)
                    case{'astro'}
                        twl=twlastro;
                        wl=wlastro;
                    case{'harmo'}
                        twl=twlharmo;
                        wl=wlharmo;
                    case{'constant'}
                        twl=twlconst;
                        wl=wlconst;
                    case{'file'}
                        twl=twl3d;
                        wl=wl3d;
                end
                switch lower(Flow.Current.BC.Source)
                    case{'file'}
                        tvel=tvel4d;
                        vel=vel4d;
                        tanvel=tanvel4d;
                    case{'harmo'}
                        tvel=tvelharmo;
                        vel=velharmo;
                    case{'constant'}
                        tvel=tvelconst;
                        vel=velconst;
                    case{'timeseries'}
                        tvel=tvelts;
                        vel=velts;
                end

                % Water levels from astro
                if isfield(Flow.Current.BC,'AstroFile') && ~strcmpi(Flow.WaterLevel.BC.Source,'astro')
                    wla=squeeze(wlastro(n,1,:));
                    wlb=squeeze(wlastro(n,2,:));
                else
                    wla=0;
                    wlb=0;
                end

                % Velocities from astro
                if isfield(Flow.Current.BC,'AstroVelFile')
                    va=squeeze(velastro(n,1,:));
                    vb=squeeze(velastro(n,2,:));
                else
                    va=0;
                    vb=0;
                end
                
                for k=1:Flow.KMax
                    switch lower(Flow.OpenBoundaries(n).Side)
                        case{'left','bottom'}
                            r1(:,k)=squeeze(vel(n,1,k,:))+ va + (squeeze(wl(n,1,:))+wla)*sqrt(9.81/dp(n,1));
                            r2(:,k)=squeeze(vel(n,2,k,:))+ vb + (squeeze(wl(n,2,:))+wlb)*sqrt(9.81/dp(n,2));
                        case{'top','right'}
                            r1(:,k)=squeeze(vel(n,1,k,:))+ va - (squeeze(wl(n,1,:))+wla)*sqrt(9.81/dp(n,1));
                            r2(:,k)=squeeze(vel(n,2,k,:))+ vb - (squeeze(wl(n,2,:))+wlb)*sqrt(9.81/dp(n,2));
                    end
                end

%                 for k=1:Flow.KMax
%                     switch lower(Flow.OpenBoundaries(n).Side)
%                         case{'left','bottom'}
%                             r1(:,k)=va + squeeze(wl(n,1,:))*sqrt(9.81/dp(n,1));
%                             r2(:,k)=vb + squeeze(wl(n,2,:))*sqrt(9.81/dp(n,2));
%                         case{'top','right'}
%                             r1(:,k)=va - squeeze(wl(n,1,:))*sqrt(9.81/dp(n,1));
%                             r2(:,k)=vb - squeeze(wl(n,2,:))*sqrt(9.81/dp(n,2));
%                     end
%                 end

                Flow.OpenBoundaries(n).NrTimeSeries=length(twl);
                Flow.OpenBoundaries(n).Profile='3d-profile';
                Flow.OpenBoundaries(n).TimeSeriesT=twl;
                Flow.OpenBoundaries(n).TimeSeriesA=r1;
                Flow.OpenBoundaries(n).TimeSeriesB=r2;
                
                if strcmpi(Flow.OpenBoundaries(n).Type,'x')
                    for k=1:Flow.KMax
                        Flow.OpenBoundaries(n).TimeSeriesAV(:,k)=squeeze(tanvel(n,1,k,:));
                        Flow.OpenBoundaries(n).TimeSeriesBV(:,k)=squeeze(tanvel(n,2,k,:));
                    end
                end

                
            case{'c'}
                switch lower(Flow.Current.BC.Source)
                    case{'file'}
                        Flow.OpenBoundaries(n).NrTimeSeries=length(tvel4d);
                        Flow.OpenBoundaries(n).Profile='3d-profile';
                        Flow.OpenBoundaries(n).TimeSeriesT=tvel4d;
                        Flow.OpenBoundaries(n).TimeSeriesA=squeeze(vel4d(n,1,:,:))';
                        Flow.OpenBoundaries(n).TimeSeriesB=squeeze(vel4d(n,2,:,:))';
                    otherwise
                end
            case{'p'}
                switch lower(Flow.WaterLevel.BC.Source)
                    case{'astro'}
                        twl=twlastro;
                        wl=wlastro;
                    case{'harmo'}
                        twl=twlharmo;
                        wl=wlharmo;
                    case{'file'}
                        twl=twl3d;
                        wl=wl3d;
                    case{'constant'}
                        twl=twlconst;
                        wl=wlconst;
                end
                switch lower(Flow.Current.BC.Source)
                    case{'file'}
                        tvel=tvel4d;
                        vel=vel4d;
                        tanvel=tanvel4d;
                    case{'harmo'}
                        tvel=tvelharmo;
                        vel=velharmo;
                    case{'constant'}
                        tvel=tvelconst;
                        vel=velconst;
                    case{'timeseries'}
                        tvel=tvelts;
                        vel=velts;
                end

                % Velocities from astro
                if isfield(Flow.Current.BC,'AstroVelFile')
                    va=squeeze(velastro(n,1,:));
                    vb=squeeze(velastro(n,2,:));
                else
                    va=0;
                    vb=0;
                end

                % Tangential velocities from astro
                if isfield(Flow.Current.BC,'AstroTanVelFile')
                    tanva=squeeze(velastro(n,1,:));
                    tanvb=squeeze(velastro(n,2,:));
                else
                    tanva=0;
                    tanvb=0;
                end

                switch lower(Flow.Current.BC.Source)
                    case{'file'}
                        Flow.OpenBoundaries(n).NrTimeSeries=length(tvel4d);
                        Flow.OpenBoundaries(n).Profile='3d-profile';
                        Flow.OpenBoundaries(n).TimeSeriesT=tvel;
                        Flow.OpenBoundaries(n).TimeSeriesA=[];
                        Flow.OpenBoundaries(n).TimeSeriesB=[];
                        for k=1:Flow.KMax
                            Flow.OpenBoundaries(n).TimeSeriesA(:,k)=squeeze(vel(n,1,k,:))+va;
                            Flow.OpenBoundaries(n).TimeSeriesB(:,k)=squeeze(vel(n,2,k,:))+vb;
                        end
                    otherwise
                end

                for k=1:Flow.KMax
                    Flow.OpenBoundaries(n).TimeSeriesAV(:,k)=squeeze(tanvel(n,1,k,:))+tanva;
                    Flow.OpenBoundaries(n).TimeSeriesBV(:,k)=squeeze(tanvel(n,2,k,:))+tanvb;
                end
                
                % Flather conditions
                Flow.OpenBoundaries(n).TimeSeriesAV(:,end)=squeeze(wl(n,1,:));
                Flow.OpenBoundaries(n).TimeSeriesBV(:,end)=squeeze(wl(n,2,:));
        end

        if strcmpi(Flow.VertCoord,'z')
            if ndims(Flow.OpenBoundaries(n).TimeSeriesA)==2
                Flow.OpenBoundaries(n).TimeSeriesA=flipdim(Flow.OpenBoundaries(n).TimeSeriesA,2);
                Flow.OpenBoundaries(n).TimeSeriesB=flipdim(Flow.OpenBoundaries(n).TimeSeriesB,2);
                if isfield(Flow.OpenBoundaries(n),'TimeSeriesAV')
                    Flow.OpenBoundaries(n).TimeSeriesAV=flipdim(Flow.OpenBoundaries(n).TimeSeriesAV,2);
                    Flow.OpenBoundaries(n).TimeSeriesBV=flipdim(Flow.OpenBoundaries(n).TimeSeriesBV,2);
                end
            end
        end

    end
end

disp('Saving bct file');
SaveBctFile(Flow);
