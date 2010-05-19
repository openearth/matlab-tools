function handles=ddb_generateBoundaryConditionsDelft3DFLOW(handles,id,varargin)

if ~isempty(varargin)
    % Check if routine exists
    if strcmpi(varargin{1},'ddb_test')
        return
    end
end


if handles.Model(md).Input(id).NrOpenBoundaries>0

    wb = waitbox('Generating Boundary Conditions ...');

    AttName=get(handles.GUIHandles.EditAttributeName,'String');
    handles.Model(md).Input(id).BcaFile=[AttName '.bca'];

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
        if xa(i)<0
            xa(i)=xa(i)+360;
        end
        if xb(i)<0
            xb(i)=xb(i)+360;
        end
    end
    xa(find(xa<0.125 & xa>0))=360;
    xa(find(xa<0.250 & xa>0.125))=0.25;
    xb(find(xb<0.125 & xb>0))=360;
    xb(find(xb<0.250 & xb>0.125))=0.25;
    
    xx=[xa xb];
    yy=[ya yb];
    
    [amp,phase,depth,ConList]=extract_HC([handles.TideDir handles.TideModelData.ActiveTideModelBC],yy,xx,'z');

    ampa=amp(:,1:handles.Model(md).Input(id).NrOpenBoundaries);
    ampb=amp(:,handles.Model(md).Input(id).NrOpenBoundaries+1:end);
    phasea=phase(:,1:handles.Model(md).Input(id).NrOpenBoundaries);
    phaseb=phase(:,handles.Model(md).Input(id).NrOpenBoundaries+1:end);

    NrCons=size(ConList,1);
    for i=1:NrCons
        Constituents(i).Name=ConList(i,:);
    end
    
    k=0;
    ampa(isnan(ampa))=0.0;
    ampb(isnan(ampb))=0.0;
    phasea(isnan(phasea))=0.0;
    phaseb(isnan(phaseb))=0.0;
    for n=1:nb
        if strcmp(handles.Model(md).Input(id).OpenBoundaries(n).Forcing,'A')
            handles.Model(md).Input(id).OpenBoundaries(n).CompA=[handles.Model(md).Input(id).OpenBoundaries(n).Name 'A'];
            handles.Model(md).Input(id).OpenBoundaries(n).CompB=[handles.Model(md).Input(id).OpenBoundaries(n).Name 'B'];
            k=k+1;
            handles.Model(md).Input(id).AstronomicComponentSets(k).Name=handles.Model(md).Input(id).OpenBoundaries(n).CompA;
            handles.Model(md).Input(id).AstronomicComponentSets(k).Nr=NrCons;
            for i=1:NrCons
                handles.Model(md).Input(id).AstronomicComponentSets(k).Component{i}=upper(Constituents(i).Name);
                handles.Model(md).Input(id).AstronomicComponentSets(k).Amplitude(i)=ampa(i,n);
                handles.Model(md).Input(id).AstronomicComponentSets(k).Phase(i)=phasea(i,n);
                handles.Model(md).Input(id).AstronomicComponentSets(k).Correction(i)=0;
                handles.Model(md).Input(id).AstronomicComponentSets(k).AmplitudeCorrection(i)=0;
                handles.Model(md).Input(id).AstronomicComponentSets(k).PhaseCorrection(i)=0;
            end
            k=k+1;
            handles.Model(md).Input(id).AstronomicComponentSets(k).Name=handles.Model(md).Input(id).OpenBoundaries(n).CompB;
            handles.Model(md).Input(id).AstronomicComponentSets(k).Nr=NrCons;
            for i=1:NrCons
                handles.Model(md).Input(id).AstronomicComponentSets(k).Component{i}=upper(Constituents(i).Name);
                handles.Model(md).Input(id).AstronomicComponentSets(k).Amplitude(i)=ampb(i,n);
                handles.Model(md).Input(id).AstronomicComponentSets(k).Phase(i)=phaseb(i,n);
                handles.Model(md).Input(id).AstronomicComponentSets(k).Correction(i)=0;
                handles.Model(md).Input(id).AstronomicComponentSets(k).AmplitudeCorrection(i)=0;
                handles.Model(md).Input(id).AstronomicComponentSets(k).PhaseCorrection(i)=0;
            end
        end
    end
    handles.Model(md).Input(id).NrAstronomicComponentSets=k;

    ddb_saveBcaFile(handles,id);
    ddb_saveBndFile(handles,id);

    close(wb);
    
else
    GiveWarning('Warning','First generate or load open boundaries');
end


