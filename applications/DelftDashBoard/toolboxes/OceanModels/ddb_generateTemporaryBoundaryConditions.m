function [openBoundaries,astronomicComponentSets]=ddb_generateTemporaryBoundaryConditions(openBoundaries,tidefile,activeCS)
   
% Generate boundary conditions

nb=length(openBoundaries);

cs.name='WGS 84';
cs.type='Geographic';

for i=1:nb
    xa(i)=openBoundaries(i).x(1);
    ya(i)=openBoundaries(i).y(1);
    xb(i)=openBoundaries(i).x(end);
    yb(i)=openBoundaries(i).y(end);
    [xa(i),ya(i)]=ddb_coordConvert(xa(i),ya(i),activeCS,cs);
    [xb(i),yb(i)]=ddb_coordConvert(xb(i),yb(i),activeCS,cs);
end

xx=[xa xb];
yy=[ya yb];

igetwl=0;
for i=1:nb
    if strcmpi(openBoundaries(i).forcing,'A')
        switch lower(openBoundaries(i).type)
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
    if strcmpi(openBoundaries(i).forcing,'A')
        switch lower(openBoundaries(i).type)
            case{'r','c'}
                igetvel=1;
        end
    end
end

if igetvel
    
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
        
        bnd=openBoundaries(n);
        dx=bnd.x(2)-bnd.x(1);
        dy=bnd.y(2)-bnd.y(1);
        if strcmpi(bnd.orientation,'negative')
            dx=dx*-1;
            dy=dy*-1;
        end
        
        alphaa=180*atan2(dy,dx)/pi;
        alphab=180*atan2(dy,dx)/pi;
        
        switch lower(openBoundaries(n).side)
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
    if strcmp(openBoundaries(n).forcing,'A')
        
        openBoundaries(n).compA=[openBoundaries(n).name 'A'];
        openBoundaries(n).compB=[openBoundaries(n).name 'B'];
        
        % Side A
        k=k+1;
        if igetvel
            %                disp(openBoundaries(n).name);
            dpcorfac=openBoundaries(n).depth(1)/deptha(n);
            %                disp(openBoundaries(n).depth(1));
            %                disp(deptha(n));
            %                 dpcorfac=max(min(dpcorfac,1.5),0.75);
            %                 dpcorfac=1;
        end
        astronomicComponentSets(k).name=openBoundaries(n).compA;
        astronomicComponentSets(k).nr=NrCons;
        for i=1:NrCons
            
            astronomicComponentSets(k).component{i}=upper(Constituents(i).name);
            
            switch lower(openBoundaries(n).type)
                case{'z'}
                    astronomicComponentSets(k).amplitude(i)=ampaz(i,n);
                    astronomicComponentSets(k).phase(i)=phaseaz(i,n);
                case{'c'}
                    astronomicComponentSets(k).amplitude(i)=ampau(i,n)*dpcorfac;
                    astronomicComponentSets(k).phase(i)=phaseau(i,n);
                case{'r'}
                    a1=ampau(i,n)*dpcorfac;
                    phi1=phaseau(i,n);
                    % Minimum depth of 1 m !
                    a2=ampaz(i,n)*sqrt(9.81/max(-openBoundaries(n).depth(1),1));
                    phi2=phaseaz(i,n);
                    
                    phi1=pi*phi1/180;
                    phi2=pi*phi2/180;
                    
                    switch lower(openBoundaries(n).side)
                        case{'left','bottom'}
                            [a3,phi3]=combinesin(a1,phi1,a2,phi2);
                        case{'top','right'}
                            [a3,phi3]=combinesin(a1,phi1,-a2,phi2);
                    end
                    
                    phi3=180*phi3/pi;
                    phi3=mod(phi3,360);
                    
                    astronomicComponentSets(k).amplitude(i)=a3;
                    astronomicComponentSets(k).phase(i)=phi3;
            end
            
            astronomicComponentSets(k).correction(i)=0;
            astronomicComponentSets(k).amplitudeCorrection(i)=0;
            astronomicComponentSets(k).phaseCorrection(i)=0;
        end
        
        % Side B
        k=k+1;
        if igetvel
            dpcorfac=openBoundaries(n).depth(2)/depthb(n);
            %                 dpcorfac=max(min(dpcorfac,1.5),0.75);
            %                 dpcorfac=1;
        end
        astronomicComponentSets(k).name=openBoundaries(n).compB;
        astronomicComponentSets(k).nr=NrCons;
        for i=1:NrCons
            astronomicComponentSets(k).component{i}=upper(Constituents(i).name);
            
            switch lower(openBoundaries(n).type)
                case{'z'}
                    astronomicComponentSets(k).amplitude(i)=ampbz(i,n);
                    astronomicComponentSets(k).phase(i)=phasebz(i,n);
                case{'c'}
                    astronomicComponentSets(k).amplitude(i)=ampbu(i,n)*dpcorfac;
                    astronomicComponentSets(k).phase(i)=phasebu(i,n);
                case{'r'}
                    a1=ampbu(i,n)*dpcorfac;
                    phi1=phasebu(i,n);
                    % Minimum depth of 1 m !
                    a2=ampbz(i,n)*sqrt(9.81/max(-openBoundaries(n).depth(2),1));
                    phi2=phasebz(i,n);
                    
                    phi1=pi*phi1/180;
                    phi2=pi*phi2/180;
                    
                    switch lower(openBoundaries(n).side)
                        case{'left','bottom'}
                            [a3,phi3]=combinesin(a1,phi1,a2,phi2);
                        case{'top','right'}
                            [a3,phi3]=combinesin(a1,phi1,-a2,phi2);
                    end
                    
                    phi3=180*phi3/pi;
                    phi3=mod(phi3,360);
                    
                    astronomicComponentSets(k).amplitude(i)=a3;
                    astronomicComponentSets(k).phase(i)=phi3;
            end
            
            astronomicComponentSets(k).correction(i)=0;
            astronomicComponentSets(k).amplitudeCorrection(i)=0;
            astronomicComponentSets(k).phaseCorrection(i)=0;
        end
    end
end
    