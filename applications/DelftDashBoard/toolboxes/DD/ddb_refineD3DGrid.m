function [x1,y1]=ddb_refineD3DGrid(x0,y0,refm,refn)

% Refine Grid

x=zeros(size(x0)+1);
x(x==0)=NaN;
y=x;

x(1:end-1,1:end-1)=x0;
y(1:end-1,1:end-1)=y0;

for i=1:size(x,1)-1
    for j=1:size(x,2)-1
        for k=0:refm
            for l=0:refn

                i1=(i-1)*refm+k+1;
                j1=(j-1)*refn+l+1;
                con1=( isnan(x(i  ,j  )) & (k<refm & l<refn) );
                con2=( isnan(x(i+1,j  )) & (k>0    & l<refn) );
                con3=( isnan(x(i+1,j+1)) & (k>0    & l>0   ) );
                con4=( isnan(x(i  ,j+1)) & (k<refm & l>0   ) );

                if con1||con2||con3||con4
                    x4(i1,j1)=NaN;
                    y4(i1,j1)=NaN;
                else
                    
                    xa=x(i  ,j  );
                    xb=x(i+1,j  );
                    xc=x(i+1,j+1);
                    xd=x(i  ,j+1);
                    dx1=xb-xa;
                    dx2=xc-xd;

                    fac1x=1-k/refm;
                    fac2x=k/refm;
                    fac1y=1-l/refn;
                    fac2y=l/refn;

                    x2=xa+fac2x*dx1;
                    x3=xd+fac2x*dx2;
 
                    xtmp=fac1y*x2+fac2y*x3;
                    if isfinite(xtmp)
                        x1(i1,j1)=xtmp;
                    end

                    ya=y(i  ,j  );
                    yb=y(i+1,j  );
                    yc=y(i+1,j+1);
                    yd=y(i  ,j+1);
                    dy1=yd-ya;
                    dy2=yc-yb;

                    y2=ya+fac2y*dy1;
                    y3=yb+fac2y*dy2;

                    ytmp=fac1x*y2+fac2x*y3;
                    if isfinite(ytmp)
                        y1(i1,j1)=ytmp;
                    end

                end
            end
        end
    end
end

x1(x1==0)=NaN;
y1(isnan(x1))=NaN;

