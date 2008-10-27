
X = [ 0  2; 1 3];
Y = [-1 -2; 0 1];

plot(X,Y,'-o')
hold on
plot(X',Y',':+')
axis([-1 5 -3 3])
grid on
set(gca,'xtick',[-10:1:10])
set(gca,'ytick',[-10:1:10])

AreaA(:,:) = GetAreaTriangle(X(1:end-1,1:end-1),Y(1:end-1,1:end-1),...
                             X(2:end  ,1:end-1),Y(2:end  ,1:end-1),...
                             X(2:end  ,2:end  ),Y(2:end  ,2:end  ));

AreaB(:,:) = GetAreaTriangle(X(1:end-1,1:end-1),Y(1:end-1,1:end-1),...
                             X(1:end-1,2:end  ),Y(1:end-1,2:end  ),...
                             X(2:end  ,2:end  ),Y(2:end  ,2:end  ));
                
Area(:,:)  = AreaA + AreaB  

disp('o---------o')
disp('| B     . |') 
disp('|    .    |')
disp('| .     A |')
disp('o---------o')
disp([num2str(AreaA)])
disp([num2str(AreaB)])
disp([num2str(Area )])

disp('---------------------------------------------')


AreaA(:,:) = GetAreaTriangle(X(1:end-1,1:end-1),Y(1:end-1,1:end-1),...
                             X(2:end  ,1:end-1),Y(2:end  ,1:end-1),...
                             X(1:end-1,2:end  ),Y(1:end-1,2:end  ));

AreaB(:,:) = GetAreaTriangle(X(2:end  ,1:end-1),Y(2:end  ,1:end-1),...
                             X(1:end-1,2:end  ),Y(1:end-1,2:end  ),...
                             X(2:end  ,2:end  ),Y(2:end  ,2:end  ));
                
Area(:,:)  = AreaA + AreaB;

disp('o---------o')
disp('| .    B  |') 
disp('|    .    |')
disp('| A     . |')
disp('o---------o')
disp([num2str(AreaA)])
disp([num2str(AreaB)])
disp([num2str(Area )])
