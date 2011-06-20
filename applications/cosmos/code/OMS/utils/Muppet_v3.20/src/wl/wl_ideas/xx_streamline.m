function [x,y]=xx_streamline(X,Y,U,V,x0),

global streamline_U streamline_V

streamline_U=U;
streamline_V=V;

dist=(X-x0(2)).^2+(Y-x0(1)).^2;
[i,j]=find(dist==min(dist(:)));
XX=X(max(1,i-1):min(size(X,1),i+1),max(1,j-1):min(size(X,2),j+1));
YY=Y(max(1,i-1):min(size(X,1),i+1),max(1,j-1):min(size(X,2),j+1));
ivalues=max(1,i-1):min(size(X,1),i+1);
jvalues=max(1,j-1):min(size(X,2),j+1);
imatrix=transpose(ivalues)*ones(1,length(jvalues));
jmatrix=ones(length(ivalues),1)*(jvalues);
i0=[griddata(XX(:),YY(:),imatrix(:),x0(2),x0(1));griddata(XX(:),YY(:),jmatrix(:),x0(2),x0(1))];
if any(isnan(i0)), % if outside valide area
  x=NaN;
  y=NaN;
  return;
end;
T=[0 1000];
odeopt=odeset('refine',2);
[t,I]=ode113nowarn('streamline_fcn',T,i0,odeopt);
x=I(:,1);
y=I(:,2);

for k=1:size(I,1),
  if any(isnan(I(k,:))),
    x(k)=NaN;
    y(k)=NaN;
  else,
    Fi=floor(I(k,1));
    Fj=floor(I(k,2));
    if (Fi>0) & (Fj>0) & (Fi<size(X,1)) & (Fj<size(X,2)),
      Di=I(k,1)-Fi;
      Dj=I(k,2)-Fj;
      x(k)=(Di*Dj)*X(Fi+1,Fj+1)+((1-Di)*Dj)*X(Fi,Fj+1)+(Di*(1-Dj))*X(Fi+1,Fj)+((1-Di)*(1-Dj))*X(Fi,Fj);
      y(k)=(Di*Dj)*Y(Fi+1,Fj+1)+((1-Di)*Dj)*Y(Fi,Fj+1)+(Di*(1-Dj))*Y(Fi+1,Fj)+((1-Di)*(1-Dj))*Y(Fi,Fj);
    else,
      x(k)=NaN;
      y(k)=NaN;
    end;
  end;
end;
