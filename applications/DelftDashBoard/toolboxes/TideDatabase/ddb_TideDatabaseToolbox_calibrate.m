function ddb_TideDatabaseToolbox_calibrate(varargin)

if isempty(varargin)
    % New tab selected
    ddb_zoomOff;
    ddb_refreshScreen;
    setUIElements('tidedatabasepanel.calibrate');
else
    %Options selected
    opt=lower(varargin{1});
    switch opt
        case{'calibrate'}
            calibrate;
        case{'savenewfourierfile'}
            saveNewFourierFile;
    end
end

%%
function calibrate

wb = waitbox('Calibrating ...');pause(0.1);

try
    
    handles=getHandles;
    
    [x,y,comp,amp,phi]=readFourierFile(handles.Toolbox(tb).Input.fourierFile);
    
    ii=handles.Toolbox(tb).Input.activeModel;
    name=handles.tideModels.model(ii).name;
    if strcmpi(handles.tideModels.model(ii).URL(1:4),'http')
        tidefile=[handles.tideModels.model(ii).URL '/' name '.nc'];
    else
        tidefile=[handles.tideModels.model(ii).URL filesep name '.nc'];
    end
    
    bnd=handles.Model(md).Input(ad).openBoundaries;
    for ib=1:length(bnd)
        switch bnd(ib).side
            case{'left'}
                ma=bnd(ib).M1+1;
                mb=bnd(ib).M2+1;
                na=bnd(ib).N1;
                nb=bnd(ib).N2;
            case{'right'}
                ma=bnd(ib).M1-1;
                mb=bnd(ib).M2-1;
                na=bnd(ib).N1;
                nb=bnd(ib).N2;
            case{'bottom'}
                ma=bnd(ib).M1;
                mb=bnd(ib).M2;
                na=bnd(ib).N1+1;
                nb=bnd(ib).N2+1;
            case{'top'}
                ma=bnd(ib).M1;
                mb=bnd(ib).M2;
                na=bnd(ib).N1-1;
                nb=bnd(ib).N2-1;
        end
        xb(ib,1)=handles.Model(md).Input(ad).gridXZ(ma,na);
        yb(ib,1)=handles.Model(md).Input(ad).gridYZ(ma,na);
        xb(ib,2)=handles.Model(md).Input(ad).gridXZ(mb,nb);
        yb(ib,2)=handles.Model(md).Input(ad).gridYZ(mb,nb);
    end
    cs0.name='WGS 84';
    cs0.type='spherical';
    [xb,yb]=ddb_coordConvert(xb,yb,handles.screenParameters.coordinateSystem,cs0);
    
    for i=1:length(amp)
        
        [ampz,phasez,conList] = readTideModel(tidefile,'type','h','x',xb,'y',yb,'constituent',comp{i});
        ampz=squeeze(ampz);
        phasez=squeeze(phasez);
        
        for ib=1:length(bnd)
            
            compSetA=bnd(ib).compA;
            compSetB=bnd(ib).compB;
            astrosets=handles.Model(md).Input(ad).astronomicComponentSets;
            for iastr=1:length(astrosets)
                astrosetNames{iastr}=lower(astrosets(iastr).name);
            end
            isetA=strmatch(lower(compSetA),astrosetNames,'exact');
            isetB=strmatch(lower(compSetB),astrosetNames,'exact');
            
            ja=strmatch(comp{i},handles.Model(md).Input(ad).astronomicComponentSets(isetA).component,'exact');
            jb=strmatch(comp{i},handles.Model(md).Input(ad).astronomicComponentSets(isetB).component,'exact');
            
            switch bnd(ib).side
                case{'left'}
                    ma=bnd(ib).M1+1;
                    mb=bnd(ib).M2+1;
                    na=bnd(ib).N1;
                    nb=bnd(ib).N2;
                case{'right'}
                    ma=bnd(ib).M1-1;
                    mb=bnd(ib).M2-1;
                    na=bnd(ib).N1;
                    nb=bnd(ib).N2;
                case{'bottom'}
                    ma=bnd(ib).M1;
                    mb=bnd(ib).M2;
                    na=bnd(ib).N1+1;
                    nb=bnd(ib).N2+1;
                case{'top'}
                    ma=bnd(ib).M1;
                    mb=bnd(ib).M2;
                    na=bnd(ib).N1-1;
                    nb=bnd(ib).N2-1;
            end
            
            ampfaca=ampz(ib,1)/amp{i}(ma,na);
            ampfacb=ampz(ib,2)/amp{i}(mb,nb);
            if phasez(ib,1)-phi{i}(ma,na)>180
                phifaca=phasez(ib,1)-(phi{i}(ma,na)+360);
            elseif phasez(ib,1)-phi{i}(ma,na)<-180
                phifaca=phasez(ib,1)+360-phi{i}(ma,na);
            else
                phifaca=phasez(ib,1)-phi{i}(ma,na);
            end
            if phasez(ib,2)-phi{i}(mb,nb)>180
                phifacb=phasez(ib,2)-(phi{i}(mb,nb)+360);
            elseif phasez(ib,2)-phi{i}(mb,nb)<-180
                phifacb=phasez(ib,2)+360-phi{i}(mb,nb);
            else
                phifacb=phasez(ib,2)-phi{i}(mb,nb);
            end
            
            ampfaca(isnan(ampfaca))=1.0;
            ampfacb(isnan(ampfacb))=1.0;
            phifaca(isnan(phifaca))=0.0;
            phifacb(isnan(phifacb))=0.0;
            ampfaca=min(max(ampfaca,0.5),2.0);
            ampfacb=min(max(ampfacb,0.5),2.0);
            
            
            handles.Model(md).Input(ad).astronomicComponentSets(isetA).correction(ja)=1;
            handles.Model(md).Input(ad).astronomicComponentSets(isetA).amplitudeCorrection(ja)=handles.Model(md).Input(ad).astronomicComponentSets(isetA).amplitudeCorrection(ja)*ampfaca;
            handles.Model(md).Input(ad).astronomicComponentSets(isetA).phaseCorrection(ja)=handles.Model(md).Input(ad).astronomicComponentSets(isetA).phaseCorrection(ja)+phifaca;
            handles.Model(md).Input(ad).astronomicComponentSets(isetB).correction(jb)=1;
            handles.Model(md).Input(ad).astronomicComponentSets(isetB).amplitudeCorrection(jb)=handles.Model(md).Input(ad).astronomicComponentSets(isetB).amplitudeCorrection(jb)*ampfacb;
            handles.Model(md).Input(ad).astronomicComponentSets(isetB).phaseCorrection(jb)=handles.Model(md).Input(ad).astronomicComponentSets(isetB).phaseCorrection(jb)+phifacb;
            
        end
        
    end
    
    close(wb);
    
    [filename, pathname, filterindex] = uiputfile('*.cor', 'Select Astronomic Corrections File',handles.Model(md).Input(ad).corFile);
    if ~isempty(pathname)
        curdir=[lower(cd) '\'];
        if ~strcmpi(curdir,pathname)
            filename=[pathname filename];
        end
        handles.Model(md).Input(ad).corFile=filename;
        handles=ddb_saveCorFile(handles,ad);
        handles=ddb_countOpenBoundaries(handles,ad);
        setHandles(handles);
    end
    
catch
    close(wb);
    giveWarning('text','An error occured while calibrating!');
end


%%
function saveNewFourierFile

handles=getHandles;

wb = waitbox('Saving ...');pause(0.1);

[x,y,comp,amp,phi]=readFourierFile(handles.Toolbox(tb).Input.fourierFile);
ddb_saveAstroMapFile(handles.Toolbox(tb).Input.fourierOutFile,x,y,comp,amp,phi);

close(wb);

%%
function [x,y,comp,amp,phi]=readFourierFile(fname)

fi=tekal('read',fname);

for i=1:length(fi.Field)
    mmax=fi.Field(i).Size(3);
    nmax=fi.Field(i).Size(4);
    str=fi.Field(i).Name;
    str=strread(str,'%s','delimiter',' ');
    f(i)=str2double(str{3});
    x=squeeze(fi.Field(i).Data(:,:,1));
    y=squeeze(fi.Field(i).Data(:,:,2));
    amp0=squeeze(fi.Field(i).Data(:,:,7));
    phi0=squeeze(fi.Field(i).Data(:,:,8));
    kcs0=squeeze(fi.Field(i).Data(:,:,9));
    kfu0=squeeze(fi.Field(i).Data(:,:,10));
    kfv0=squeeze(fi.Field(i).Data(:,:,11));
    x=reshape(x,mmax,nmax);
    y=reshape(y,mmax,nmax);
    amp0=reshape(amp0,mmax,nmax);
    phi0=reshape(phi0,mmax,nmax);
    kcs0=reshape(kcs0,mmax,nmax);
    kfu0=reshape(kfu0,mmax,nmax);
    kfv0=reshape(kfv0,mmax,nmax);
    x(x==999.999)=NaN;
    y(y==999.999)=NaN;
    amp0(amp0==999.999)=NaN;
    phi0(phi0==999.999)=NaN;
    amp{i}=amp0;
    phi{i}=phi0;
    amp{i}(kcs0+kfu0+kfv0<3)=NaN;
    phi{i}(kcs0+kfu0+kfv0<3)=NaN;
end

const=t_getconsts;
freqs=const.freq; % freq in cycles per hour
freqs=360*freqs;

for i=1:length(amp)
    ifreq= abs(freqs-f(i))==min(abs(freqs-f(i)));
    comp{i}=deblank(upper(const.name(ifreq,:)));
end
