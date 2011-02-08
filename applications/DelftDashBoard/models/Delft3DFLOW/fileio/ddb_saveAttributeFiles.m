function handles=ddb_saveAttributeFiles(handles,id,opt)

sall=0;
if strcmpi(opt,'saveallas')
    sall=1;
end

if handles.Model(md).Input(id).NrOpenBoundaries>0

    handles=ddb_sortBoundaries(handles,id);

    if isempty(handles.Model(md).Input(id).BndFile) || sall
        [filename, pathname, filterindex] = uiputfile('*.bnd', 'Select Boundary Definitions File','');
        curdir=[lower(cd) '\'];
        if ~strcmpi(curdir,pathname)
            filename=[pathname filename];
        end
        handles.Model(md).Input(id).BndFile=filename;
    end
    ddb_saveBndFile(handles,id);
    
    handles=ddb_countOpenBoundaries(handles,id);

    if handles.Model(md).Input(id).NrAstro>0
        if isempty(handles.Model(md).Input(id).BcaFile) || sall
            [filename, pathname, filterindex] = uiputfile('*.bca', 'Select Astronomic Conditions File','');
            curdir=[lower(cd) '\'];
            if ~strcmpi(curdir,pathname)
                filename=[pathname filename];
            end
            handles.Model(md).Input(id).BcaFile=filename;
        end
        ddb_saveBcaFile(handles,id);
    end

    if handles.Model(md).Input(id).NrCor>0
        if isempty(handles.Model(md).Input(id).CorFile) || sall
            [filename, pathname, filterindex] = uiputfile('*.cor', 'Select Astronomic Corrections File','');
            curdir=[lower(cd) '\'];
            if ~strcmpi(curdir,pathname)
                filename=[pathname filename];
            end
            handles.Model(md).Input(id).CorFile=filename;
        end
        ddb_saveCorFile(handles,id);
    end

    if handles.Model(md).Input(id).NrHarmo>0
        if isempty(handles.Model(md).Input(id).BchFile) || sall
            [filename, pathname, filterindex] = uiputfile('*.bch', 'Select Harmonic Conditions File','');
            curdir=[lower(cd) '\'];
            if ~strcmpi(curdir,pathname)
                filename=[pathname filename];
            end
            handles.Model(md).Input(id).BchFile=filename;
        end
        ddb_saveBchFile(handles,id);
    end

    if handles.Model(md).Input(id).NrTime>0
        if isempty(handles.Model(md).Input(id).BctFile) || sall
            [filename, pathname, filterindex] = uiputfile('*.bct', 'Select Time Series Conditions File','');
            curdir=[lower(cd) '\'];
            if ~strcmpi(curdir,pathname)
                filename=[pathname filename];
            end
            handles.Model(md).Input(id).BctFile=filename;
        end
        ddb_saveBctFile(handles,id);
    end

    incconst=handles.Model(md).Input(id).Salinity.Include || handles.Model(md).Input(id).Temperature.Include || handles.Model(md).Input(id).Sediments || handles.Model(md).Input(id).Tracers;
    if incconst
        if isempty(handles.Model(md).Input(id).BccFile) || sall
            [filename, pathname, filterindex] = uiputfile('*.bcc', 'Select Transport Conditions File','');
            curdir=[lower(cd) '\'];
            if ~strcmpi(curdir,pathname)
                filename=[pathname filename];
            end
            handles.Model(md).Input(id).BccFile=filename;
        end
        ddb_saveBccFile(handles,id);
    end

end


if handles.Model(md).Input(id).NrObservationPoints>0
    if isempty(handles.Model(md).Input(id).ObsFile) || sall
        [filename, pathname, filterindex] = uiputfile('*.obs', 'Select Observation Points File','');
        curdir=[lower(cd) '\'];
        if ~strcmpi(curdir,pathname)
            filename=[pathname filename];
        end
        handles.Model(md).Input(id).ObsFile=filename;
    end
    ddb_saveObsFile(handles,id);
end

if handles.Model(md).Input(id).NrCrossSections>0
    if isempty(handles.Model(md).Input(id).CrsFile) || sall
        [filename, pathname, filterindex] = uiputfile('*.crs', 'Select Cross Sections File','');
        curdir=[lower(cd) '\'];
        if ~strcmpi(curdir,pathname)
            filename=[pathname filename];
        end
        handles.Model(md).Input(id).CrsFile=filename;
    end
    ddb_saveCrsFile(handles,id);
end

if handles.Model(md).Input(id).nrDryPoints>0
    if isempty(handles.Model(md).Input(id).DryFile) || sall
        [filename, pathname, filterindex] = uiputfile('*.dry', 'Select Dry Points File','');
        curdir=[lower(cd) '\'];
        if ~strcmpi(curdir,pathname)
            filename=[pathname filename];
        end
        handles.Model(md).Input(id).DryFile=filename;
    end
    ddb_saveDryFile(handles,id);
end

if handles.Model(md).Input(id).NrThinDams>0
    if isempty(handles.Model(md).Input(id).ThdFile) || sall
        [filename, pathname, filterindex] = uiputfile('*.thd', 'Select Thin Dams File','');
        curdir=[lower(cd) '\'];
        if ~strcmpi(curdir,pathname)
            filename=[pathname filename];
        end
        handles.Model(md).Input(id).ThdFile=filename;
    end
    ddb_saveThdFile(handles,id);
end

if handles.Model(md).Input(id).NrDischarges>0

    if isempty(handles.Model(md).Input(id).SrcFile) || sall
        [filename, pathname, filterindex] = uiputfile('*.src', 'Select Discharge Locations File','');
        curdir=[lower(cd) '\'];
        if ~strcmpi(curdir,pathname)
            filename=[pathname filename];
        end
        handles.Model(md).Input(id).SrcFile=filename;
    end
    ddb_saveSrcFile(handles,id);

    if isempty(handles.Model(md).Input(id).DisFile) || sall
        [filename, pathname, filterindex] = uiputfile('*.dis', 'Select Discharge File','');
        curdir=[lower(cd) '\'];
        if ~strcmpi(curdir,pathname)
            filename=[pathname filename];
        end
        handles.Model(md).Input(id).DisFile=filename;
    end
    ddb_saveDisFile(handles,id);
end
