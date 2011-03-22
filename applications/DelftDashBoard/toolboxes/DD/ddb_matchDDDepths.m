function [z1,z2]=ddb_matchDDDepths(ddbound,z1,z2,runid1,runid2,dpsopt)

% Changes first two to depth rows in finer domain

for k=1:length(ddbound)
    
    ddb=ddbound(k);
    
    dom1=0;

    % Check if domain 1 or 2 is the coarser one for this boundary

    if strcmpi(ddb.runid1,runid1) && strcmpi(ddb.runid2,runid2)

        if ddb.m1a==ddb.m1b
            % Vertical line
            if ddb.n1b-ddb.n1a<=ddb.n2b-ddb.n2a
                % Domain 1 is coarser
                dom1=1;
            else
                % Domain 2 is coarser
                dom1=2;
            end
        else
            % Horizontal line
            if ddb.m1b-ddb.m1a<=ddb.m2b-ddb.m2a
                % Domain 1 is coarser
                dom1=1;
            else
                % Domain 2 is coarser
                dom1=2;
            end
        end
        
    elseif strcmpi(ddb.runid1,runid2) && strcmpi(ddb.runid2,runid1)

        if ddb.m1a==ddb.m1b
            % Vertical line
            if ddb.n1b-ddb.n1a<=ddb.n2b-ddb.n2a
                % Domain 1 is coarser
                dom1=2;
            else
                % Domain 2 is coarser
                dom1=1;
            end
        else
            % Horizontal line
            if ddb.m1b-ddb.m1a<=ddb.m2b-ddb.m2a
                % Domain 1 is coarser
                dom1=2;
            else
                % Domain 2 is coarser
                dom1=1;
            end
        end
    
    end

    if dom1==1
        % Domain 1 is coarser
        ddb=ddbound(k);
%         ddb.m1a=ddbound(k).m1a;
%         ddb.m1b=ddbound(k).m1b;
%         ddb.n1a=ddbound(k).n1a;
%         ddb.n1b=ddbound(k).n1b;
%         ddb.m2a=ddbound(k).m2a;
%         ddb.m2b=ddbound(k).m2b;
%         ddb.n2a=ddbound(k).n2a;
%         ddb.n2b=ddbound(k).n2b;
%         ddb.runid1=runid1;
%         ddb.runid2=runid2;
%         zz1=z1;
%         zz2=z2;
        z2=matchDepths(z1,z2,runid1,runid2,ddb,dpsopt);
%         z2=zz2;
    elseif dom1==2
        % Domain 2 is coarser
        ddb=ddbound(k);
%         ddb.m1a=ddbound(k).m2a;
%         ddb.m1b=ddbound(k).m2b;
%         ddb.n1a=ddbound(k).n2a;
%         ddb.n1b=ddbound(k).n2b;
%         ddb.m2a=ddbound(k).m1a;
%         ddb.m2b=ddbound(k).m1b;
%         ddb.n2a=ddbound(k).n1a;
%         ddb.n2b=ddbound(k).n1b;
%         ddb.runid1=runid2;
%         ddb.runid2=runid1;
%         zz1=z2;
%         zz2=z1;
        z1=matchDepths(z2,z1,runid2,runid1,ddb,dpsopt);
%         z1=zz2;
    end
    
end

%%
function z2=matchDepths(z1,z2,runid1,runid2,ddb,dpsopt)
% Adjust depth z2 (finer domain). Runid1 is the coarse domain!

if strcmpi(dpsopt,'dp')
    madd=0;
else
    madd=1;
end

z1=GetDepthZ(z1,dpsopt);

if strcmpi(ddb.runid1,runid1) && strcmpi(ddb.runid2,runid2)
    % Coarse domain to the left/bottom of fine domain
    m1a=ddb.m1a;
    m1b=ddb.m1b;
    n1a=ddb.n1a;
    n1b=ddb.n1b;
    m2a=ddb.m2a;
    m2b=ddb.m2b;
    n2a=ddb.n2a;
    n2b=ddb.n2b;
    if ddb.m1a==ddb.m1b
        % Coarse domain at left
        nref=(n2b-n2a)/(n1b-n1a);
        j=0;
        for n=n1a+1:n1b
            j=j+1;
            ma=m2a;
            mb=m2a+1;
            na=n2a+(j-1)*nref+1;
            nb=n2a+j*nref;
            z2(ma:mb,na:nb)=z1(m1a,n);
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
            z2(ma:mb,na:nb)=z1(m,n1a);
        end
    end
elseif strcmpi(ddb.runid2,runid1) && strcmpi(ddb.runid1,runid2)
    % Coarse domain to the right/top of fine domain
    m1a=ddb.m2a;
    m1b=ddb.m2b;
    n1a=ddb.n2a;
    n1b=ddb.n2b;
    m2a=ddb.m1a;
    m2b=ddb.m1b;
    n2a=ddb.n1a;
    n2b=ddb.n1b;
    if ddb.m1a==ddb.m1b
        % Coarse domain at right
        nref=(n2b-n2a)/(n1b-n1a);
        j=0;
        for n=n1a+1:n1b
            j=j+1;
            ma=m2a-madd;
            mb=m2a;
            na=n2a+(j-1)*nref+1;
            nb=n2a+j*nref;
            z2(ma:mb,na:nb)=z1(m1a+1,n);
        end
    else
        % Coarse domain at top
        mref=(m2b-m2a)/(m1b-m1a);
        j=0;
        for m=m1a+1:m1b
            j=j+1;
            na=n2a-madd;
            nb=n2a;
            ma=m2a+(j-1)*mref+1;
            mb=m2a+j*mref;
            z2(ma:mb,na:nb)=z1(m,n1a+1);
        end
    end
else
    % Different domains
end

