%netcdf.abort  最新の netCDF ファイル定義を元に戻す
%
%   netcdf.abort(ncid) は、netcdf.create の後 (ただし netcdf.endDef の前) に
%   作成された無効な定義である netCDF ファイルを元に戻します。さらにファイルを
%   閉じます。
%
%   この関数を使用するには、バージョン 3.6.2 の "NetCDF C Interface Guide" 内
%   に含まれる netCDF に関する情報を熟知している必要があります。
%   このドキュメンテーションは、
%   <http://www.unidata.ucar.edu/software/netcdf/old_docs/docs_3_6_2/> の 
%   Unidata の Web サイトにあります。この関数は、netCDF ライブラリ C API の
%   関数 "nc_abort" に相当します。
%
%   詳細は、ファイル netcdfcopyright.txt と mexnccopyright.txt を参照して
%   ください。
%
%   参考 netcdf.create, netcdf.endDef.


%   Copyright 2008-2009 The MathWorks, Inc.
