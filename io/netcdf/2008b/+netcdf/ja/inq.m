%netcdf.inq  netCDF ファイルに関する情報の出力
%
%   [ndims,nvars,ngatts,unlimdimid] = netcdf.inq(ncid) は、次元数、変数の数、
%   グローバル属性の数、さらに存在する場合、制限のない次元の指定を調べます。
%   netCDF ファイルは、数値 ID ncid で識別されます。
%
%   この関数を使用するには、バージョン 3.6.2 の "NetCDF C Interface Guide" 内
%   に含まれる netCDF に関する情報を熟知している必要があります。
%   このドキュメンテーションは、
%   <http://www.unidata.ucar.edu/software/netcdf/old_docs/docs_3_6_2/> の 
%   Unidata の Web サイトにあります。この関数は、netCDF ライブラリ C API の 
%   "nc_inq" 関数に相当します。
%
%   詳細は、ファイル netcdfcopyright.txt と mexnccopyright.txt を参照してくだ
%   さい。


%   Copyright 2008-2009 The MathWorks, Inc.
