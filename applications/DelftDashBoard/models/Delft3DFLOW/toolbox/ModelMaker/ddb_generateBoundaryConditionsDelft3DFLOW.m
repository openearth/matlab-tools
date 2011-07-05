function [handles,err]=ddb_generateBoundaryConditionsDelft3DFLOW(handles,id,varargin)

err='';

if ~isempty(varargin)
    % Check if routine exists
    if strcmpi(varargin{1},'ddb_test')
        return
    end
end

if handles.Model(md).Input(id).nrOpenBoundaries==0
    err='First generate or load open boundaries';
    return
end

wb = waitbox('Generating Boundary Conditions ...');
    
try
    
    ii=handles.Toolbox(tb).Input.activeTideModelBC;
    name=handles.tideModels.model(ii).name;
    if strcmpi(handles.tideModels.model(ii).URL(1:4),'http')
        tidefile=[handles.tideModels.model(ii).URL '/' name '.nc'];
    else
        tidefile=[handles.tideModels.model(ii).URL filesep name '.nc'];
    end
    
    
    x=handles.Model(md).Input(id).gridX;
    y=handles.Model(md).Input(id).gridY;
    z=handles.Model(md).Input(id).depth;
    
    mmax=size(x,1);
    nmax=size(x,2);
    
    % Generate boundary conditions
    
    nb=handles.Model(md).Input(id).nrOpenBoundaries;
    
    cs.name='WGS 84';
    cs.type='Geographic';
    
    for i=1:nb
        xa(i)=handles.Model(md).Input(id).openBoundaries(i).x(1);
        ya(i)=handles.Model(md).Input(id).openBoundaries(i).y(1);
        xb(i)=handles.Model(md).Input(id).openBoundaries(i).x(end);
        yb(i)=handles.Model(md).Input(id).openBoundaries(i).y(end);
        [xa(i),ya(i)]=ddb_coordConvert(xa(i),ya(i),handles.screenParameters.coordinateSystem,cs);
        [xb(i),yb(i)]=ddb_coordConvert(xb(i),yb(i),handles.screenParameters.coordinateSystem,cs);
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
        if strcmpi(handles.Model(md).Input(id).openBoundaries(i).forcing,'A')
            switch lower(handles.Model(md).Input(id).openBoundaries(i).type)
                case{'r','z'}
                    igetwl=1;
            end
        end
    end
    
    if igetwl
        
        [ampz,phasez,conList] = readTideModel(tidefile,'type','h','x',xx,'y',yy,'constituent','all');
        
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
        if strcmpi(handles.Model(md).Input(id).openBoundaries(i).forcing,'A')
            switch lower(handles.Model(md).Input(id).openBoundaries(i).type)
                case{'r','c'}
                    igetvel=1;
            end
        end
    end
    
    if igetvel
        
        % Riemann or current boundaries present
        
        [ampu,phaseu,ampv,phasev,depth,conList] = readTideModel(tidefile,'type','q','x',xx,'y',yy,'constituent','all','includedepth');
        
        % Units are m2/s
        
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
            
            bnd=handles.Model(md).Input(id).openBoundaries(n);
            dx=bnd.x(2)-bnd.x(1);
            dy=bnd.y(2)-bnd.y(1);
            if strcmpi(bnd.orientation,'negative')
                dx=dx*-1;
                dy=dy*-1;
            end
            
            alphaa=180*atan2(dy,dx)/pi;
            alphab=180*atan2(dy,dx)/pi;
            
            switch lower(handles.Model(md).Input(id).openBoundaries(n).side)
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
        Constituents(i).name=conList{i};
    end
    
    k=0;
    
    for n=1:nb
        if strcmp(handles.Model(md).Input(id).openBoundaries(n).forcing,'A')
            
            handles.Model(md).Input(id).openBoundaries(n).compA=[handles.Model(md).Input(id).openBoundaries(n).name 'A'];
            handles.Model(md).Input(id).openBoundaries(n).compB=[handles.Model(md).Input(id).openBoundaries(n).name 'B'];
            
            % Side A
            k=k+1;
            if igetvel
                dpcorfac=-1/handles.Model(md).Input(id).openBoundaries(n).depth(1);
            end
            handles.Model(md).Input(id).astronomicComponentSets(k).name=handles.Model(md).Input(id).openBoundaries(n).compA;
            handles.Model(md).Input(id).astronomicComponentSets(k).nr=NrCons;
            for i=1:NrCons
                
                handles.Model(md).Input(id).astronomicComponentSets(k).component{i}=upper(Constituents(i).name);
                
                switch lower(handles.Model(md).Input(id).openBoundaries(n).type)
                    case{'z'}
                        handles.Model(md).Input(id).astronomicComponentSets(k).amplitude(i)=ampaz(i,n);
                        handles.Model(md).Input(id).astronomicComponentSets(k).phase(i)=phaseaz(i,n);
                    case{'c'}
                        handles.Model(md).Input(id).astronomicComponentSets(k).amplitude(i)=ampau(i,n)*dpcorfac;
                        handles.Model(md).Input(id).astronomicComponentSets(k).phase(i)=phaseau(i,n);
                    case{'r'}
                        a1=ampau(i,n)*dpcorfac;
                        phi1=phaseau(i,n);
                        pp(n,i)=phi1;
                        % Minimum depth of 1 m !
                        a2=ampaz(i,n)*sqrt(9.81/max(-handles.Model(md).Input(id).openBoundaries(n).depth(1),1));
                        phi2=phaseaz(i,n);
                        
                        phi1=pi*phi1/180;
                        phi2=pi*phi2/180;
                        
                        switch lower(handles.Model(md).Input(id).openBoundaries(n).side)
                            case{'left','bottom'}
                                [a3,phi3]=combinesin(a1,phi1,a2,phi2);
                            case{'top','right'}
                                [a3,phi3]=combinesin(a1,phi1,-a2,phi2);
                        end
                        
                        phi3=180*phi3/pi;
                        phi3=mod(phi3,360);
                        
                        handles.Model(md).Input(id).astronomicComponentSets(k).amplitude(i)=a3;
                        handles.Model(md).Input(id).astronomicComponentSets(k).phase(i)=phi3;
                end
                
                handles.Model(md).Input(id).astronomicComponentSets(k).correction(i)=0;
                handles.Model(md).Input(id).astronomicComponentSets(k).amplitudeCorrection(i)=0;
                handles.Model(md).Input(id).astronomicComponentSets(k).phaseCorrection(i)=0;
            end
            
            % Side B
            k=k+1;
            if igetvel
                dpcorfac=-1/handles.Model(md).Input(id).openBoundaries(n).depth(2);
            end
            handles.Model(md).Input(id).astronomicComponentSets(k).name=handles.Model(md).Input(id).openBoundaries(n).compB;
            handles.Model(md).Input(id).astronomicComponentSets(k).nr=NrCons;
            for i=1:NrCons
                handles.Model(md).Input(id).astronomicComponentSets(k).component{i}=upper(Constituents(i).name);
                
                switch lower(handles.Model(md).Input(id).openBoundaries(n).type)
                    case{'z'}
                        handles.Model(md).Input(id).astronomicComponentSets(k).amplitude(i)=ampbz(i,n);
                        handles.Model(md).Input(id).astronomicComponentSets(k).phase(i)=phasebz(i,n);
                    case{'c'}
                        handles.Model(md).Input(id).astronomicComponentSets(k).amplitude(i)=ampbu(i,n)*dpcorfac;
                        handles.Model(md).Input(id).astronomicComponentSets(k).phase(i)=phasebu(i,n);
                    case{'r'}
                        a1=ampbu(i,n)*dpcorfac;
                        phi1=phasebu(i,n);
                        % Minimum depth of 1 m !
                        a2=ampbz(i,n)*sqrt(9.81/max(-handles.Model(md).Input(id).openBoundaries(n).depth(2),1));
                        phi2=phasebz(i,n);
                        
                        phi1=pi*phi1/180;
                        phi2=pi*phi2/180;
                        
                        switch lower(handles.Model(md).Input(id).openBoundaries(n).side)
                            case{'left','bottom'}
                                [a3,phi3]=combinesin(a1,phi1,a2,phi2);
                            case{'top','right'}
                                [a3,phi3]=combinesin(a1,phi1,-a2,phi2);
                        end
                        
                        phi3=180*phi3/pi;
                        phi3=mod(phi3,360);
                        
                        handles.Model(md).Input(id).astronomicComponentSets(k).amplitude(i)=a3;
                        handles.Model(md).Input(id).astronomicComponentSets(k).phase(i)=phi3;
                end
                
                handles.Model(md).Input(id).astronomicComponentSets(k).correction(i)=0;
                handles.Model(md).Input(id).astronomicComponentSets(k).amplitudeCorrection(i)=0;
                handles.Model(md).Input(id).astronomicComponentSets(k).phaseCorrection(i)=0;
            end
        end
    end
    handles.Model(md).Input(id).nrAstronomicComponentSets=k;
    
    attName=handles.Model(md).Input(id).attName;
    handles.Model(md).Input(id).bcaFile=[attName '.bca'];
    
    ddb_saveBcaFile(handles,id);
    ddb_saveBndFile(handles,id);
    
catch
    err='An error occured while generating boundary conditions!';
    a=lasterror;
    disp(a.message);
end

close(wb);
