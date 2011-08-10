function [m,n]=CheckDepth(m,n,dps)

ns=length(m);

for k=1:ns
    i=m(k);
    j=n(k);
    if i>0 && j>0
        if dps(i,j)>-1
            if i==size(dps,1)
                d(1)=999;
            else
                d(1)=dps(i+1,j);
            end
            if j==size(dps,2)
                d(2)=999;
            else
                d(2)=dps(i,j+1);
            end
            if i==1
                d(3)=999;
            else
                d(3)=dps(i-1,j);
            end
            if j==1
                d(4)=999;
            else
                d(4)=dps(i,j-1);
            end
            [dsort,ii] = sort(d);
            if dsort(1)<-1
                switch ii(1)
                    case 1
                        m(k)=i+1;
                        n(k)=j;
                    case 2
                        m(k)=i;
                        n(k)=j+1;
                    case 3
                        m(k)=i-1;
                        n(k)=j;
                    case 4
                        m(k)=i;
                        n(k)=j-1;
                end
            end
        end
    end
end
