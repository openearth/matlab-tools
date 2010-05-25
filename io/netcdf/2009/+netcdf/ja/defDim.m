%netcdf.defDim  netCDF 次元の作成
%
%   dimid = netcdf.defDim(ncid,dimname,dimlen) は、名前と長さを与えて新規の
%   次元を作成します。戻り値は、新規次元に対応する数値 ID です。
%
%   この関数を使用するには、バージョン 3.6.2 の "NetCDF C Interface Guide" 内
%   に含まれる netCDF に関する情報を熟知している必要があります。
%   このドキュメンテーションは、
%   <http://www.unidata.ucar.edu/software/netcdf/old_docs/docs_3_6_2/> の 
%   Unidata の Web サイトにあります。この関数は、netCDF ライブラリ C API の 
%   "nc_def_dim" 関数に相当します。
%
%   詳細は、ファイル netcdfcopyright.txt と mexnccopyright.txt を参照して
%   ください。


%   Copyright 2008-2009 The MathWorks, Inc.
