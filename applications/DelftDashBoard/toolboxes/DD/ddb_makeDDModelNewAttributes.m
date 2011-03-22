function handles=ddb_makeDDModelNewAttributes(handles,id1,id2,runid1,runid2,varargin)

if ~isempty(varargin)

%     % Only adjust bathymetry
%     fname=varargin{1};
% 
%     % Make sure depths along boundaries in both domains are the same
%     z=handles.Model(md).Input(id2).depth;
%     z=ddb_matchDDDepths(handles,z,id1,runid1,runid2);
%     handles.Model(md).Input(id2).depth=z;
%     handles.Model(md).Input(id2).depthZ=GetDepthZ(z,handles.Model(md).Input(id2).dpsOpt);
%     ddb_wldep('write',fname,z);
%     handles.Model(md).Input(id2).depFile=fname;

else

    % Adjust all attribute files

    % Attribute Files
    handles.Model(md).Input(id2).nrObservationPoints=0;
    handles.Model(md).Input(id2).obsFile='';
    handles.Model(md).Input(id2).observationPoints=[];

    handles.Model(md).Input(id2).nrObservationPoints=0;
    handles.Model(md).Input(id2).openBoundaries=[];

    handles.Model(md).Input(id2).nrDryPoints=0;
    handles.Model(md).Input(id2).dryPoints=[];

    handles.Model(md).Input(id2).nrThinDams=0;
    handles.Model(md).Input(id2).thinDams=[];

    % Bathymetry
    if isfield(handles.Model(md).Input(id1),'depth') && size(handles.Model(md).Input(id1).depth,1)>1

        xx=handles.GUIData.x;
        yy=handles.GUIData.y;
        zz=handles.GUIData.z;

        dpsopt=handles.Model(md).Input(id2).dpsOpt;

        switch lower(dpsopt)
            case{'dp'}
                x2=handles.Model(md).Input(id2).gridXZ;
                y2=handles.Model(md).Input(id2).gridYZ;
            otherwise
                x2=handles.Model(md).Input(id2).gridX;
                y2=handles.Model(md).Input(id2).gridY;
        end

        x2(isnan(x2))=0;
        y2(isnan(y2))=0;

        z=interp2(xx,yy,zz,x2,y2);
        handles.Model(md).Input(id2).depth=z;

%         % Make sure depths along boundaries in both domains are the same
% 
%         z=ddb_matchDDDepths(handles,z,id1,runid1,runid2);
% 
%         handles.Model(md).Input(id2).depth=z;
         handles.Model(md).Input(id2).depthZ=GetDepthZ(z,handles.Model(md).Input(id2).dpsOpt);
% 
%         ddb_wldep('write',[runid2 '.dep'],z);
         handles.Model(md).Input(id2).depFile=[runid2 '.dep'];

    end

    if exist(handles.Toolbox(tb).Input.originalDomain.obsFile)
        % overall model based on original grid
        %         nobs=ddb_obs2obs(handles.Toolbox(tb).Input.originalDomain.grdFile,handles.Model(md).Input(id1).obsFile,handles.Model(md).Input(id1).grdFile,handles.Model(md).Input(id1).obsFile);
        %         if nobs>0
        %             [name,m,n] = textread([handles.Model(md).Input(id1).obsFile],'%21c%f%f');
        %             handles.Model(md).Input(id1).observationPoints=[];
        %             handles.Model(md).Input(id1).observationPoints.M=m;
        %             handles.Model(md).Input(id1).observationPoints.N=n;
        %             for i=1:length(m)
        %                 handles.Model(md).Input(id1).observationPoints.Name{i}=deblank(name(i,:));
        %             end
        %             handles.Model(md).Input(id2).nrObservationPoints = nobs;
        %         end
        % dd-model
        nobs=ddb_obs2obs(handles.Toolbox(tb).Input.originalDomain.grdFile,handles.Model(md).Input(id1).obsFile,handles.Model(md).Input(id2).grdFile,[runid2 '.obs']);
        if nobs>0
            handles.Model(md).Input(id2).obsFile = [runid2 '.obs'];
            handles.activeDomain=id2;
            handles=ddb_readObsFile(handles);
            handles.activeDomain=id1;
            handles.Model(md).Input(id2).nrObservationPoints = nobs;
        end
    end
    if exist(handles.Toolbox(tb).Input.originalDomain.thdFile)
        nthd=ddb_thd2thd(handles.Toolbox(tb).Input.originalDomain.grdFile,handles.Model(md).Input(id1).thdFile,handles.Model(md).Input(id2).grdFile,[runid2 '.thd']);
        if nthd>0
            handles.Model(md).Input(id2).thdFile = [runid2 '.thd'];
            handles.activeDomain=id2;
            handles=ddb_readThdFile(handles);
            handles.activeDomain=id1;
            handles.Model(md).Input(id2).nrThinDams = nthd;
        end
    end
    if exist(handles.Toolbox(tb).Input.originalDomain.dryFile)
        ndry=ddb_dry2dry(handles.Toolbox(tb).Input.originalDomain.grdFile,handles.Model(md).Input(id1).dryFile,handles.Model(md).Input(id2).grdFile,[runid2 '.dry']);
        if ndry>0
            handles.Model(md).Input(id2).dryFile = [runid2 '.dry'];
            handles.activeDomain=id2;
            handles=ddb_readDryFile(handles);
            handles.activeDomain=id1;
            handles.Model(md).Input(id2).nrDryPoints = ndry;
        end
    end
    if exist(handles.Toolbox(tb).Input.originalDomain.crsFile)
        ncrs=ddb_crs2crs(handles.Toolbox(tb).Input.originalDomain.grdFile,handles.Model(md).Input(id1).crsFile,handles.Model(md).Input(id2).grdFile,[runid2 '.crs']);
        if ncrs>0
            handles.Model(md).Input(id2).crsFile = [runid2 '.crs'];
            handles.activeDomain=id2;
            handles=ddb_readCrsFile(handles);
            handles.activeDomain=id1;
            handles.Model(md).Input(id2).nrCrossSections = ncrs;
        end
    end
    if exist(handles.Toolbox(tb).Input.originalDomain.srcFile)
        nsrc=ddb_src2src(handles.Toolbox(tb).Input.originalDomain.grdFile,handles.Model(md).Input(id1).srcFile,handles.Model(md).Input(id2).grdFile,[runid2 '.src']);
        if nsrc>0
            handles.Model(md).Input(id2).srcFile = [runid2 '.src'];
            handles.activeDomain=id2;
            handles=ddb_readSrcFile(handles);
            handles.activeDomain=id1;
            handles.Model(md).Input(id2).nrDischarges = nsrc;
        end
    end
end
