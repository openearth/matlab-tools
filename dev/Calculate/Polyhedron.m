%Class to declare the most common Calculations
%
% @author ABR
% @author SEO
% @version 0.8, 10/02/2014
%

classdef Polyhedron < handle
    %Public properties
    properties
        Property1;
    end
    
    %Dependand properties
    properties (Dependent = true, SetAccess = private)
        
    end
    
    %Private properties
    properties(SetAccess = private)
        
    end
    
    %Default constructor
    methods
        function obj = Template(property1)
            if nargin > 0
                obj.Property1 = property1;
            end
        end
    end
    
    %Set methods
    methods
        function set.Property1(obj,property1)
            obj.Property1 = property1;
        end
    end
    
    %Get methods
    methods
        function property1 = get.Property1(obj)
            property1 = obj.Property1;
        end
    end
    
    %Public methods
    methods
        
    end
    
    %Private methods
    methods (Access = 'private')
        
    end
    
    %Stactic methods
    methods (Static)
        function volume = volumePolyhedron(XYZ,Connection)
            % calculates the volume of a polyhedron
            % WARNING: IT OIS NOT CHECKED WHETTHER THE POINT IN CONNECTION ARE NON-INTERSECTING POLYGONS. STILL TODO
            %
            % INPUT: XYZ: [m x 3] matrix, with x y and z coordinates of the corner points
            %        Connection : [n x l] matrix with for all n faces the numers
            
            % thershold for accuracy of the determination of the points
            theshold = 0.001;
            
            sizeCon = size(Connection);
            volume = 0;
            
            % check the input
            
            isPolyhedron = EulerPolyhedron(XYZ,Connection);
            if ~isPolyhedron
                errordlg('Input is not a valid polyhedron. Check the input.');
                return;
            end;
            
            % loop over allplanes
            for i = 1:sizeCon(1)
                
                % determine the coordinates
                connect = Connection(i,:);
                connect(isnan(connect)) = [];
                x = XYZ(connect,1);
                y = XYZ(connect,2);
                z = XYZ(connect,3);
                
                if length(x)<3
                    errordlg(['At least three points are needed in each plane. Not satisfied in plane ',num2str(i),'.']);
                    return;
                end;
                % fit a plane through the points
                % z = ax + by +c;
                %=> z = Av
                %  v = [a b c ];
                A =[x,y,ones(size(x))];
                coeff = A\z;
                
                % determine the new coordinates that go through the plane
                
                znew = coeff(1).*x + coeff(2).*y + coeff(3);
                if abs(z-znew)>theshold
                    errordlg(['The points must all be in the same plane. Not satisfied in plane ',num2str(i),'.']);
                    return;
                end;
                
                
                % determine the vector normal through the plane
                % which i sgiven as n = [-a -b 1]
                
                n = [-coeff(1:2);1];
                normN = dist(n);
                
                %     determine the coordinates in a rotated plane
                % cos (theta) = u.v / |u| |v|
                % v is bottom. ie. v = [0 0 1];
                % cosTheta = n*[0 0 1]' ./ sqrt(sum(n.^2));
                % sinTheta = sqrt(1-cosTheta^2);
                %
                % rotate around the line y = -a/b x - c/b
                %
                % rotation matrix for rotation around the yaxis
                %  R = [cosTheta,0,sinTheta;...
                %       0,1,0;...
                %       -sinTheta,0,cosTheta];
                %
                %       xTrans = cosTheta.*x + sinTheta.*y;
                %       yTrans = y;
                %       zTrans = -sinTheta.*x + cosTheta.*y;
                
                % rotate the coordinates
                
                
                % calculate the area of the face  (in 3D)
                %using a projection
                %http://geomalgorithms.com/a01-_area.html
                % dimension with biggesn component (which is ignored)
                [~,ndim] = max(abs(n));
                switch(ndim)
                    case 1
                        xTrans = y;
                        yTrans = z;
                    case 2
                        xTrans = x;
                        yTrans = z;
                    case 3
                        xTrans = x;
                        yTrans = y;
                end;
                
                nFac =  normN/abs(n(ndim));
                Area = nFac.*abs(polyarea(xTrans,yTrans));
                
                % calculate the volume
                %V = sum(all faces) 1/3 xi . ni A
                nNorm = n/normN;
                volume = volume + 0.33333333333333.*([x(1) y(1) z(1)] * nNorm) .*Area;
                
            end;
            
        end
        
        function y = dist(x)
            y = sqrt(sum(x.^2));
            
        end
        
        function isPolyhedron = EulerPolyhedron(XYZ,Connection)
            % checks the polyhedron with euler's equation
            nrVertices = size(XYZ,1);
            nrFaces = size(Connection,1);
            
            % determine all the lines in the vertex and eliminate those that are
            % double)
            nrConnection = size(Connection);
            edges = nan(prod(nrConnection),2);
            iEdge = 1;
            for i = 1:nrConnection(1)
                points =  Connection(i,:);
                points(isnan(points)) = [];
                for j = 1:length(points)-1
                    edges(iEdge,:) = [min(points(j:j+1)),max(points(j:j+1))];
                    iEdge = iEdge + 1;
                end;
                edges(iEdge,:) = [min(points([1,j+1])),max(points([1,j+1]))];
                iEdge = iEdge + 1;
            end;
            edges(isnan(edges(:,1)),:) = [];
            % delete double linesets
            edges = unique(edges,'rows');
            
            nrEdges = size(edges,1);
            
            
            
            eulerNr  =  nrVertices - nrEdges + nrFaces;
            isPolyhedron = (eulerNr ==2);
        end
        
        function X = selfintersect(varargin)
            % Self intersection points of a 2D polygon P
            %
            % function X = selfintersect(P)
            % OR function X = selfintersect(x,y)
            %
            % INPUTS:
            % P two-row array, each column is a vertice
            % or (x,y) coordinates of the vertices
            % They might or might not be wrapped around
            % OUTPUT:
            % X is two-row array, each column is an intersecting point
            %
            % Author: Bruno Luong <brunoluong@????.???>
            % History:
            % Original 23-Jan-2011
            
            if nargin==2
                P = [varargin{1}(:) varargin{2}(:)].';
            else
                P = varargin{1};
                if size(P,2)==2 && size(P,2)~=2
                    P = P.';
                end
            end
            
            % wrap around if needed
            if ~isequal(P(:,end),P(:,1))
                P(:,end+1) = P(:,1);
            end
            
            % We increment the intermediate results by this amount
            increment = 10;
            % Empty buffer
            X = zeros(2,0);
            filled = 0;
            sizec = 0;
            % Loop over segment of P
            for n=2:size(P,2)-2
                seg = P(:,n-1:n);
                Pn = P(:,n+1:end);
                if n==2
                    Pn(:,end) = [];
                end
                cn = seg2poly(seg, Pn);
                m = size(cn,2);
                filled = filled+m;
                % Buffer too small
                if sizec < filled
                    sizec = filled+increment;
                    X(2,sizec) = 0;
                end
                % Store the result
                X(:,filled+(-m+1:0)) = cn;
            end
            % remove the tail
            X(:,filled+1:end) = [];
            
        end % polyxpoly
        
        %%
        function X = seg2poly(s1, P)
            % function X = seg2poly(s1, P)
            % Check if a line segment s1 intersects with a polygon P.
            % INPUTS:
            % s is (2 x 2) where
            % s(:,1) is the first point
            % s(:,2) is the the second point of the segment.
            % P is (2 x n) array, each column is a vertices
            % OUTPUT
            % X is (2 x m) array, each column is an intersecting point
            %
            % Author: Bruno Luong <brunoluong@????.???>
            % History:
            % Original 20-May-2010
            
            % Translate so that first point is origin
            a = s1(:,1);
            M = bsxfun(@minus, P, a);
            b = s1(:,2)-a;
            % Check if the points are on the left/right side
            x = [b(2) -b(1)]*M;
            sx = sign(x);
            % x -coordinates has opposite signs
            ind = sx(1:end-1).*sx(2:end) <= 0;
            if any(ind)
                ind = find(ind);
                % cross point to the y-axis (along the segment)
                x1 = x(ind);
                x2 = x(ind+1);
                d = b.'/(b(1)^2+b(2)^2);
                y1 = d*M(:,ind);
                y2 = d*M(:,ind+1);
                dx = x2-x1;
                % We won't bother with the degenerate case of dx=0 and x1=0
                y = (y1.*x2-y2.*x1)./dx;
                % Check if the cross point is inside the segment
                ind = y>=0 & y<1;
                if any(ind)
                    X = bsxfun(@plus, a, b*y(ind));
                else
                    X = zeros(2,0);
                end
            else
                X = zeros(2,0);
            end
            
        end % seg2poly
        
        %%%%%%%%%%%%%%%%%
        % % Test script
        % m = 10; % number of vertices
        %
        % xv = zeros(m,1);
        % yv = zeros(m,1);
        %
        % fprintf('Use the mouse and enter %d points of the polygonal\n', m);
        %
        % figure(1);
        % clf
        % axis equal
        % axis([0 1 0 1]);
        % hold on
        % k = 1;
        % while k<=m
        %     [xv(k) yv(k)] = ginput(1);
        %     if k>1
        %         plot(xv(k+[-1 0]),yv(k+[-1 0]),'-');
        %     else
        %         plot(xv(1),yv(1),'.');
        %     end
        %     axis([0 1 0 1]);
        %     k = k+1;
        % end
        % plot(xv([end 1]),yv([end 1]),'-b');
        %
        % X = selfintersect(xv, yv);
        %
        % hold on
        % for k=1:size(X,2)
        %     plot(X(1,k),X(2,k),'or');
        % end
        
        
    end
end