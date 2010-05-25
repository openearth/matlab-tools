%netcdf.renameVar  netCDF 変数名の変更
%
%   netcdf.renameVar(ncid,varid,newName) は、ncid に関連する netCDF ファイル
%   内の varid で識別される変数名を変更します。
%
%   この関数を使用するには、バージョン 3.6.2 の "NetCDF C Interface Guide" 内
%   に含まれる netCDF に関する情報を熟知している必要があります。
%   このドキュメンテーションは、
%   <http://www.unidata.ucar.edu/software/netcdf/old_docs/docs_3_6_2/> の 
%   Unidata の Web サイトにあります。この関数は、netCDF ライブラリ C API の 
%   "nc_rename_var" 関数に相当します。
%
%   詳細は、ファイル netcdfcopyright.txt と mexnccopyright.txt を参照してくだ
%   さい。


%   Copyright 2008-2009 The MathWorks, Inc.
