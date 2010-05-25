%netcdf.putAtt  netCDF 属性の書き込み
%
%   netcdf.putAtt(ncid,varid,attrname,attrvalue) は、varid で指定される 
%   netCDF 変数に属性を書き込みます。グローバル属性を指定するには、
%   varid に対して netcdf.getConstant('GLOBAL') を使用してください。
%
%   この関数を使用するには、バージョン 3.6.2 の "NetCDF C Interface Guide" 内
%   に含まれる netCDF に関する情報を熟知している必要があります。
%   このドキュメンテーションは、
%   <http://www.unidata.ucar.edu/software/netcdf/old_docs/docs_3_6_2/> の 
%   Unidata の Web サイトにあります。この関数は、netCDF ライブラリ C API の 
%   "nc_put_att" 関数群に相当します。
%
%   詳細は、ファイル netcdfcopyright.txt と mexnccopyright.txt を参照してくだ
%   さい。
%
%   参考 netcdf.getConstant.


%   Copyright 2008-2009 The MathWorks, Inc.
