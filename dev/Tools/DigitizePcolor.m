function [Xout,Yout,Zout] = DigitizePcolor(sctInput)
% digitizes a pcolorlike figure
%
%INPUT sctInput: a 
%
%OUTPUT Xout

% read the file
if nargin ==0
    sctInput = struct;
end
sctInput = Util.setDefault(sctInput,'nrCol',100);
if ~isfield(sctInput,'imgFile')
  [theFile,thePath] = uigetfile({'*.png';'*.jpg';'*.jpeg';'*.tif';'*.bmp';'*.*'},'Open an image');
   sctInput.imgFile  = fullfile(thePath,theFile);
end

% read data
img = imread(sctInput.imgFile);

% pot
close all;
figure;
image(img);
axis equal;
imgSize = size(img);
% draw extra line for help every 100 pixels
hold on;
% xH = 0:100:imgSize(1);
% yH = 0:100:imgSize(2);
% plot([zeros(size(xH));imgSize(1).*ones(size(xH))],[xH;xH],':k')
% plot([yH;yH],[zeros(size(yH));imgSize(2).*ones(size(yH))],':k')

[Xin,Yin] = meshgrid(1:imgSize(2),1:imgSize(1));

% define calibration points

[xIn1,xReal1] = getCalibrationPoints(1);
[xIn2,xReal2] = getCalibrationPoints(2);
[xIn3,xReal3] = getCalibrationPoints(3);

% calculate calibration from points
A    = [xIn1;xIn2;xIn3];
abcX = A\[xReal1(1);xReal2(1);xReal3(1)];
abcY = A\[xReal1(2);xReal2(2);xReal3(2)];


% define area of interest

xyAoI = getPolyline;
points = [Xin(:),Yin(:)];
mask = inpoly(points,xyAoI);
% calibrate colorbar

% calculate colormap calibration
[colMap0,cV0] = calibColorbar(img);

% pick no data color
title('Pick color for no data')
[xNo,yNo] = ginput(1);
colNoData = double(squeeze(img(round(yNo),round(xNo),:)))';

% make a more detailed colormap
colValue = cV0(1):(cV0(end)-cV0(1))/sctInput.nrCol:cV0(end);
colMap   = interp1(cV0,colMap0,colValue);

%calculate values in area of interest
Xout = Xin(mask).*abcX(1) + Yin(mask).*abcX(2) + abcX(3);
Yout = Xin(mask).*abcY(1) + Yin(mask).*abcY(2) + abcY(3);
imgCol = reshape(img,[numel(img)/3,3]);
imgCol = double(imgCol(mask,:));
Zout = zeros(size(Xout));
for i = 1:size(imgCol,1)
    dst    = (imgCol(i,1)-colMap(:,1)).^2 + ...
             (imgCol(i,2)-colMap(:,2)).^2 + ...
             (imgCol(i,3)-colMap(:,3)).^2;
    [minDst,ind] = min(dst);
    dstNoData = sum((imgCol(i,:)-colNoData).^2);
    if minDst < dstNoData
        Zout(i)   =  colValue(ind);
    else
        Zout(i)   =  nan;
    end
end


end

function [colMap,colValue] = calibColorbar(img)
    %calibrates a colormap by picking values
    cMapStr = inputdlg({'Give a list of values to digitize in the colormap'},'digitize colors');
    colValue= str2num(cMapStr{1}); %#ok<ST2NM>
    if ~isempty(colValue)
        colMap = zeros(length(colValue),3);
        for i=1:length(colValue)
            title(['Pick a color for ',num2str(colValue(i))]);
            %xywh = rbbox;
            [x,y] = ginput(1);
            xi = round(y);
            yi = round(x);
            allColor3    = img(xi,yi,:);
            colMap(i,:)  = squeeze(allColor3);
        end
    else
        error('Wrong input for color values');
    end
    

end


function xy = getPolyline
% gets a polyline with the area to consider
title('Draw the area of interest');
hold on;
w = 1;
xy = [];
while w==1
    
    %get point
    [x,y,w] = ginput(1);
    if w ==1
        if ~isempty(xy)
            delete(hL);
        end
        xy = [xy;x,y];
        % plot polyline
        xyp = [xy;xy(1,:)];
        hL = plot(xyp(:,1),xyp(:,2),'r');
        
    else
        if length(xy)>2
            xy = [xy;xy(1,:)];
        end
    end
    
end
end

function [xIn,xReal] = getCalibrationPoints(i)
% gets calibration points graphically
switch(i)
    case 1
        txt = 'first';
    case 2
        txt = 'second';
    case 3
        txt = 'third';
end
title(['Define ',txt,' calibration point']);
[x0,y0,w] = ginput(1);
if w==1
    calTxt  = inputdlg({['X value calibration point ',num2str(i)],...
        ['Y value calibration point ',num2str(i)]},...
        'Calibration point');
    xCal0 = str2double(calTxt{1});
    if isnan(xCal0)
        error('Invalid value for x');
    end
    yCal0 = str2double(calTxt{2});
    if isnan(yCal0)
        error('Invalid value for y');
    end
else
    error('No calibration point selected');
end
xIn   = [x0, y0, 1];
xReal = [xCal0, yCal0];
end



