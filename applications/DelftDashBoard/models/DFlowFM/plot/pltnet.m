function p=pltnet(netStruc)

if size(netStruc.edge.NetLink,1)==2
    % transpose
    netStruc.edge.NetLink=netStruc.edge.NetLink';
end

i1=netStruc.edge.NetLink(:,1);
i2=netStruc.edge.NetLink(:,2);
x=zeros(3,length(i1));
x(x==0)=NaN;
y=x;
x(1,:)=netStruc.node.x(i1);
y(1,:)=netStruc.node.y(i1);
x(2,:)=netStruc.node.x(i2);
y(2,:)=netStruc.node.y(i2);

x=reshape(x,[1 3*size(x,2)]);
y=reshape(y,[1 3*size(y,2)]);

% x=[netStruc.node.x(i1);netStruc.node.x(i2)];
% y=[netStruc.node.y(i1);netStruc.node.y(i2)];

% tic
% for ii=1:size(netStruc.edge.NetLink,1)
%     i1=netStruc.edge.NetLink(ii,1);
%     i2=netStruc.edge.NetLink(ii,2);
%     x{ii}(1)=netStruc.node.x(i1);
%     x{ii}(2)=netStruc.node.x(i2);
%     y{ii}(1)=netStruc.node.y(i1);
%     y{ii}(2)=netStruc.node.y(i2);
% end
% toc
% tic
% [x,y] = poly_join(x,y);
% toc
p=plot(x,y);
