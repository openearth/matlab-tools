function [m,n,uv]=FindGridLine(posx,posy,x,y)

m=0;
n=0;
uv=-1;
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
[mm,nn]=find(xmin<=posx & xmax>=posx & ymin<=posy & ymax>=posy);
if length(mm)>0
    for i=1:length(m)
        polx=[x(mm(i),nn(i)) x(mm(i)+1,nn(i)) x(mm(i)+1,nn(i)+1) x(mm(i),nn(i)+1) ];
        poly=[y(mm(i),nn(i)) y(mm(i)+1,nn(i)) y(mm(i)+1,nn(i)+1) y(mm(i),nn(i)+1) ];
        ip=inpolygon(posx,posy,polx,poly);
        if ip==1
            x0=[posx,posy];
            % top
            xx1=[x(mm(i),nn(i)+1) y(mm(i),nn(i)+1)];
            xx2=[x(mm(i)+1,nn(i)+1) y(mm(i)+1,nn(i)+1)];
            pt=sqrt((xx2(1)-xx1(1))^2  + (xx2(2)-xx1(2))^2);
            dist(1)=det([xx2-xx1 ; xx1-x0])/pt;
            % bottom
            xx1=[x(mm(i),nn(i)) y(mm(i),nn(i))];
            xx2=[x(mm(i)+1,nn(i)) y(mm(i)+1,nn(i))];
            pt=sqrt((xx2(1)-xx1(1))^2  + (xx2(2)-xx1(2))^2);
            dist(2)=det([xx2-xx1 ; xx1-x0])/pt;
            % right
            xx1=[x(mm(i)+1,nn(i))   y(mm(i)+1,nn(i))];
            xx2=[x(mm(i)+1,nn(i)+1) y(mm(i)+1,nn(i)+1)];
            pt=sqrt((xx2(1)-xx1(1))^2  + (xx2(2)-xx1(2))^2);
            dist(3)=det([xx2-xx1 ; xx1-x0])/pt;
            % left
            xx1=[x(mm(i),nn(i))   y(mm(i),nn(i))];
            xx2=[x(mm(i),nn(i)+1) y(mm(i),nn(i)+1)];
            pt=sqrt((xx2(1)-xx1(1))^2  + (xx2(2)-xx1(2))^2);
            dist(4)=det([xx2-xx1 ; xx1-x0])/pt;
            dist=abs(dist);
            mind=find(dist<=min(dist));
            if mind==1
                m=mm(i)+1;
                n=nn(i)+1;
                uv=1;
            elseif mind==2
                m=mm(i)+1;
                n=nn(i);
                uv=1;
            elseif mind==3    
                m=mm(i)+1;
                n=nn(i)+1;
                uv=0;
            elseif mind==4    
                m=mm(i);
                n=nn(i)+1;
                uv=0;
            end
            break
        end
    end
end
