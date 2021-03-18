function [xg,yg]=spw2rect_grid(ldbfile,dx)

dy=dx;
ldb=landboundary('read',ldbfile);
xldb=squeeze(ldb(:,1));
yldb=squeeze(ldb(:,2));

% if ~isempty(ldbfile)
%     [xx]=tekal('read',ldbfile,'loaddata');
%     for ii=1:length(xx.Field)
%         ldb(ii).x=xx.Field(ii).Data(:,1);
%         ldb(ii).y=xx.Field(ii).Data(:,2);
%     end
% end

% Find bounding box
xmin=floor(min(xldb));
xmax=ceil(max(xldb));
ymin=floor(min(yldb));
ymax=ceil(max(yldb));

% Count number of times cyclone genesis took place in bins
[xg,yg]=meshgrid(xmin:dx:xmax,ymin:dy:ymax);