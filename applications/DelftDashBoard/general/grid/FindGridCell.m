function [m,n]=findGridCell(posx0,posy0,x,y)

m=zeros(size(posx0));
n=zeros(size(posx0));
x1=x(1:end-1,1:end-1);
y1=y(1:end-1,1:end-1);
x2=x(2:end  ,1:end-1);
y2=y(2:end  ,1:end-1);
x3=x(2:end  ,2:end  );
y3=y(2:end  ,2:end  );
x4=x(1:end-1,2:end  );
y4=y(1:end-1,2:end  );
xmin=min(min(min(x1,x2),x3),x4);
xmax=max(max(max(x1,x2),x3),x4);
ymin=min(min(min(y1,y2),y3),y4);
ymax=max(max(max(y1,y2),y3),y4);
xmin(isnan(x1))=NaN;
xmin(isnan(x2))=NaN;
xmin(isnan(x3))=NaN;
xmin(isnan(x4))=NaN;
ymin(isnan(y1))=NaN;
ymin(isnan(y2))=NaN;
ymin(isnan(y3))=NaN;
ymin(isnan(y4))=NaN;

for j=1:length(posx0)
    posx=posx0(j);
    posy=posy0(j);
    [mm,nn]=find(xmin<=posx & xmax>=posx & ymin<=posy & ymax>=posy);
    if ~isempty(mm)
        for i=1:length(mm)
            polx=[x(mm(i),nn(i)) x(mm(i)+1,nn(i)) x(mm(i)+1,nn(i)+1) x(mm(i),nn(i)+1) ];
            poly=[y(mm(i),nn(i)) y(mm(i)+1,nn(i)) y(mm(i)+1,nn(i)+1) y(mm(i),nn(i)+1) ];
            ip=inpolygon(posx,posy,polx,poly);
            if ip==1
                m(j)=mm(i)+1;
                n(j)=nn(i)+1;
                break
            end
        end
    end
end
