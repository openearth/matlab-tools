function z=ddb_matchDDDepths(handles,z,id1,runid1,runid2)

% Change first two to depth rows in finer domains

dpsopt=handles.Model(md).Input(id1).dpsOpt;
if strcmpi(dpsopt,'dp')
    madd=0;
else
    madd=1;
end

ndb=length(handles.Toolbox(tb).Input.DDBoundaries);
for k=1:ndb
    if strcmpi(handles.Toolbox(tb).Input.DDBoundaries(k).runid1,runid1) && strcmpi(handles.Toolbox(tb).Input.DDBoundaries(k).runid2,runid2)
        % Coarse domain to the left/bottom of fine domain
        m1a=handles.Toolbox(tb).Input.DDBoundaries(k).m1a;
        m1b=handles.Toolbox(tb).Input.DDBoundaries(k).m1b;
        n1a=handles.Toolbox(tb).Input.DDBoundaries(k).n1a;
        n1b=handles.Toolbox(tb).Input.DDBoundaries(k).n1b;
        m2a=handles.Toolbox(tb).Input.DDBoundaries(k).m2a;
        m2b=handles.Toolbox(tb).Input.DDBoundaries(k).m2b;
        n2a=handles.Toolbox(tb).Input.DDBoundaries(k).n2a;
        n2b=handles.Toolbox(tb).Input.DDBoundaries(k).n2b;
        if handles.Toolbox(tb).Input.DDBoundaries(k).m1a==handles.Toolbox(tb).Input.DDBoundaries(k).m1b
            % Coarse domain at left
            nref=(n2b-n2a)/(n1b-n1a);
            j=0;
            for n=n1a+1:n1b
                j=j+1;
                ma=m2a;
                mb=m2a+1;
                na=n2a+(j-1)*nref+1;
                nb=n2a+j*nref;
                z(ma:mb,na:nb)=handles.Model(md).Input(id1).depthZ(m1a,n);
            end
        else
            % Coarse domain at bottom
            mref=(m2b-m2a)/(m1b-m1a);
            j=0;
            for m=m1a+1:m1b
                j=j+1;
                na=n2a;
                nb=n2a+1;
                ma=m2a+(j-1)*mref+1;
                mb=m2a+j*mref;
                z(ma:mb,na:nb)=handles.Model(md).Input(id1).depthZ(m,n1a);
            end
        end
    elseif strcmpi(handles.Toolbox(tb).Input.DDBoundaries(k).runid2,runid1) && strcmpi(handles.Toolbox(tb).Input.DDBoundaries(k).runid1,runid2)
        % Coarse domain to the right/top of fine domain
        m1a=handles.Toolbox(tb).Input.DDBoundaries(k).m2a;
        m1b=handles.Toolbox(tb).Input.DDBoundaries(k).m2b;
        n1a=handles.Toolbox(tb).Input.DDBoundaries(k).n2a;
        n1b=handles.Toolbox(tb).Input.DDBoundaries(k).n2b;
        m2a=handles.Toolbox(tb).Input.DDBoundaries(k).m1a;
        m2b=handles.Toolbox(tb).Input.DDBoundaries(k).m1b;
        n2a=handles.Toolbox(tb).Input.DDBoundaries(k).n1a;
        n2b=handles.Toolbox(tb).Input.DDBoundaries(k).n1b;
        if handles.Toolbox(tb).Input.DDBoundaries(k).m1a==handles.Toolbox(tb).Input.DDBoundaries(k).m1b
            % Coarse domain at right
            nref=(n2b-n2a)/(n1b-n1a);
            j=0;
            for n=n1a+1:n1b
                j=j+1;
                ma=m2a;
                mb=m2a-madd;
                na=n2a+(j-1)*nref+1;
                nb=n2a+j*nref;
                z(ma:mb,na:nb)=handles.Model(md).Input(id1).depthZ(m1a+1,n);
            end
        else
            % Coarse domain at top
            mref=(m2b-m2a)/(m1b-m1a);
            j=0;
            for m=m1a+1:m1b
                j=j+1;
                na=n2a;
                nb=n2a-madd;
                ma=m2a+(j-1)*mref+1;
                mb=m2a+j*mref;
                z(ma:mb,na:nb)=handles.Model(md).Input(id1).depthZ(m,n1a+1);
            end
        end
    else
        % Different domains
    end
end
