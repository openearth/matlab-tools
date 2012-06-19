function [c0,h,wp]=contourf_mvo(x0,y0,z0,col,clmap)

c0=[];
h=[];
wp=[];

colormap(clmap);

nocol=size(col,2)-1;
 
z0max=max(max(z0));
z0min=min(min(z0));
 
if z0max==z0min
    for i=1:nocol
        if z0max>=col(i) && z0max<col(i+1)
            unicol=i;
        end
    end
    if z0max<=col(1)
        unicol=1;
    end
    if z0max>=col(end)
        unicol=nocol;
    end
    for i=1:size(z0,1);
        for j=1:size(z0,2);
            r(i,j)=col(1)+(col(end)-col(1))*(i/size(z0,1));
        end
    end
    z0=z0+0.01*r;
end

%[c0,h]=mp_contourfcorr(x0,y0,z0,col);hold on;
[c0,h]=contourf(x0,y0,z0,col);hold on;
cvbb=get(h);
set(h,'EdgeColor','none');
% sz=size(cvbb,1);
% for i=1:sz
%     set(h(i),'EdgeColor','none');
%     val(i)=get(h(i),'CData');
%     for j=1:nocol
%         if val(i)==col(j)
%              set(h(i),'FaceColor',clmap(max(1,j),:));
%         end
%     end
% end

clear x1;
clear y1;

jj=1;
wp=[];

mmax=size(x0,1);
nmax=size(x0,2);
for i=2:mmax-1
    for j=2:nmax-1
        if isfinite(z0(i,j))
            k(1)=isfinite(z0(i-1,j+1));
            k(2)=isfinite(z0(i  ,j+1));
            k(3)=isfinite(z0(i+1,j+1));
            k(4)=isfinite(z0(i+1,j  ));
            k(5)=isfinite(z0(i+1,j-1));
            k(6)=isfinite(z0(i  ,j-1));
            k(7)=isfinite(z0(i-1,j-1));
            k(8)=isfinite(z0(i-1,j  ));
            ktot=sum(k);
            fac=0.2;
            z1=zeros(5);
            if k<8;
                if k(8) && k(2) && ~k(1)
                    x1(1)=x0(i-1,j  );
                    x1(3)=x0(i  ,j+1);
                    x1(4)=x0(i  ,j  );
                    x1(5)=x1(1);
                    cen=0.5*(x1(3)+x1(1));
                    x1(2)=cen-fac*(x1(4)-cen);
                    y1(1)=y0(i-1,j  );
                    y1(3)=y0(i  ,j+1);
                    y1(4)=y0(i  ,j  );
                    y1(5)=y1(1);
                    cen=0.5*(y1(3)+y1(1));
                    y1(2)=cen-fac*(y1(4)-cen);
                    wp(jj)=patch(x1,y1,z1,[1 1 1],'LineStyle','none');
                    jj=jj+1;
                end
                if k(2) && k(4) && ~k(3)
                    x1(1)=x0(i  ,j+1);
                    x1(3)=x0(i+1,j  );
                    x1(4)=x0(i  ,j  );
                    x1(5)=x1(1);
                    cen=0.5*(x1(3)+x1(1));
                    x1(2)=cen-fac*(x1(4)-cen);
                    y1(1)=y0(i  ,j+1);
                    y1(3)=y0(i+1,j  );
                    y1(4)=y0(i  ,j  );
                    y1(5)=y1(1);
                    cen=0.5*(y1(3)+y1(1));
                    y1(2)=cen-fac*(y1(4)-cen);
                    wp(jj)=patch(x1,y1,z1,[1 1 1],'LineStyle','none');
                    jj=jj+1;
                end
                if k(4) && k(6) && ~k(5)
                    x1(1)=x0(i+1,j  );
                    x1(3)=x0(i  ,j-1);
                    x1(4)=x0(i  ,j  );
                    x1(5)=x1(1);
                    cen=0.5*(x1(3)+x1(1));
                    x1(2)=cen-fac*(x1(4)-cen);
                    y1(1)=y0(i+1,j  );
                    y1(3)=y0(i  ,j-1);
                    y1(4)=y0(i  ,j  );
                    y1(5)=y1(1);
                    cen=0.5*(y1(3)+y1(1));
                    y1(2)=cen-fac*(y1(4)-cen);
                    wp(jj)=patch(x1,y1,z1,[1 1 1],'LineStyle','none');
                    jj=jj+1;
                end
                if k(6) && k(8) && ~k(7)
                    x1(1)=x0(i-1,j  );
                    x1(3)=x0(i  ,j-1);
                    x1(4)=x0(i  ,j  );
                    x1(5)=x1(1);
                    cen=0.5*(x1(3)+x1(1));
                    x1(2)=cen-fac*(x1(4)-cen);
                    y1(1)=y0(i-1,j  );
                    y1(3)=y0(i  ,j-1);
                    y1(4)=y0(i  ,j  );
                    y1(5)=y1(1);
                    cen=0.5*(y1(3)+y1(1));
                    y1(2)=cen-fac*(y1(4)-cen);
                    wp(jj)=patch(x1,y1,z1,[1 1 1],'LineStyle','none');
                    jj=jj+1;
                end
            end
        end
    end
end
 
