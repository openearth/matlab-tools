function varargout = pg_ewkb(s)
%PG_EWKB   parse PostGIS Extended Well-Known Binary (EWKB) hexadecimal geometry object
%
% PG_EWKB(hex) parses a Well-Known Binary (WKB) hexadecimal object 
% (string) or a PostGIS Extended WKB (EWKB). hex can be a char array 
% or a JBBC object: org.postgresql.util.PGobject.
%
% string = PG_EWKB(hex) returns a PostGIS SQL text representation
%
% [type,srid,x,y,<z>] = PG_EWKB(hex) returns the OGC geometry type, the SRID
% (EPSG) reference number (for EWKB, default []), and the x and y
% and optionally (if present) z coordinates in doubles.
%
%See also: pg_datenum, shape

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 Tu Delft / Deltares for Building with Nature
%       Gerben J. de Boer
%
%       g.j.deboer@tudelft.nl / gerben.deboer@deltares.nl
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$

% This is first attempt to make a native ewkb reader, an alternative is to use existing libraries:
% the java library JTS  - http://www.vividsolutions.com/jts/jtshome.htm
% the C    library GEOS - http://trac.osgeo.org/geos/
% the C#   library NTS  - http://nts.sourceforge.net/

if strcmpi(class(s),'org.postgresql.util.PGobject')
   s = char(s.toString);
end

    %% Examples and explanation of WKB
    %  http://en.wikipedia.org/wiki/Well-known_text
    %  http://www.vividsolutions.com/jts/jtshome.htm
    %  https://docs.djangoproject.com/en/dev/ref/contrib/gis/geos/ [C port of JTS]
    %  http://postgis.refractions.net/docs/ST_GeomFromEWKT.html

    %% PostGIS implementation definition of Extend WKB
    %  http://svn.osgeo.org/postgis/trunk/liblwgeom/lwin_wkb.c
    %  http://svn.osgeo.org/postgis/trunk/liblwgeom/lwout_wkb.c

    %% byte order
    byte_order = hex2dec(s(1:2));

    %% geometry type and (E)WKB
    %  http://svn.osgeo.org/postgis/trunk/liblwgeom/liblwgeom.h.in
    %  WKBZOFFSET  0x80000000
    %  WKBMOFFSET  0x40000000
    %  WKBSRIDFLAG 0x20000000
    %  WKBBBOXFLAG 0x10000000
    
    type       = reshape(s(3:10),2,4)';
    if     byte_order==1
      type = flipud(type);
    end
    type = hex2dec(type)';
    
%% detect and remove extended flags    
    
    if bitand(type(1),32)
       has.srid  = true;
       type(1)   = bitset(type(1),6,0);
    else
       has.srid  = false;
    end
    
    if bitand(type(1),64)
       has.m     = true;
       type(1)   = bitset(type(1),7,0);
    else
       has.m     = false;
    end

    if bitand(type(1),128)
       has.z     = true;
       type(1)   = bitset(type(1),8,0);
    else
       has.z     = false;
    end    
    
%% parse extended srid

    if has.srid
        srid     = reshape(s(11:18),2,4)';
        if byte_order==1
            srid = flipud(srid);
        end 
        srid = reshape(srid',8,1)';
        srid = hex2dec(srid);
    else
        has_srid = 0;
        srid     = [];
    end
    
    wkb_type = type(1)*1000 + type(2)*100 + type(3)*10 + type(4);
   [geometry_type,z_type] = pg_geometry(wkb_type);
    z    = [];
    
%% parse coordinates
    
    if mod(type,10)>1
      error('Not yet implemented ',gstr)
    else
      x    = reshape(s([11:26]+has.srid*8),2,8)';
      y    = reshape(s([27:42]+has.srid*8),2,8)';
      if has.z
      z    = reshape(s([43:58]+has.srid*8),2,8)';
      end
      if byte_order==1
         x = flipud(x);
         y = flipud(y);
         if has.z
         z = flipud(z);
         end
      end
      x = hex2num(reshape(x',16,1)');
      y = hex2num(reshape(y',16,1)');
      if has.z
      z = hex2num(reshape(z',16,1)');
      end
    end

    if nargout<2

       varargout = {(['SRID=',num2str(srid),';',upper(geometry_type),'(',num2str(x),' ',num2str(y),')'])};
       
       % SELECT ST_GeomFromEWKT('SRID=4269;POINT(-71.064544 42.28787)');

    else
       varargout = {wkb_type,srid,x,y,z};
    end

function [gstr,zstr] = pg_geometry(ind)

% http://svn.osgeo.org/postgis/trunk/liblwgeom/liblwgeom.h.in
% POINTTYPE                1
% LINETYPE                 2
% POLYGONTYPE              3
% MULTIPOINTTYPE           4
% MULTILINETYPE            5
% MULTIPOLYGONTYPE         6
% COLLECTIONTYPE           7
% CIRCSTRINGTYPE           8
% COMPOUNDTYPE             9
% CURVEPOLYTYPE           10
% MULTICURVETYPE          11
% MULTISURFACETYPE        12
% POLYHEDRALSURFACETYPE   13
% TRIANGLETYPE            14
% TINTYPE                 15

geometry_type = {...
 'Geometry',...
 'Point',...
 'LineString',...
 'Polygon',...
 'MultiPoint',...
 'MultiLineString',...
 'MultiPolygon',...
 'GeometryCollection',...
 'CircularString',...
 'CompoundCurve',...
 'CurvePolygon',...
 'MultiCurve',...
 'MultiSurface',...
 'Curve',...
 'Surface',...
 'PolyhedralSurface',...
 'TIN',...
 'Triangle'};

z_type = {...
 '2D',...
 'Z',...
 'M',...
 'ZM'};

 gstr = geometry_type{mod(ind,100)+1 };
 zstr = z_type       {div(ind,1000)+1};
 