function OK = arc_info_binary_test()
% ARC_INFO_BINARY_TEST   test for arc_info_binary_test
%  
% test arc_info_binary_test with sets from OpenEarthRawData
%
%   See also arc_info_binary, arcgisread

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Pieter van Geer
%
%       pieter.vangeer@deltares.nl	
%
%       Rotterdamseweg 185
%       2629 HD Delft
%       P.O. 177
%       2600 MH Delft
%
%   This library is free software: you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation, either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library. If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tools is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 22 Jun 2010
% Created with Matlab version: 7.10.0.499 (R2010a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

MTestCategory.DataAccess;
if TeamCity.running
    TODO('Use test dataset instead');
    TeamCity.ignore('Data unavailable at agent');
    OK = 1;
    return;
end

%% Test data 
% All data files in
%    F:\checkouts\OpenEarthRawData\
% are a Subversion checkout from:
%    http:repos.deltares.nl/repos/OpenEarthRawData/trunk/

%% binary grids to be read with arc_info_binary_test
maps = {'F:\checkouts\OpenEarthRawData\tno\ncp\raw\dz10_juli2007',... % 1 floats, OK
        'F:\checkouts\OpenEarthRawData\tno\ncp\raw\dz50_juli2007',... % 2
        'F:\checkouts\OpenEarthRawData\tno\ncp\raw\dz90_juli2007',... % 3
        'F:\checkouts\OpenEarthRawData\tno\ncp\raw\grind_fbr2007',... % 4
        'F:\checkouts\OpenEarthRawData\tno\ncp\raw\slib_juli2007',... % 5
        'F:\checkouts\OpenEarthRawData\rijkswaterstaat\Oosterschelde\Galgeplaat\rasters\2m grid\g2m_t0_mei08\',...  % integers, does not work yet
        'F:\checkouts\OpenEarthRawData\rijkswaterstaat\Oosterschelde\Galgeplaat\rasters\2m grid\g2m_t1_okt08\',...  % 7
        'F:\checkouts\OpenEarthRawData\rijkswaterstaat\Oosterschelde\Galgeplaat\rasters\2m grid\g2m_t2_okt08\',...  % 8
        'F:\checkouts\OpenEarthRawData\rijkswaterstaat\Oosterschelde\Galgeplaat\rasters\2m grid\g2m_t3_nov08\',...  % 9
        'F:\checkouts\OpenEarthRawData\rijkswaterstaat\Oosterschelde\Galgeplaat\rasters\2m grid\g2m_t4_dec08\',...  %10
        'F:\checkouts\OpenEarthRawData\rijkswaterstaat\Oosterschelde\Galgeplaat\rasters\2m grid\g2m_t5_jan09\',...  % 1
        'F:\checkouts\OpenEarthRawData\rijkswaterstaat\Oosterschelde\Galgeplaat\rasters\2m grid\g2m_t6_feb09\',...  % 2
        'F:\checkouts\OpenEarthRawData\rijkswaterstaat\Oosterschelde\Galgeplaat\rasters\2m grid\g2m_t7_mrt09\',...  % 3
        'F:\checkouts\OpenEarthRawData\rijkswaterstaat\Oosterschelde\Galgeplaat\rasters\2m grid\g2m_t8_jun09\',...  % 4
        'F:\checkouts\OpenEarthRawData\rijkswaterstaat\Oosterschelde\Galgeplaat\rasters\2m grid\g2m_t9_jul09\',...  % 5
        'F:\checkouts\OpenEarthRawData\rijkswaterstaat\Oosterschelde\Galgeplaat\rasters\2m grid\g2m_t10_sep09\',... % 6
        'F:\checkouts\OpenEarthRawData\rijkswaterstaat\Oosterschelde\Galgeplaat\rasters\2m grid\g2m_t11_dec09\',... % 7
        'F:\checkouts\OpenEarthRawData\rijkswaterstaat\Oosterschelde\Galgeplaat\rasters\5m grid\g5m_t0_mei08\',...  % 8
        'F:\checkouts\OpenEarthRawData\rijkswaterstaat\Oosterschelde\Galgeplaat\rasters\5m grid\g5m_t4_dec08\',...  % 9
        'F:\checkouts\OpenEarthRawData\rijkswaterstaat\Oosterschelde\Galgeplaat\rasters\5m grid\g5m_t7_mrt09\',...  % 0
        'F:\checkouts\OpenEarthRawData\rijkswaterstaat\Oosterschelde\Galgeplaat\rasters\5m grid\g5m_t10_sep09\',... %21
        'F:\checkouts\OpenEarthRawData\rijkswaterstaat\Oosterschelde\Galgeplaat\rasters\g_os2007\',...              % 2
        'F:\checkouts\OpenEarthRawData\rijkswaterstaat\Oosterschelde\Galgeplaat\rasters\laser_07_galg\'};           % 3

%% ascii dumps mae with arcgis, can be used for regression analysis
ascii= {'F:\checkouts\OpenEarthRawData\tno\ncp\raw\dz10_juli2007\rastert_dz10_ju.txt',... % 1 floats, OK
        'F:\checkouts\OpenEarthRawData\tno\ncp\raw\dz50_juli2007\rastert_dz50_ju1.txt',... % 2
        'F:\checkouts\OpenEarthRawData\tno\ncp\raw\dz90_juli2007\rastert_dz90_ju1.txt',... % 3
        'F:\checkouts\OpenEarthRawData\tno\ncp\raw\grind_fbr2007\rastert_grind_f1.txt',... % 4
        'F:\checkouts\OpenEarthRawData\tno\ncp\raw\slib_juli2007\rastert_slib_ju1.txt',... % 5
        'F:\checkouts\OpenEarthRawData\rijkswaterstaat\Oosterschelde\Galgeplaat\rasters\2m grid\g2m_t0_mei08\g2m_t0_mei08.txt',...  % integers, does not work yet
        'F:\checkouts\OpenEarthRawData\rijkswaterstaat\Oosterschelde\Galgeplaat\rasters\2m grid\g2m_t1_okt08\',...  % 7
        'F:\checkouts\OpenEarthRawData\rijkswaterstaat\Oosterschelde\Galgeplaat\rasters\2m grid\g2m_t2_okt08\',...  % 8
        'F:\checkouts\OpenEarthRawData\rijkswaterstaat\Oosterschelde\Galgeplaat\rasters\2m grid\g2m_t3_nov08\',...  % 9
        'F:\checkouts\OpenEarthRawData\rijkswaterstaat\Oosterschelde\Galgeplaat\rasters\2m grid\g2m_t4_dec08\',...  %10
        'F:\checkouts\OpenEarthRawData\rijkswaterstaat\Oosterschelde\Galgeplaat\rasters\2m grid\g2m_t5_jan09\',...  % 1
        'F:\checkouts\OpenEarthRawData\rijkswaterstaat\Oosterschelde\Galgeplaat\rasters\2m grid\g2m_t6_feb09\',...  % 2
        'F:\checkouts\OpenEarthRawData\rijkswaterstaat\Oosterschelde\Galgeplaat\rasters\2m grid\g2m_t7_mrt09\',...  % 3
        'F:\checkouts\OpenEarthRawData\rijkswaterstaat\Oosterschelde\Galgeplaat\rasters\2m grid\g2m_t8_jun09\',...  % 4
        'F:\checkouts\OpenEarthRawData\rijkswaterstaat\Oosterschelde\Galgeplaat\rasters\2m grid\g2m_t9_jul09\',...  % 5
        'F:\checkouts\OpenEarthRawData\rijkswaterstaat\Oosterschelde\Galgeplaat\rasters\2m grid\g2m_t10_sep09\',... % 6
        'F:\checkouts\OpenEarthRawData\rijkswaterstaat\Oosterschelde\Galgeplaat\rasters\2m grid\g2m_t11_dec09\',... % 7
        'F:\checkouts\OpenEarthRawData\rijkswaterstaat\Oosterschelde\Galgeplaat\rasters\5m grid\g5m_t0_mei08\',...  % 8
        'F:\checkouts\OpenEarthRawData\rijkswaterstaat\Oosterschelde\Galgeplaat\rasters\5m grid\g5m_t4_dec08\',...  % 9
        'F:\checkouts\OpenEarthRawData\rijkswaterstaat\Oosterschelde\Galgeplaat\rasters\5m grid\g5m_t7_mrt09\',...  % 0
        'F:\checkouts\OpenEarthRawData\rijkswaterstaat\Oosterschelde\Galgeplaat\rasters\5m grid\g5m_t10_sep09\',... %21
        'F:\checkouts\OpenEarthRawData\rijkswaterstaat\Oosterschelde\Galgeplaat\rasters\g_os2007\',...              % 2
        'F:\checkouts\OpenEarthRawData\rijkswaterstaat\Oosterschelde\Galgeplaat\rasters\laser_07_galg\'};           % 3

%% we cannot read *prj file yet, but often there isn't even one
epsg = [32631 % 'WGS 84 / UTM zone 31N'
        32631
        32631
        32631
        32631
        28992 % RD
        28992
        28992
        28992
        28992
        28992
        28992
        28992
        28992
        28992
        28992
        28992
        28992
        28992
        28992
        28992
        28992
        28992];

for im= 1:length(maps)

   close all

   try
   [X,Y,D,M] = arc_info_binary([maps{im},'\'],...
        'debug',0,...
         'plot',1,...
       'export',1,...
        'clim',[100 300],...
        'epsg',epsg(im),... % RD = 28992, 'WGS 84 / UTM zone 31N'=32631
          'vc','F:\checkouts\OpenEarthRawData\deltares\landboundaries\processed\northsea.nc');
       disp(['succes: ',num2str(im),' ',maps{im}])
       succes(im) = 1;
   catch
       disp(['failed: ',num2str(im),' ',maps{im}])
       succes(im) = 0;
   end
          
   %A = ArcGisRead(ascii{im})       

end

OK = all(succes);