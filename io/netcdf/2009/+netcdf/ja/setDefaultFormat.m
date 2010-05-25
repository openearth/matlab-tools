%netcdf.setDefaultFormat  デフォルトの netCDF ファイル形式の変更
%
%   oldFormat = netcdf.setDefaultFormat(newFormat) は、将来作成するファイルの
%   形式を newFormat に変更し、古い形式の値を返します。
%   newFormat は、'FORMAT_CLASSIC' または 'FORMAT_64BIT'、あるいは、
%   netcdf.getConstant で取得されるものと等価な数値のいずれかになります。
%
%   例
%   --
%       newFormat = netcdf.getConstant('NC_FORMAT_64BIT');
%       oldFormat = netcdf.setDefaultFormat(newFormat);
%
%   この関数を使用するには、バージョン 3.6.2 の "NetCDF C Interface Guide" 内
%   に含まれる netCDF に関する情報を熟知している必要があります。
%   このドキュメンテーションは、
%   <http://www.unidata.ucar.edu/software/netcdf/old_docs/docs_3_6_2/> の 
%   Unidata の Web サイトにあります。この関数は、netCDF ライブラリ C API の 
%   "nc_set_default_format" 関数に相当します。
%
%   詳細は、ファイル netcdfcopyright.txt と mexnccopyright.txt を参照してくだ
%   さい。
%
%   参考 netcdf.getConstant.


%   Copyright 2008-2009 The MathWorks, Inc.
