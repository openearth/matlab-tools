%netcdf.inqVar  netCDF 変数に関する情報の出力
%
%   [varname,xtype,dimids,natts] = netcdf.inqVar(ncid,varid) は、名前、
%   データタイプ、次元 ID、varid で識別された変数の属性の数を返します。
%
%   この関数を使用するには、バージョン 3.6.2 の "NetCDF C Interface Guide" 内
%   に含まれる netCDF に関する情報を熟知している必要があります。
%   このドキュメンテーションは、
%   <http://www.unidata.ucar.edu/software/netcdf/old_docs/docs_3_6_2/> の 
%   Unidata の Web サイトにあります。この関数は、netCDF ライブラリ C API の 
%   "nc_inq_var" 関数に相当します。
%   MATLAB は FORTRAN スタイルの並びを使用するため、次元 ID の並びは、
%   C API から得られる並びと逆になります。
%
%   詳細は、ファイル netcdfcopyright.txt と mexnccopyright.txt を参照してくだ
%   さい。


%   Copyright 2008-2009 The MathWorks, Inc.
