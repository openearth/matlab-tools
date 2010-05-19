function handles=ddb_makeDDModelNewAttributes(handles,id1,id2,runid1,runid2,varargin)

if ~isempty(varargin)

    % Only adjust bathymetry
    fname=varargin{1};

    % Make sure depths along boundaries in both domains are the same
    z=handles.Model(md).Input(id2).Depth;
    z=ddb_matchDDDepths(handles,z,id1,runid1,runid2);
    handles.Model(md).Input(id2).Depth=z;
    handles.Model(md).Input(id2).DepthZ=GetDepthZ(z,handles.Model(md).Input(id2).DpsOpt);
    ddb_wldep('write',fname,z);
    handles.Model(md).Input(id2).DepFile=fname;

else

    % Adjust all attribute files

    % Attribute Files
    handles.Model(md).Input(id2).NrObservationPoints=0;
    handles.Model(md).Input(id2).ObsFile='';
    handles.Model(md).Input(id2).ObservationPoints=[];

    handles.Model(md).Input(id2).NrObservationPoints=0;
    handles.Model(md).Input(id2).OpenBoundaries=[];

    handles.Model(md).Input(id2).NrDryPoints=0;
    handles.Model(md).Input(id2).DryPoints=[];

    handles.Model(md).Input(id2).NrThinDams=0;
    handles.Model(md).Input(id2).ThinDams=[];

    % Bathymetry
    if isfield(handles.Model(md).Input(id1),'Depth') && size(handles.Model(md).Input(id1).Depth,1)>1

        xx=handles.GUIData.x;
        yy=handles.GUIData.y;
        zz=handles.GUIData.z;

        dpsopt=handles.Model(md).Input(id2).DpsOpt;

        switch lower(dpsopt)
            case{'DP'}
                x2=handles.Model(md).Input(id2).GridXZ;
                y2=handles.Model(md).Input(id2).GridYZ;
            otherwise
                x2=handles.Model(md).Input(id2).GridX;
                y2=handles.Model(md).Input(id2).GridY;
        end

        x2(isnan(x2))=0;
        y2(isnan(y2))=0;

        z=interp2(xx,yy,zz,x2,y2);
        handles.Model(md).Input(id2).Depth=z;

        % Make sure depths along boundaries in both domains are the same

        z=ddb_matchDDDepths(handles,z,id1,runid1,runid2);

        handles.Model(md).Input(id2).Depth=z;
        handles.Model(md).Input(id2).DepthZ=GetDepthZ(z,handles.Model(md).Input(id2).DpsOpt);

        ddb_wldep('write',[runid2 '.dep'],z);
        handles.Model(md).Input(id2).DepFile=[runid2 '.dep'];

    end

    if exist(handles.Model(md).Input(20).ObsFile)
        % overall model based on original grid
        %         nobs=ddb_obs2obs(handles.Model(md).Input(20).GrdFile,handles.Model(md).Input(id1).ObsFile,handles.Model(md).Input(id1).GrdFile,handles.Model(md).Input(id1).ObsFile);
        %         if nobs>0
        %             [name,m,n] = textread([handles.Model(md).Input(id1).ObsFile],'%21c%f%f');
        %             handles.Model(md).Input(id1).ObservationPoints=[];
        %             handles.Model(md).Input(id1).ObservationPoints.M=m;
        %             handles.Model(md).Input(id1).ObservationPoints.N=n;
        %             for i=1:length(m)
        %                 handles.Model(md).Input(id1).ObservationPoints.Name{i}=deblank(name(i,:));
        %             end
        %             handles.Model(md).Input(id2).NrObservationPoints = nobs;
        %         end
        % dd-model
        nobs=ddb_obs2obs(handles.Model(md).Input(20).GrdFile,handles.Model(md).Input(id1).ObsFile,handles.Model(md).Input(id2).GrdFile,[runid2 '.obs']);
        if nobs>0
            handles.Model(md).Input(id2).ObsFile = [runid2 '.obs']
            handles.ActiveDomain=id2;
            handles=ddb_readObsFile(handles);
            handles.ActiveDomain=id1;
            handles.Model(md).Input(id2).NrObservationPoints = nobs;
        end
    end
    if exist(handles.Model(md).Input(20).ThdFile)
        nthd=ddb_thd2thd(handles.Model(md).Input(20).GrdFile,handles.Model(md).Input(id1).ThdFile,handles.Model(md).Input(id2).GrdFile,[runid2 '.thd']);
        if nthd>0
            handles.Model(md).Input(id2).ThdFile = [runid2 '.thd'];
            handles.ActiveDomain=id2;
            handles=ddb_readThdFile(handles);
            handles.ActiveDomain=id1;
            handles.Model(md).Input(id2).NrThinDams = nthd;
        end
    end
    if exist(handles.Model(md).Input(20).DryFile)
        ndry=ddb_dry2dry(handles.Model(md).Input(20).GrdFile,handles.Model(md).Input(id1).DryFile,handles.Model(md).Input(id2).GrdFile,[runid2 '.dry']);
        if ndry>0
            handles.Model(md).Input(id2).DryFile = [runid2 '.dry'];
            handles.ActiveDomain=id2;
            handles=ddb_readDryFile(handles);
            handles.ActiveDomain=id1;
            handles.Model(md).Input(id2).NrDryPoints = ndry;
        end
    end
    if exist(handles.Model(md).Input(20).CrsFile)
        ncrs=ddb_crs2crs(handles.Model(md).Input(20).GrdFile,handles.Model(md).Input(id1).CrsFile,handles.Model(md).Input(id2).GrdFile,[runid2 '.crs']);
        if ncrs>0
            handles.Model(md).Input(id2).CrsFile = [runid2 '.crs'];
            handles.ActiveDomain=id2;
            handles=ddb_readCrsFile(handles);
            handles.ActiveDomain=id1;
            handles.Model(md).Input(id2).NrCrossSections = ncrs;
        end
    end
    if exist(handles.Model(md).Input(20).SrcFile)
        nsrc=ddb_src2src(handles.Model(md).Input(20).GrdFile,handles.Model(md).Input(id1).SrcFile,handles.Model(md).Input(id2).GrdFile,[runid2 '.src']);
        if nsrc>0
            handles.Model(md).Input(id2).SrcFile = [runid2 '.src'];
            handles.ActiveDomain=id2;
            handles=ddb_readSrcFile(handles);
            handles.ActiveDomain=id1;
            handles.Model(md).Input(id2).NrDischarges = nsrc;
        end
    end
end
