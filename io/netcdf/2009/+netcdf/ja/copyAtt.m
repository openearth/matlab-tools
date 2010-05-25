%netcdf.copyAtt  新規場所に属性をコピー
%
%   netcdf.copyAtt(ncid_in,varid_in,attname,ncid_out,varid_out) は、可能な
%   限りファイル全体で、1 つの変数から別の変数へ属性をコピーします。
%
%   この関数を使用するには、バージョン 3.6.2 の "NetCDF C Interface Guide" 内
%   に含まれる netCDF に関する情報を熟知している必要があります。
%   このドキュメンテーションは、
%   <http://www.unidata.ucar.edu/software/netcdf/old_docs/docs_3_6_2/> の 
%   Unidata の Web サイトにあります。この関数は、netCDF ライブラリ C API の 
%   "nc_copy_att" 関数に相当します。
%
%   詳細は、ファイル netcdfcopyright.txt と mexnccopyright.txt を参照して
%   ください。


%   Copyright 2008-2009 The MathWorks, Inc.
