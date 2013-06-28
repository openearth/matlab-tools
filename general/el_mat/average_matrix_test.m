[x,y,z] = meshgrid(1:4,(1:8)/1000,(1:8)/1000000);
data = x+y+z;

reducedData = average_matrix(data,[1 2 4]);


[x,y,z] = meshgrid(1:400,(1:80)/10,(1:800)/100);
data = x+y+z;

reducedData = average_matrix(data,[16 20 4]);