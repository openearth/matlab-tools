%netcdf.setFill  netCDF の埋め込みモードの設定
%
%   oldMode = netcdf.setFill(ncid,newMode) は、netCDF ファイルに対して
%   埋め込みモードを設定します。newMode は、'FILL' または 'NOFILL'、あるいは、
%   netcdf.getConstant で取得されるものと等価な数値のいずれかになります。
%   デフォルトモードは、'FILL' です。古い埋め込みモードは、oldMode に返されます。
%
%   この関数を使用するには、バージョン 3.6.2 の "NetCDF C Interface Guide" 内
%   に含まれる netCDF に関する情報を熟知している必要があります。
%   このドキュメンテーションは、
%   <http://www.unidata.ucar.edu/software/netcdf/old_docs/docs_3_6_2/> の 
%   Unidata の Web サイトにあります。この関数は、netCDF ライブラリ C API の 
%   "nc_set_fill" 関数に相当します。
%
%   詳細は、ファイル netcdfcopyright.txt と mexnccopyright.txt を参照してくだ
%   さい。
%
%   参考 netcdf.getConstant.


%   Copyright 2008-2009 The MathWorks, Inc.
