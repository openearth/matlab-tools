function [x_zerocross,varargout]=find0crossing(X,Y,varargin)

% function [x_zerocross,id]=find0crossing(X,Y,Ylevel)
%
% Computes zerocrossing
%
% input:
% X            [1xN] vector
% Y            [1xN] vector
% Ylevel       (optional) level at which crossing should be computed (default=0)
%
% output:
% x_zerocross  location of zero crossing
% id           (optional) id of zerocrosspoint
% 
% B.J.A. Huisman, 2008


%if nargin>3
%   level = varargin{1};
%   dx    = varargin{2};
%elseif
if nargin>2
    level = varargin{1};
%   dx    = (max(X)-min(X))/100000;
else
    level = 0;
%   dx    = (max(X)-min(X))/100000;
end

if size(X,2)>size(X,1)
    X=X';
end
if size(Y,2)>size(Y,1)
    Y=Y';
end

cntr=1;
id_zerocross=[];errmsg={};
clear x_zerocross
if isnumeric(X) & isnumeric(Y)
    if size(X,2)==1 & size(X,1)>1 & size(Y,2)==1 & size(Y,1)>1
        x_zerocross=[];
        %xy = addEquidistantPointsBetweenSupportingLDBPoints([X,Y],dx);
        %diffy       = abs(xy(:,2) - level);
        %id          = find(diffy==min(min(diffy)));
        %x_zerocross = xy(id,1);
        
        
        Ydiff  = Y-level;
        idplus = find(Ydiff(2:end)>0 & Ydiff(1:end-1)<0);
        idmin  = find(Ydiff(1:end-1)>0 & Ydiff(2:end)<0);
        idzero = find(Ydiff==0);
        
        for ii=1:length(idplus)
            x1 = X(idplus(ii));
            x2 = X(idplus(ii)+1);
            y1 = Y(idplus(ii));
            y2 = Y(idplus(ii)+1);
            x_zerocross(ii)      = x1 + (x2-x1)/(y2-y1)*(level-y1);
            id_zerocross(ii)     = mean(idplus(ii)) + (level-y1)/(y2-y1);
        end
        for iii=1:length(idmin)
            x1 = X(idmin(iii));
            x2 = X(idmin(iii)+1);
            y1 = Y(idmin(iii));
            y2 = Y(idmin(iii)+1);
            x_zerocross(iii+length(idplus))      = x1 + (x2-x1)/(y2-y1)*(level-y1);
            id_zerocross(iii+length(idplus))     = mean(idmin(iii)) + (level-y1)/(y2-y1);
        end
        for iiii=1:length(idzero)
            x1 = X(idzero(iiii));
            x_zerocross(iiii+length(idplus)+length(idmin))      = x1;
            id_zerocross(iiii+length(idplus)+length(idmin))     = mean(idzero(iiii));
        end
        if isempty(idplus) & isempty(idmin) & isempty(idzero)
            x_zerocross=[];
            errmsg{cntr} = ['warning cannot find crossing point! Polygon does not cross horizontal plane)'];cntr=cntr+1;
        end
    elseif size(X,2)==1 & size(X,1)==1 & size(Y,2)==1 & size(Y,1)==1
        x_zerocross=[];
        fprintf('warning cannot find crossing point if only 1 point is specified!\n');
    else
        x_zerocross=[];
        fprintf('warning x,y values should be vectors!\n');
    end
else
    x_zerocross=[];
    fprintf('warning x,y values are not numeric!\n');
end
x_zerocross=sort(x_zerocross);

if nargout>=2
    varargout{1}=id_zerocross;
end
if nargout>2
    varargout{2}=errmsg;
end