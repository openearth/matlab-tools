function handles=GenerateBoundaryLocationsDelft3DFLOW(handles,id,varargin)

if ~isempty(varargin)
    % Check if routine exists
    if strcmpi(varargin{1},'test')
        return
    end
end

tb=strmatch('ModelMaker',{handles.Toolbox(:).Name},'exact');

if ~isempty(handles.Model(handles.ActiveModel.Nr).Input(id).GrdFile)
    if ~isempty(handles.Model(handles.ActiveModel.Nr).Input(id).DepFile)

        d=handles.Toolbox(tb).Input.SectionLength;
        zmax=handles.Toolbox(tb).Input.ZMax;

        AttName=get(handles.GUIHandles.EditAttributeName,'String');

        handles.Model(handles.ActiveModel.Nr).Input(id).BndFile=[AttName '.bnd'];

        x=handles.Model(handles.ActiveModel.Nr).Input(id).GridX;
        y=handles.Model(handles.ActiveModel.Nr).Input(id).GridY;
        z=handles.Model(handles.ActiveModel.Nr).Input(id).Depth;

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
                            handles.Model(handles.ActiveModel.Nr).Input(id).Depth(m,n(j))<zmax
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
                            handles.Model(handles.ActiveModel.Nr).Input(id).Depth(m,n(j))<zmax
                        mend=m;
                    else
                        break
                    end
                    m=m+1;
                end
                if mstart>0 && mend>0
%                    if mean([handles.Model(handles.ActiveModel.Nr).Input(id).Depth(mstart-1,n(j)) handles.Model(handles.ActiveModel.Nr).Input(id).Depth(mend,n(j))])<zmax
                        nb=nb+1;
                        nd=nd+1;
                        handles.Model(handles.ActiveModel.Nr).Input(id).OpenBoundaries(nb).M1=mstart;
                        handles.Model(handles.ActiveModel.Nr).Input(id).OpenBoundaries(nb).M2=mend;
                        handles.Model(handles.ActiveModel.Nr).Input(id).OpenBoundaries(nb).N1=n2(j);
                        handles.Model(handles.ActiveModel.Nr).Input(id).OpenBoundaries(nb).N2=n2(j);
                        handles=InitializeBoundary(handles,nb);
                        handles.Model(handles.ActiveModel.Nr).Input(id).OpenBoundaries(nb).Name=[dir{j} num2str(nd)];
%                         handles.Model(handles.ActiveModel.Nr).Input(id).OpenBoundaries(nb).X1=x(mstart-1,n(j));
%                         handles.Model(handles.ActiveModel.Nr).Input(id).OpenBoundaries(nb).Y1=y(mstart-1,n(j));
%                         handles.Model(handles.ActiveModel.Nr).Input(id).OpenBoundaries(nb).X2=x(mend,n(j));
%                         handles.Model(handles.ActiveModel.Nr).Input(id).OpenBoundaries(nb).Y2=y(mend,n(j));
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
                            handles.Model(handles.ActiveModel.Nr).Input(id).Depth(m(j),n)<zmax
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
                            handles.Model(handles.ActiveModel.Nr).Input(id).Depth(m(j),n)<zmax
                        nend=n;
                    else
                        break
                    end
                    n=n+1;
                end
                if nstart>0 && nend>0
%                    if mean([handles.Model(handles.ActiveModel.Nr).Input(id).Depth(m(j),nstart-1) handles.Model(handles.ActiveModel.Nr).Input(id).Depth(m(j),nend)])<zmax
                        nb=nb+1;
                        nd=nd+1;
                        handles.Model(handles.ActiveModel.Nr).Input(id).OpenBoundaries(nb).M1=m2(j);
                        handles.Model(handles.ActiveModel.Nr).Input(id).OpenBoundaries(nb).M2=m2(j);
                        handles.Model(handles.ActiveModel.Nr).Input(id).OpenBoundaries(nb).N1=nstart;
                        handles.Model(handles.ActiveModel.Nr).Input(id).OpenBoundaries(nb).N2=nend;
                        handles=InitializeBoundary(handles,nb);
                        handles.Model(handles.ActiveModel.Nr).Input(id).OpenBoundaries(nb).Name=[dir{j} num2str(nd)];
%                         handles.Model(handles.ActiveModel.Nr).Input(id).OpenBoundaries(nb).X1=x(m(j),nstart-1);
%                         handles.Model(handles.ActiveModel.Nr).Input(id).OpenBoundaries(nb).Y1=y(m(j),nstart-1);
%                         handles.Model(handles.ActiveModel.Nr).Input(id).OpenBoundaries(nb).X2=x(m(j),nend);
%                         handles.Model(handles.ActiveModel.Nr).Input(id).OpenBoundaries(nb).Y2=y(m(j),nend);
%                    end
                end
            end
        end

        handles.Model(handles.ActiveModel.Nr).Input(id).NrOpenBoundaries=nb;

        handles=CountOpenBoundaries(handles,id);

        PlotFlowAttributes(handles,'OpenBoundaries','plot',id,0,1);

        SaveBndFile(handles,id);

    else
        GiveWarning('Warning','First generate or load a bathymetry');
    end
else
    GiveWarning('Warning','First generate or load a grid');
end
