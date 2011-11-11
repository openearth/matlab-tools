function [handles,err]=ddb_generateBoundaryConditionsDelft3DFLOW(handles,id,varargin)

err='';

model=handles.Model(id).Input;

if ~isempty(varargin)
    % Check if routine exists
    if strcmpi(varargin{1},'ddb_test')
        return
    end
end

if model.nrOpenBoundaries==0
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
    
    % Generate boundary conditions
    
    nb=model.nrOpenBoundaries;
    
    cs.name='WGS 84';
    cs.type='Geographic';
    
    for i=1:nb
        xa(i)=model.openBoundaries(i).x(1);
        ya(i)=model.openBoundaries(i).y(1);
        xb(i)=model.openBoundaries(i).x(end);
        yb(i)=model.openBoundaries(i).y(end);
        [xa(i),ya(i)]=ddb_coordConvert(xa(i),ya(i),handles.screenParameters.coordinateSystem,cs);
        [xb(i),yb(i)]=ddb_coordConvert(xb(i),yb(i),handles.screenParameters.coordinateSystem,cs);
    end
    
    xx=[xa xb];
    yy=[ya yb];
    
    igetwl=0;
    for i=1:nb
        if strcmpi(model.openBoundaries(i).forcing,'A')
            switch lower(model.openBoundaries(i).type)
                case{'r','z'}
                    igetwl=1;
            end
        end
    end
    
    if igetwl
        
        [ampz,phasez,conList] = readTideModel(tidefile,'type','h','x',xx,'y',yy,'constituent','all');
        
        if model.timeZone~=0
            % Try to make time zone changes
            cnst=t_getconsts;
            for ic=1:size(cnst.name,1)
                cns{ic}=deblank(cnst.name(ic,:));
                frq(ic)=cnst.freq(ic);
            end
            
            for ic=1:length(conList)
                ii=strmatch(conList{ic},cns,'exact');
                freq=frq(ii); % Freq in cycles per hour
                for jj=1:size(phasez,2)
                    phasez(ic,jj)=phasez(ic,jj)+360*model.timeZone*freq;
                end
            end
            phasez=mod(phasez,360);
        end
        
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
        if strcmpi(model.openBoundaries(i).forcing,'A')
            switch lower(model.openBoundaries(i).type)
                case{'r','c'}
                    igetvel=1;
            end
        end
    end
    
    if igetvel
        
        % Riemann or current boundaries present
        
        [ampu,phaseu,ampv,phasev,depth,conList] = readTideModel(tidefile,'type','q','x',xx,'y',yy,'constituent','all','includedepth');

        if model.timeZone~=0
            % Try to make time zone changes
            cnst=t_getconsts;
            for ic=1:size(cnst.name,1)
                cns{ic}=deblank(cnst.name(ic,:));
                frq(ic)=cnst.freq(ic);
            end
            for ic=1:length(conList)
                ii=strmatch(conList{ic},cns,'exact');
                freq=frq(ii); % Freq in cycles per hour
                for jj=1:size(phasez,2)
                    phaseu(ic,jj)=phaseu(ic,jj)+360*model.timeZone*freq;
                    phasev(ic,jj)=phasev(ic,jj)+360*model.timeZone*freq;
                end
            end
            phaseu=mod(phaseu,360);
            phasev=mod(phasev,360);
        end
        
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
            
            bnd=model.openBoundaries(n);
            dx=bnd.x(2)-bnd.x(1);
            dy=bnd.y(2)-bnd.y(1);

            if strcmpi(handles.screenParameters.coordinateSystem.type,'geographic')
                % Correct dx
                dx=dx*abs(cos(bnd.y(1)*pi/180));
            end
            
            if strcmpi(bnd.orientation,'negative')
                dx=dx*-1;
                dy=dy*-1;
            end
            
            alphaa=180*atan2(dy,dx)/pi;
            alphab=180*atan2(dy,dx)/pi;
            
            switch lower(model.openBoundaries(n).side)
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
        if strcmp(model.openBoundaries(n).forcing,'A')
            
            model.openBoundaries(n).compA=[model.openBoundaries(n).name 'A'];
            model.openBoundaries(n).compB=[model.openBoundaries(n).name 'B'];
            
            % Side A
            k=k+1;
            if igetvel
                dpcorfac=-1/model.openBoundaries(n).depth(1);
            end
            model.astronomicComponentSets(k).name=model.openBoundaries(n).compA;
            model.astronomicComponentSets(k).nr=NrCons;
            for i=1:NrCons
                
                model.astronomicComponentSets(k).component{i}=upper(Constituents(i).name);
                
                switch lower(model.openBoundaries(n).type)
                    case{'z'}
                        model.astronomicComponentSets(k).amplitude(i)=ampaz(i,n);
                        model.astronomicComponentSets(k).phase(i)=phaseaz(i,n);
                    case{'c'}
                        model.astronomicComponentSets(k).amplitude(i)=ampau(i,n)*dpcorfac;
                        model.astronomicComponentSets(k).phase(i)=phaseau(i,n);
                    case{'r'}
                        a1=ampau(i,n)*dpcorfac;
                        phi1=phaseau(i,n);
                        pp(n,i)=phi1;
                        % Minimum depth of 1 m !
                        a2=ampaz(i,n)*sqrt(9.81/max(-model.openBoundaries(n).depth(1),1));
                        phi2=phaseaz(i,n);
                        
                        phi1=pi*phi1/180;
                        phi2=pi*phi2/180;
                        
                        switch lower(model.openBoundaries(n).side)
                            case{'left','bottom'}
                                [a3,phi3]=combinesin(a1,phi1,a2,phi2);
                            case{'top','right'}
                                [a3,phi3]=combinesin(a1,phi1,-a2,phi2);
                        end
                        
                        phi3=180*phi3/pi;
                        phi3=mod(phi3,360);
                        
                        model.astronomicComponentSets(k).amplitude(i)=a3;
                        model.astronomicComponentSets(k).phase(i)=phi3;
                end
                
                model.astronomicComponentSets(k).correction(i)=0;
                model.astronomicComponentSets(k).amplitudeCorrection(i)=1;
                model.astronomicComponentSets(k).phaseCorrection(i)=0;
            end
            
            % Side B
            k=k+1;
            if igetvel
                dpcorfac=-1/model.openBoundaries(n).depth(2);
            end
            model.astronomicComponentSets(k).name=model.openBoundaries(n).compB;
            model.astronomicComponentSets(k).nr=NrCons;
            for i=1:NrCons
                model.astronomicComponentSets(k).component{i}=upper(Constituents(i).name);
                
                switch lower(model.openBoundaries(n).type)
                    case{'z'}
                        model.astronomicComponentSets(k).amplitude(i)=ampbz(i,n);
                        model.astronomicComponentSets(k).phase(i)=phasebz(i,n);
                    case{'c'}
                        model.astronomicComponentSets(k).amplitude(i)=ampbu(i,n)*dpcorfac;
                        model.astronomicComponentSets(k).phase(i)=phasebu(i,n);
                    case{'r'}
                        a1=ampbu(i,n)*dpcorfac;
                        phi1=phasebu(i,n);
                        % Minimum depth of 1 m !
                        a2=ampbz(i,n)*sqrt(9.81/max(-model.openBoundaries(n).depth(2),1));
                        phi2=phasebz(i,n);
                        
                        phi1=pi*phi1/180;
                        phi2=pi*phi2/180;
                        
                        switch lower(model.openBoundaries(n).side)
                            case{'left','bottom'}
                                [a3,phi3]=combinesin(a1,phi1,a2,phi2);
                            case{'top','right'}
                                [a3,phi3]=combinesin(a1,phi1,-a2,phi2);
                        end
                        
                        phi3=180*phi3/pi;
                        phi3=mod(phi3,360);
                        
                        model.astronomicComponentSets(k).amplitude(i)=a3;
                        model.astronomicComponentSets(k).phase(i)=phi3;
                end
                
                model.astronomicComponentSets(k).correction(i)=0;
                model.astronomicComponentSets(k).amplitudeCorrection(i)=1;
                model.astronomicComponentSets(k).phaseCorrection(i)=0;
            end
        end
    end
    model.nrAstronomicComponentSets=k;
    
    attName=model.attName;
    model.bcaFile=[attName '.bca'];
    
    handles.Model(id).Input=model;
    
    ddb_saveBcaFile(handles,id);
    ddb_saveBndFile(handles,id);
    
catch
    err='An error occured while generating boundary conditions!';
    a=lasterror;
    disp(a.message);
end

close(wb);
