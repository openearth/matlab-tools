%% detran_tutorial tutorial for Detran
% This tutorial explains Detran. Detran calculates the cumulative sediment 
% transport through cross sections on the basis of transport data from 
% Delft3D results.
%
% Detran can be used as a interactive graphical environment or as a
% command line toolbox.

%% Opening the graphical user interface (GUI-mode)
% To open the GUI, just type call detran without input arguments.
detran

%%
% The use of the graphical user interface is illustrated in more detail in 
% a <http://openearth.nl video tutorial>
%% Command line mode: using trim-files
% To use Detran in command line mode, you have to specify some input 
% arguments. If we have for example a single trim-file, and we want to 
% calculate the transport through a certain transect with coordinates 
% (2260,5333) to (5798,1797), then we use the following command to 
% calculate the transport through this transect:
trimfile='testmodel\trim-example.dat'; 
transect = [200 150 450 150];
tr = detran('single',trimfile,'transects',transect,'transType',...
    {'total','mean'},'fraction',0,'timeStep',0);
disp(['The transport rate through the transect is ' num2str(3600*tr,'%5.0f') ' m3/hr'])
%%
% Because a couple of the specified input arguments are default values,
% they can be omitted:
tr = detran('single',trimfile,'transects',transect);
disp(['The transport rate through the transect is ' num2str(3600*tr,'%5.0f') ' m3/hr']);
%%
% The example trim file contains two sediment fractions. If you want to
% extract the transport rate for each fraction seperately, you enter:
tr1 = detran('single',trimfile,'transects',transect,'fraction',1);
tr2 = detran('single',trimfile,'transects',transect,'fraction',2);
disp(['The transport rate of fraction 1 through the transect is ' num2str(3600*tr1,'%5.0f') ' m3/hr']);
disp(['The transport rate of fraction 2 through the transect is ' num2str(3600*tr2,'%5.0f') ' m3/hr']);
%%
% Logically, tr1 + tr2 = tr!
disp(['The total transport rate through the transect is: ' num2str(3600*(tr1+tr2),'%5.0f') ' m3/hr']);

%%
% It is also possible to define more than one trasect:
transect = [200 150 450 150;...
            450 150 700 150;...
            450 310 450 150;...
            200 150 200 10;...
            700 150 700 10];
tr = detran('single',trimfile,'transects',transect);
disp(num2str(3600*tr,'%5.0f'));

%%
% By specifying 3 output arguments, detran also gives the gross transport
% rates (positive and negative):
[tr,tp,tn] = detran('single',trimfile,'transects',transect);
disp(num2str(3600*[tr tp tn],'%5.0f'));

%%
% Since the transport is uniformly directed along the transect, one of the
% gross transport components is 0.

%% Command line mode: using trih-files
% Detran can also be used to read the transport rate through the cross
% sections as specified in the model input. This information is stored in
% the history output file of Delft3D (trih-file). As a consequence you do
% not need to specify transect information as input argument when using
% trih-files:
trihfile='testmodel\trih-example.dat';
tr = detran('single',trihfile);
disp(num2str(3600*tr,'%5.0f'));

%%
% Because nine cross sections have been defined in the Delft3D input, 
% three transport rates are returned by Detran. Note that the cross 
% sections (and thus the resulting transpor rates) are identical to those 
% used for the example with trim-input. 
%
% Also for trih-files it is possible to calculate the transport rate per 
% fraction:
tr = detran('single',trihfile,'fraction',1);
disp(num2str(3600*tr,'%5.0f'));

%% Command line mode: plotting the results
% The resulting transport rates and their corresponding transects can also
% easily be plotted using 'detran_plotTransportThroughTransect' from the Detran 
% toolbox:
trimfile='testmodel\trim-example.dat'; 
transect = [200 150 450 150;...
            450 150 700 150;...
            450 310 450 150;...
            200 150 200 10;...
            700 150 700 10];
tr = detran('single',trimfile,'transects',transect);
ldb=[0     0 195 195 205 205 695 695 705 705 900 900;...
     400 310 310 150 150 310 310 150 150 310 310 400]';
figure;
patch(ldb(:,1),ldb(:,2),[1 1 0.5]);
hold on;
for t=1:size(transect,1)
    detran_plotTransportThroughTransect(transect(t,1:2),transect(t,3:4),3600*tr(t),10);
end
title('transport rate though transects in m^3/hr!');
xlabel('x (m)');
ylabel('y (m)');

%%
% You can also plot the gross transport rates:
[tr tp tn] = detran('single',trimfile,'transects',transect);
figure;
patch(ldb(:,1),ldb(:,2),[1 1 0.5]);
hold on;
for t=1:size(transect,1)
    detran_plotTransportThroughTransect(transect(t,1:2),transect(t,3:4),3600.*[tr(t) tp(t) tn(t)],10);
end
title('transport rate though transects in m^3/hr!');
xlabel('x (m)');
ylabel('y (m)');
