function varargout = poly_op(varargin)
%POLY_OP  Returns the union or the overlapping region of 2 polygons.
%
%    [xr,yr] = poly_op(x1,y1,x2,y2,'union')
%
% returns a clockwise oriented polygon which is the union of two polygons
% (x1,y1) and (x2,y2) and is simply connected (i.e. no donuts, sorry).
%
%    [xr,yr] = poly_op(x1,y1,x2,y2,'overlap')
%
% returns a clockwise oriented polygon which is the area which the two 
% polygons have in common.
%
%    [xr,yr] = poly_op(x1,y1,x2,y2,'overlap','disp',1)
% 
% returns the polygon and plots it as well
% 
% To do in future: deal with overlapping line segments,
%                  error handling, incorrect polygons, etc
%                  
% 
% See also: polyintersect, poly_isclockwise, dflowfm.intersect_lines,
%           convhull
%
%   --------------------------------------------------------------------
%   Copyright (C) 2013 Deltares
%       Willem Ottevanger 
%
%       willem.ottevanger@deltares.nl	
%
%       Deltares 
%       Rotterdamseweg 185
%       2629 HD Delft
%       The Netherlands
%
%   This library is free software; you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation; either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library; if not, write to the Free Software
%   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
%   USA
%   -------------------------------------------------------------------- 

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 18 Oct 2013
% Created with Matlab version: 8.1.0.604 (R2013a)

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

%%
   %% Set defaults for keywords
   %% ----------------------

   %OPT.debug = 0;
   OPT.disp  = 0;

   %% Return defaults
   %% ----------------------

   if nargin==0
      varargout = {OPT};
      return
   elseif nargin == 4;
      x1 = varargin{1};
      y1 = varargin{2};
      x2 = varargin{3};
      y2 = varargin{4};
      choice = 'union';
   else       
      x1 = varargin{1};
      y1 = varargin{2};
      x2 = varargin{3};
      y2 = varargin{4};
      choice = varargin{5};
   end
   overlaptrue = 0;
   if strcmp('overlap',choice)
      overlaptrue = 1;
   end
      
   
   %% Cycle keywords in input argument list to overwrite default values.
   %% Align code lines as much as possible to allow for block editing in textpad.
   %% Only start <keyword,value> pairs after the REQUIRED arguments. 
   %% ----------------------
% 
    iargin    = 6;
    while iargin<=nargin,
      if      ischar(varargin{iargin}),
        switch lower(varargin{iargin})
%        case 'debug'     ;iargin=iargin+1;OPT.debug    = varargin{iargin};
        case 'disp'      ;iargin=iargin+1;OPT.disp     = varargin{iargin};
        otherwise
           error(sprintf('Invalid string argument: %s.',varargin{iargin}));
        end
      end;
      iargin=iargin+1;
    end;   

%% code

% check for overlapping begin and end point.
if (x1(1)==x1(end) & y1(1)==y1(end))
    x1(end) = [];
    y1(end) = [];
end
if (x2(1)==x2(end) & y2(1)==y2(end))
    x1(end) = [];
    y1(end) = [];
end

% make both polygons clockwise oriented
if (~poly_isclockwise(x1,y1));
    x1 = x1(NA:-1:1);
    y1 = y1(NA:-1:1);
end
if (~poly_isclockwise(x2,y2));
    x2 = x2(NB:-1:1);
    y2 = y2(NB:-1:1);
end


x1=x1(:);
x2=x2(:);
y1=y1(:);
y2=y2(:);

NA = length(x1);
NB = length(x2);

xt = [x1;x2];
yt = [y1;y2];

kidx = convhull(xt,yt); %determine points inside convex hull for starting point 
%kidx2 = kidx;
if (overlaptrue)
   kidx2 = setdiff([1:NA],kidx(kidx<=NA));    %for union determine points inside convex hull
   kidx3 = min(kidx2);
else
   kidx3 = min(kidx)-1;  
end
% plot(x1,y1,'g-',x1(1),y1(1),'ro')
% hold on;
% xlim([-2 2]);
% ylim([-2 2]);

x1 = circshift(x1,-kidx3);
y1 = circshift(y1,-kidx3);
%plot(x1(1),y1(1),'bo')
%%



A.x1 = x1;
A.x2 = circshift(x1,1);
A.y1 = y1;
A.y2 = circshift(y1,1);
B.x1 = x2;
B.x2 = circshift(x2,1);
B.y1 = y2;
B.y2 = circshift(y2,1);
A.out = 0*x1;
B.out = 0*x2;
A.idxB = 0*x1;
B.idxA = 0*x2;

m = 0;

for j = 1:NA;
    
    D.x1 = A.x1(j);
    D.x2 = A.x2(j);
    D.y1 = A.y1(j);
    D.y2 = A.y2(j);
    
    %P.x1(m) = D.x1;
    %P.y1(m) = D.y1;
    
    k = 0;
    out = 0;
    while ((out == 0) && (k<NB));
        k = k+1;
        E.x1 = B.x1(k);
        E.x2 = B.x2(k);
        E.y1 = B.y1(k);
        E.y2 = B.y2(k);
        det  = (D.x2-D.x1).*(E.y2-E.y1) - (D.y2-D.y1).*(E.x2-E.x1);
        if (det == 0)
            X1 = [D.x1, D.x2, E.x1, E.x2, D.x1];
            Y1 = [D.y1, D.y2, E.y1, E.y2, D.y1];
            area1 = polyarea(X1,Y1);
            X2 = [D.x1, D.x2, E.x2, E.x1, D.x1];
            Y2 = [D.y1, D.y2, E.y2, E.y1, D.y1];
            area2 = polyarea(X2,Y2);
            area = max(abs(area1),abs(area2));
            if (area > 0.00000000001)
                out = 0;
            else
                out = 2;
            end
        else
            det  = (D.x2-D.x1).*(E.y2-E.y1) - (D.y2-D.y1).*(E.x2-E.x1);
            alpha = ( (E.x1-D.x1).*(E.y2-E.y1) - (E.y1-D.y1).*(E.x2-E.x1) ) ./ det;
            beta  = ( (E.x1-D.x1).*(D.y2-D.y1) - (E.y1-D.y1).*(D.x2-D.x1) ) ./ det;
            ind = find(alpha>=0 & alpha<=1 & beta>=0 & beta<=1);
            if (length(ind) > 0)
                out = 1;
                m = m+1;
                Pint.x1(m) = D.x1+alpha*(D.x2-D.x1);
                Pint.y1(m) = D.y1+alpha*(D.y2-D.y1);
            else
                out = 0;
            end
        end
        if (out>0)
            %disp(['setting A',num2str(j)])
            A.out(j) = out;
            A.idxB(j) = k;
            %disp(['setting B',num2str(k)])
            B.out(k) = out;
            B.idxA(k) = j;
        end
    end
end
%plot(x1,y1,'b--.')
%hold on;
%plot(x2,y2,'r--.')
%plot([E.x1 E.x2],[E.y1 E.y2],'r-');
%plot([D.x1 D.x2],[D.y1 D.y2],'b-')
%plot(P.x1,P.y1,'o')
% 
% 
% figure(1)
% hold on;
% for j = 1:NA;
%     if A.out(j) == 1
%         plot([A.x1(j) A.x2(j)],[A.y1(j) A.y2(j)],'r-');
%     elseif A.out(j) == 2
%         plot([A.x1(j) A.x2(j)],[A.y1(j) A.y2(j)],'g-');
%     else
%         plot([A.x1(j) A.x2(j)],[A.y1(j) A.y2(j)],'b-');
%     end
% end
% for k = 1:NB;
%     if B.out(k) == 1
%         plot([B.x1(k) B.x2(k)],[B.y1(k) B.y2(k)],'r-');
%     elseif B.out(k) == 2
%         plot([B.x1(k) B.x2(k)],[B.y1(k) B.y2(k)],'g-');
%     else
%         plot([B.x1(k) B.x2(k)],[B.y1(k) B.y2(k)],'b-');
%     end
% end
% 
% plot(Pint.x1,Pint.y1,'ro')
% %hold off;
% xlim([-2 2])
% ylim([-2 2])

%% Now we have the intersections and overlapping line segments

%find starting point

idxA = find(A.out>0);
idxB = find(B.out>0);
%idxA = unique([1;idxA;NA])
%idxB = unique([1;idxB;NB])

Asegval = 0;
Bsegval = 0;

j = 1;
n = 1;
k = 0;
m = 0;
Px(n) = A.x1(j);
Py(n) = A.y1(j);
line = 1;
while (j<NA)
    %disp([j,k])
    n = n+1;
    if line == 1
        j = mod(j,NA)+1;
        if (A.out(j) == 0)
            Px(n) = A.x1(j);
            Py(n) = A.y1(j);
        elseif (A.out(j) == 1)
            k = A.idxB(j);
            m = m+1;
            Px(n) = Pint.x1(m);
            Py(n) = Pint.y1(m);
            n = n+1;
            Px(n) = B.x1(k);
            Py(n) = B.y1(k);
            line = 0;
        end
    elseif line == 0;
        k = mod(k,NB)+1;
        if (B.out(k) == 0)
            Px(n) = B.x1(k);
            Py(n) = B.y1(k);
        elseif (B.out(k) == 1)
            j = B.idxA(k);
            m = m+1;
            Px(n) = Pint.x1(m);
            Py(n) = Pint.y1(m);
            n = n+1;
            Px(n) = A.x1(j);
            Py(n) = A.y1(j);
            line = 1;
        end
    end
end

Px = [Px,Px(1)];
Py = [Py,Py(1)];
  
if OPT.disp
   plot([x1;x1(1)],[y1;y1(1)],x1(1),y1(1),'o',[x2;x2(1)],[y2;y2(1)],Px,Py)
end

if nargout==2
   varargout = {Px,Py};
end
   
   
