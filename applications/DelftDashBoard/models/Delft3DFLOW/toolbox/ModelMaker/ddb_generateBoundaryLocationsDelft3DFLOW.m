function handles=ddb_generateBoundaryLocationsDelft3DFLOW(handles,id,varargin)

if ~isempty(varargin)
    % Check if routine exists
    if strcmpi(varargin{1},'ddb_test')
        return
    end
end

if ~isempty(handles.Model(md).Input(id).grdFile)
    if ~isempty(handles.Model(md).Input(id).depFile)

        d=handles.Toolbox(tb).Input.sectionLength;
        zmax=handles.Toolbox(tb).Input.zMax;

        attName=handles.Model(md).Input(id).attName;

        handles.Model(md).Input(id).bndFile=[attName '.bnd'];

        x=handles.Model(md).Input(id).gridX;
        y=handles.Model(md).Input(id).gridY;
        z=handles.Model(md).Input(id).depth;

        mmax=size(x,1);
        nmax=size(x,2);

        % Boundary locations

        % North and South

        dir={'North','South'};

        n=[nmax 1];
        n2=[nmax+1 1];
        nb=0;

        for j=1:2

            nd=0;
            mstart=0;
            mend=0;
            m=2;
            while m<mmax
                while m<mmax
                    % Find start point
                    if ~isnan(x(m,n(j))) && ~isnan(x(m-1,n(j))) && ...
                            handles.Model(md).Input(id).depth(m,n(j))<zmax
                        mstart=m;
                        break
                    else
                        m=m+1;
                    end
                end
                m=m+1;
                mend=0;
                while m<mstart+d && m<=mmax
                    % Find end point
                    if ~isnan(x(m,n(j))) && ~isnan(x(m-1,n(j))) && ...
                            handles.Model(md).Input(id).depth(m,n(j))<zmax
                        mend=m;
                    else
                        break
                    end
                    m=m+1;
                end
                if mstart>0 && mend>0
%                    if mean([handles.Model(md).Input(id).Depth(mstart-1,n(j)) handles.Model(md).Input(id).Depth(mend,n(j))])<zmax
                        nb=nb+1;
                        nd=nd+1;
                        handles.Model(md).Input(id).openBoundaries(nb).M1=mstart;
                        handles.Model(md).Input(id).openBoundaries(nb).M2=mend;
                        handles.Model(md).Input(id).openBoundaries(nb).N1=n2(j);
                        handles.Model(md).Input(id).openBoundaries(nb).N2=n2(j);
                        handles=ddb_initializeBoundary(handles,nb);
                        handles.Model(md).Input(id).openBoundaries(nb).name=[dir{j} num2str(nd)];
%                         handles.Model(md).Input(id).OpenBoundaries(nb).X1=x(mstart-1,n(j));
%                         handles.Model(md).Input(id).OpenBoundaries(nb).Y1=y(mstart-1,n(j));
%                         handles.Model(md).Input(id).OpenBoundaries(nb).X2=x(mend,n(j));
%                         handles.Model(md).Input(id).OpenBoundaries(nb).Y2=y(mend,n(j));
%                    end
                end
            end

        end

        % West and East
        dir={'West','East'};

        m=[1 mmax];
        m2=[1 mmax+1];

        for j=1:2

            nd=0;
            nstart=0;
            nend=0;
            n=2;
            while n<nmax
                while n<nmax
                    % Find start point
                    if ~isnan(x(m(j),n)) && ~isnan(x(m(j),n-1)) && ...
                            handles.Model(md).Input(id).depth(m(j),n)<zmax
                        nstart=n;
                        break
                    else
                        n=n+1;
                    end
                end
                n=n+1;
                nend=0;
                while n<nstart+d && n<=nmax
                    % Find end point
                    if ~isnan(x(m(j),n)) && ~isnan(x(m(j),n-1)) && ...
                            handles.Model(md).Input(id).depth(m(j),n)<zmax
                        nend=n;
                    else
                        break
                    end
                    n=n+1;
                end
                if nstart>0 && nend>0
%                    if mean([handles.Model(md).Input(id).Depth(m(j),nstart-1) handles.Model(md).Input(id).Depth(m(j),nend)])<zmax
                        nb=nb+1;
                        nd=nd+1;
                        handles.Model(md).Input(id).openBoundaries(nb).M1=m2(j);
                        handles.Model(md).Input(id).openBoundaries(nb).M2=m2(j);
                        handles.Model(md).Input(id).openBoundaries(nb).N1=nstart;
                        handles.Model(md).Input(id).openBoundaries(nb).N2=nend;
                        handles=ddb_initializeBoundary(handles,nb);
                        handles.Model(md).Input(id).openBoundaries(nb).name=[dir{j} num2str(nd)];
%                         handles.Model(md).Input(id).OpenBoundaries(nb).X1=x(m(j),nstart-1);
%                         handles.Model(md).Input(id).OpenBoundaries(nb).Y1=y(m(j),nstart-1);
%                         handles.Model(md).Input(id).OpenBoundaries(nb).X2=x(m(j),nend);
%                         handles.Model(md).Input(id).OpenBoundaries(nb).Y2=y(m(j),nend);
%                    end
                end
            end
        end

        handles.Model(md).Input(id).nrOpenBoundaries=nb;
        
        % Set boundary name in one cell array
        for ib=1:nb
            handles.Model(md).Input(ad).openBoundaryNames{ib}=handles.Model(md).Input(id).openBoundaries(ib).name;
        end
        
        handles=ddb_countOpenBoundaries(handles,id);

        handles=ddb_Delft3DFLOW_plotAttributes(handles,'plot','openboundaries','visible',1,'active',0);

        ddb_saveBndFile(handles,id);

    else
        GiveWarning('Warning','First generate or load a bathymetry');
    end
else
    GiveWarning('Warning','First generate or load a grid');
end
