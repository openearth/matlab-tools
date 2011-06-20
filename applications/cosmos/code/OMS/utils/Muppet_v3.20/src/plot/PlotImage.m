function handles=PlotImage(handles,i,j,k,mode)

DeleteObject(i,j,k);

Plt=handles.Figure(i).Axis(j).Plot(k);
Data=handles.DataProperties(Plt.AvailableDatasetNr);
 
Data.x=Data.x(1:Plt.FieldThinningFactor1:end,1:Plt.FieldThinningFactor1:end);
Data.y=Data.y(1:Plt.FieldThinningFactor1:end,1:Plt.FieldThinningFactor1:end);
Data.z=zeros(size(Data.x))+Plt.Elevation;
Data.c=Data.c(1:Plt.FieldThinningFactor1:end,1:Plt.FieldThinningFactor1:end,:);
a=sum(Data.c,3);
Data.c(a>Plt.WhiteVal*3)=NaN;

plt=surf(Data.x,Data.y,Data.z,Data.c);shading interp;hold on;
alpha(plt,Plt.Transparency);

SetObjectData(plt,i,j,k,'image');
