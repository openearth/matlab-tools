function handles=ddb_generateBoundaryConditionsDelft3DFLOW(handles,id,varargin)

if ~isempty(varargin)
    % Check if routine exists
    if strcmpi(varargin{1},'ddb_test')
        return
    end
end

if handles.Model(md).Input(id).NrOpenBoundaries>0

    wb = waitbox('Generating Boundary Conditions ...');
    
    ii=strmatch(handles.TideModels.ActiveTideModelBC,handles.TideModels.Name,'exact');
    if strcmpi(handles.TideModels.Model(ii).URL(1:4),'http')
        tidefile=[handles.TideModels.Model(ii).URL '/' handles.TideModels.ActiveTideModelBC '.nc'];
    else
        tidefile=[handles.TideModels.Model(ii).URL filesep handles.TideModels.ActiveTideModelBC '.nc'];
    end


    x=handles.Model(md).Input(id).GridX;
    y=handles.Model(md).Input(id).GridY;
    z=handles.Model(md).Input(id).Depth;

    mmax=size(x,1);
    nmax=size(x,2);

    % Generate boundary conditions

    nb=handles.Model(md).Input(id).NrOpenBoundaries;

    cs.Name='WGS 84';
    cs.Type='Geographic';

    for i=1:nb
        xa(i)=handles.Model(md).Input(id).OpenBoundaries(i).X(1);
        ya(i)=handles.Model(md).Input(id).OpenBoundaries(i).Y(1);
        xb(i)=handles.Model(md).Input(id).OpenBoundaries(i).X(end);
        yb(i)=handles.Model(md).Input(id).OpenBoundaries(i).Y(end);
        [xa(i),ya(i)]=ddb_coordConvert(xa(i),ya(i),handles.ScreenParameters.CoordinateSystem,cs);
        [xb(i),yb(i)]=ddb_coordConvert(xb(i),yb(i),handles.ScreenParameters.CoordinateSystem,cs);
%         if xa(i)<0
%             xa(i)=xa(i)+360;
%         end
%         if xb(i)<0
%             xb(i)=xb(i)+360;
%         end
    end
%     xa(xa<0.125 & xa>0)=360;
%     xa(xa<0.250 & xa>0.125)=0.25;
%     xb(xb<0.125 & xb>0)=360;
%     xb(xb<0.250 & xb>0.125)=0.25;
    
    xx=[xa xb];
    yy=[ya yb];
    
    igetwl=0;
    for i=1:nb
        if strcmpi(handles.Model(md).Input(id).OpenBoundaries(i).Forcing,'A')
            switch lower(handles.Model(md).Input(id).OpenBoundaries(i).Type)
                case{'r','z'}
                    igetwl=1;
            end
        end
    end

    if igetwl
%       [ampz,phasez,depth,ConList]=extract_HC([handles.TideDir handles.TideModels.ActiveTideModelBC],yy,xx,'z');
       [ampz,phasez,conList] = readTideModel(tidefile,'type','h','x',xx,'y',yy,'constituent','all');
%       [ampz,phasez,depth,conList]=ddb_extractTidalConstituents(tidefile,xx,yy,'z');
        
        ampaz=ampz(:,1:nb);
        ampbz=ampz(:,nb+1:end);
        phaseaz=phasez(:,1:nb);
        phasebz=phasez(:,nb+1:end);

        ampaz(isnan(ampaz))=0.0;
        ampbz(isnan(ampbz))=0.0;
        phaseaz(isnan(phaseaz))=0.0;
        phasebz(isnan(phasebz))=0.0;

    end
    
    igetvel=0;
    for i=1:nb
        if strcmpi(handles.Model(md).Input(id).OpenBoundaries(i).Forcing,'A')
            switch lower(handles.Model(md).Input(id).OpenBoundaries(i).Type)
                case{'r','c'}
                    igetvel=1;
            end
        end
    end
    
    if igetvel
        
        % Riemann or current boundaries present
        
        %       [ampu,phaseu,depth,ConList]=extract_HC([handles.TideDir handles.TideModels.ActiveTideModelBC],yy,xx,'u');
        %       [ampv,phasev,depth,ConList]=extract_HC([handles.TideDir handles.TideModels.ActiveTideModelBC],yy,xx,'v');
%         [ampu,phaseu,depth,conList]=ddb_extractTidalConstituents(tidefile,xx,yy,'u');
%         [ampv,phasev,depth,conList]=ddb_extractTidalConstituents(tidefile,xx,yy,'v');
        [ampu,phaseu,ampv,phasev,depth,conList] = readTideModel(tidefile,'type','vel','x',xx,'y',yy,'constituent','all','includedepth');
        
        % Units are cm/s
        ampu=ampu/100;
        ampv=ampv/100;
        
        % A
        ampau=ampu(:,1:nb);
        ampav=ampv(:,1:nb);
        % B
        ampbu=ampu(:,nb+1:end);
        ampbv=ampv(:,nb+1:end);
        
        % A
        phaseau=phaseu(:,1:nb);
        phaseav=phasev(:,1:nb);
        % B
        phasebu=phaseu(:,nb+1:end);
        phasebv=phasev(:,nb+1:end);

        % Depth
        deptha=-depth(1:nb);
        depthb=-depth(nb+1:end);

        [semaa,ecca,inca,phaa]=ap2ep(ampau,phaseau,ampav,phaseav);
        [semab,eccb,incb,phab]=ap2ep(ampbu,phasebu,ampbv,phasebv);
        
        for n=1:nb
            
            bnd=handles.Model(md).Input(id).OpenBoundaries(n);
            dx=bnd.X(2)-bnd.X(1);
            dy=bnd.Y(2)-bnd.Y(1);
            if strcmpi(bnd.Orientation,'negative')
                dx=dx*-1;
                dy=dy*-1;
            end
            
            alphaa=180*atan2(dy,dx)/pi;
            alphab=180*atan2(dy,dx)/pi;
            
            switch lower(handles.Model(md).Input(id).OpenBoundaries(n).Side)
                case{'left','right'}
                    % u-point
                    alphaa=alphaa-90;
                    alphab=alphab-90;
                case{'bottom','top'}
                    % v-point
                    alphaa=alphaa+90;
                    alphab=alphab+90;
            end
            
            for i=1:size(inca,1)
                inca(i,n)=inca(i,n)-alphaa;
                incb(i,n)=incb(i,n)-alphab;
            end
        end
        
        [ampau,phaseau,ampav,phaseav]=ep2ap(semaa,ecca,inca,phaa);
        [ampbu,phasebu,ampbv,phasebv]=ep2ap(semab,eccb,incb,phab);
        
%         ampau=ampav;
%         phaseau=phaseav;
%         ampbu=ampbv;
%         phasebu=phasebv;
        
        ampau(isnan(ampau))=0.0;
        ampbu(isnan(ampbu))=0.0;
        phaseau(isnan(phaseau))=0.0;
        phasebu(isnan(phasebu))=0.0;
        ampav(isnan(ampav))=0.0;
        ampbv(isnan(ampbv))=0.0;
        phaseav(isnan(phaseav))=0.0;
        phasebv(isnan(phasebv))=0.0;
        
    end
    
    NrCons=length(conList);
    for i=1:NrCons
        Constituents(i).Name=conList{i};
    end
    
    k=0;
    
    for n=1:nb
        if strcmp(handles.Model(md).Input(id).OpenBoundaries(n).Forcing,'A')

            handles.Model(md).Input(id).OpenBoundaries(n).CompA=[handles.Model(md).Input(id).OpenBoundaries(n).Name 'A'];
            handles.Model(md).Input(id).OpenBoundaries(n).CompB=[handles.Model(md).Input(id).OpenBoundaries(n).Name 'B'];
            
            % Side A
            k=k+1;
            if igetvel
                dpcorfac=handles.Model(md).Input(id).OpenBoundaries(n).Depth(1)/deptha(n);
%                 dpcorfac=max(min(dpcorfac,1.5),0.75);
%                 dpcorfac=1;
            end
            handles.Model(md).Input(id).AstronomicComponentSets(k).Name=handles.Model(md).Input(id).OpenBoundaries(n).CompA;
            handles.Model(md).Input(id).AstronomicComponentSets(k).Nr=NrCons;
            for i=1:NrCons
                
                handles.Model(md).Input(id).AstronomicComponentSets(k).Component{i}=upper(Constituents(i).Name);
                
                switch lower(handles.Model(md).Input(id).OpenBoundaries(n).Type)
                    case{'z'}
                        handles.Model(md).Input(id).AstronomicComponentSets(k).Amplitude(i)=ampaz(i,n);
                        handles.Model(md).Input(id).AstronomicComponentSets(k).Phase(i)=phaseaz(i,n);
                    case{'c'}
                        handles.Model(md).Input(id).AstronomicComponentSets(k).Amplitude(i)=ampau(i,n)*dpcorfac;
                        handles.Model(md).Input(id).AstronomicComponentSets(k).Phase(i)=phaseau(i,n);
                    case{'r'}
                        a1=ampau(i,n)*dpcorfac;
                        phi1=phaseau(i,n);
                        % Minimum depth of 1 m !
                        a2=ampaz(i,n)*sqrt(9.81/max(-handles.Model(md).Input(id).OpenBoundaries(n).Depth(1),1));
                        phi2=phaseaz(i,n);
                        
                        phi1=pi*phi1/180;
                        phi2=pi*phi2/180;
                        
                        switch lower(handles.Model(md).Input(id).OpenBoundaries(n).Side)
                            case{'left','bottom'}
                                [a3,phi3]=combinesin(a1,phi1,a2,phi2);
                            case{'top','right'}
                                [a3,phi3]=combinesin(a1,phi1,-a2,phi2);
                        end
                        
                        phi3=180*phi3/pi;
                        phi3=mod(phi3,360);
                        
                        handles.Model(md).Input(id).AstronomicComponentSets(k).Amplitude(i)=a3;
                        handles.Model(md).Input(id).AstronomicComponentSets(k).Phase(i)=phi3;
                end
                
                handles.Model(md).Input(id).AstronomicComponentSets(k).Correction(i)=0;
                handles.Model(md).Input(id).AstronomicComponentSets(k).AmplitudeCorrection(i)=0;
                handles.Model(md).Input(id).AstronomicComponentSets(k).PhaseCorrection(i)=0;
            end
            
            % Side B
            k=k+1;
            if igetvel
                dpcorfac=handles.Model(md).Input(id).OpenBoundaries(n).Depth(2)/depthb(n);
%                 dpcorfac=max(min(dpcorfac,1.5),0.75);
%                 dpcorfac=1;
            end
            handles.Model(md).Input(id).AstronomicComponentSets(k).Name=handles.Model(md).Input(id).OpenBoundaries(n).CompB;
            handles.Model(md).Input(id).AstronomicComponentSets(k).Nr=NrCons;
            for i=1:NrCons
                handles.Model(md).Input(id).AstronomicComponentSets(k).Component{i}=upper(Constituents(i).Name);
                
                switch lower(handles.Model(md).Input(id).OpenBoundaries(n).Type)
                    case{'z'}
                        handles.Model(md).Input(id).AstronomicComponentSets(k).Amplitude(i)=ampbz(i,n);
                        handles.Model(md).Input(id).AstronomicComponentSets(k).Phase(i)=phasebz(i,n);
                    case{'c'}
                        handles.Model(md).Input(id).AstronomicComponentSets(k).Amplitude(i)=ampbu(i,n)*dpcorfac;
                        handles.Model(md).Input(id).AstronomicComponentSets(k).Phase(i)=phasebu(i,n);
                    case{'r'}
                        a1=ampbu(i,n)*dpcorfac;
                        phi1=phasebu(i,n);
                        % Minimum depth of 1 m !
                        a2=ampbz(i,n)*sqrt(9.81/max(-handles.Model(md).Input(id).OpenBoundaries(n).Depth(2),1));
                        phi2=phasebz(i,n);
                        
                        phi1=pi*phi1/180;
                        phi2=pi*phi2/180;
                        
                        switch lower(handles.Model(md).Input(id).OpenBoundaries(n).Side)
                            case{'left','bottom'}
                                [a3,phi3]=combinesin(a1,phi1,a2,phi2);
                            case{'top','right'}
                                [a3,phi3]=combinesin(a1,phi1,-a2,phi2);
                        end
                        
                        phi3=180*phi3/pi;
                        phi3=mod(phi3,360);
                                                
                        handles.Model(md).Input(id).AstronomicComponentSets(k).Amplitude(i)=a3;
                        handles.Model(md).Input(id).AstronomicComponentSets(k).Phase(i)=phi3;
                end
                
                handles.Model(md).Input(id).AstronomicComponentSets(k).Correction(i)=0;
                handles.Model(md).Input(id).AstronomicComponentSets(k).AmplitudeCorrection(i)=0;
                handles.Model(md).Input(id).AstronomicComponentSets(k).PhaseCorrection(i)=0;
            end
        end
    end
    handles.Model(md).Input(id).NrAstronomicComponentSets=k;
    
    AttName=get(handles.GUIHandles.EditAttributeName,'String');
    handles.Model(md).Input(id).BcaFile=[AttName '.bca'];

    ddb_saveBcaFile(handles,id);
    ddb_saveBndFile(handles,id);
    
    close(wb);
    
else
    GiveWarning('Warning','First generate or load open boundaries');
end


