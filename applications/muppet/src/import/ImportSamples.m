function DataProperties=ImportSamples(DataProperties,i)
 
a=load([DataProperties(i).PathName DataProperties(i).FileName]);
 
DataProperties(i).x=a(:,1);
DataProperties(i).y=a(:,2);
DataProperties(i).z=a(:,3);

DataProperties(i).Type = 'Samples';
DataProperties(i).TC='c';
