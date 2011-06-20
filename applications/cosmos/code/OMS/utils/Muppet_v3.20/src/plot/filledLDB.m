function outH=filledLDB(ldb,edgeColor,faceColor,maxDist,zLevel)

% Add a filled polygon to the figure
%
% Usage:
% filledLDB(ldb,edgeColor,faceColor,maxDist,zLevel)
%
% ldb: Px2 array with [x, y] points of the landboundary
% edgecolor: 1x3 array with 0-1 values for [r g b]
% facecolor: 1x3 array with 0-1 values for [r g b]
% maxDist: distance between ldb-points above which the landboundary is cut
%           (optional, leave empty [] to discard)
% zLevel: z-level of patch (optional, leave empty [] to use the z=1000 default)
%
% R. Morelissen, 2004-2005

outH=[];

%add nan to beginning and end if there are none
if ~isnan(ldb(1,1))
    ldb=[nan nan;ldb];
end
if ~isnan(ldb(end,1))
    ldb=[ldb;nan nan];
end

%If maxDist is given, cut ldb points further than maxDist apart
if nargin==4&~isempty(maxDist)
    dists=sqrt((ldb(2:end,1)-ldb(1:end-1,1)).^2+(ldb(2:end,2)-ldb(1:end-1,2)).^2);
    mID=find(dists>=maxDist);
    for ii=1:length(mID)
        ldb=[ldb(1:mID,:);nan nan;ldb(mID+1:end,:)];
    end
end

%Cater for other Z-level of patch
if nargin~=5|isempty(zLevel)
    zLevel=1000;
end

id=find(isnan(ldb(:,1)));

%plot all filled patches

%Remember hold setting
curHold=get(gca,'NextPlot');

hold on;

for ii=1:length(id)-1
    %Try to account for the effect that a ldb is copied multiple times
    %behind eachother, resulting in a non-filled ldb
%     doubleLDB=unique(ldb(id(ii)+1:id(ii+1)-1,:),'rows');
%     multiLDB=round(length(ldb(id(ii)+1:id(ii+1)-1,1))/length(doubleLDB));
%     if multiLDB>1
%         %         fH=fill(ldb(id(ii)+1:id(ii)+1+length(doubleLDB),1),ldb(id(ii)+1:id(ii)+1+length(doubleLDB),2),faceColor);
%         fH=patch(ldb(id(ii)+1:id(ii)+1+length(doubleLDB),1),ldb(id(ii)+1:id(ii)+1+length(doubleLDB),2),repmat(zLevel,length(ldb(id(ii)+1:id(ii)+1+length(doubleLDB),2)),1),'k');
%     else
        %         fH=fill(ldb(id(ii)+1:id(ii+1)-1,1),ldb(id(ii)+1:id(ii+1)-1,2),faceColor);
        fH=patch(ldb(id(ii)+1:id(ii+1)-1,1),ldb(id(ii)+1:id(ii+1)-1,2),repmat(zLevel,length(ldb(id(ii)+1:id(ii+1)-1,2)),1),'k');
%     end
    set(fH,'edgecolor',edgeColor,'facecolor',faceColor);

    outH=[outH fH];
end

%Set original hold setting
set(gca,'NextPlot',curHold);