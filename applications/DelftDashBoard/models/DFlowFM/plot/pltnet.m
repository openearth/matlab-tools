function p=pltnet(netStruc)
for i=1:length(netStruc.linkNodes)
    i1=netStruc.linkNodes(i,1);
    i2=netStruc.linkNodes(i,2);
    x{i}(1)=netStruc.nodeX(i1);
    x{i}(2)=netStruc.nodeX(i2);
    y{i}(1)=netStruc.nodeY(i1);
    y{i}(2)=netStruc.nodeY(i2);
end
[x,y] = poly_join(x,y);
p=plot(x,y);
