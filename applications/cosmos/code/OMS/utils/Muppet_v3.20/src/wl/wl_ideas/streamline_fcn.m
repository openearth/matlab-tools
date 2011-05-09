function DU=streamline_fcn(t,X),

global streamline_U streamline_V

i=X(1);
j=X(2);
if any(isnan(X)),
  DU(1,1)=inf;
  DU(2,1)=inf;
else,
  Fi=floor(i);
  Fj=floor(j);
  Di=i-Fi;
  Dj=j-Fj;
  if (Fi<1) | (Fj<1) | ((Fi+1)>size(streamline_U,1)) | ((Fj+1)>size(streamline_U,2)),
    DU(1,1)=inf;
    DU(2,1)=inf;
  else,
    DU(1,1)=(Di*Dj)*streamline_V(Fi+1,Fj+1)+((1-Di)*Dj)*streamline_V(Fi,Fj+1)+(Di*(1-Dj))*streamline_V(Fi+1,Fj)+((1-Di)*(1-Dj))*streamline_V(Fi,Fj);
    DU(2,1)=(Di*Dj)*streamline_U(Fi+1,Fj+1)+((1-Di)*Dj)*streamline_U(Fi,Fj+1)+(Di*(1-Dj))*streamline_U(Fi+1,Fj)+((1-Di)*(1-Dj))*streamline_U(Fi,Fj);
  end;
end;