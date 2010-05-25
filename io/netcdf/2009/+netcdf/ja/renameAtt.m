%netcdf.renameAtt  netCDF 属性名の変更
%
%   netcdf.renameAtt(ncid,varid,oldName,newName) は、oldName で識別される
%   属性を newName に変更します。属性は、varid で識別される変数に関連します。
%   グローバル属性は、varid に対して netcdf.getConstant('GLOBAL') を使用する
%   ことで指定することができます。
%
%   この関数を使用するには、バージョン 3.6.2 の "NetCDF C Interface Guide" 内
%   に含まれる netCDF に関する情報を熟知している必要があります。
%   このドキュメンテーションは、
%   <http://www.unidata.ucar.edu/software/netcdf/old_docs/docs_3_6_2/> の 
%   Unidata の Web サイトにあります。この関数は、netCDF ライブラリ C API の 
%   "nc_rename_att" 関数に相当します。
%
%   詳細は、ファイル netcdfcopyright.txt と mexnccopyright.txt を参照してくだ
%   さい。
%
%   参考 netcdf.getConstant.


%   Copyright 2008-2009 The MathWorks, Inc.
