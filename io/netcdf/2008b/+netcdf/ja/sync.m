%netcdf.sync  netCDF データセットとディスクの同期を取る
%
%   netcdf.sync(ncid) は、netCDF データセットの状態とディスクの同期を取ります。
%   netCDF ライブラリは、 NC_SHARE モードが netcdf.open または netcdf.create 
%   に与えられない限り、通常、netCDF ファイルの下にバッファアクセスします。
%
%   この関数を使用するには、バージョン 3.6.2 の "NetCDF C Interface Guide" 内
%   に含まれる netCDF に関する情報を熟知している必要があります。
%   このドキュメンテーションは、
%   <http://www.unidata.ucar.edu/software/netcdf/old_docs/docs_3_6_2/> の 
%   Unidata の Web サイトにあります。この関数は、netCDF ライブラリ C API の 
%   "nc_sync" 関数に相当します。
%
%   詳細は、ファイル netcdfcopyright.txt と mexnccopyright.txt を参照してくだ
%   さい。
%
%   参考 netcdf.open, netcdf.create, netcdf.close, netcdf.endDef


%   Copyright 2008-2009 The MathWorks, Inc.
