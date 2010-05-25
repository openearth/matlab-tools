%netcdf.getVar  netCDF 変数からデータのデータの出力
%
%   data = netcdf.getVar(ncid,varid) は、変数全体を読み込みます。
%   出力データのクラスは、netCDF 変数のクラスと一致します。
%
%   data = netcdf.getVar(ncid,varid,start) は、指定したインデックスで始まる
%   単一の値を読み込みます。
%
%   data = netcdf.getVar(ncid,varid,start,count) は、変数のセクションを
%   連続的に読み込みます。
%
%   data = netcdf.getVar(ncid,varid,start,count,stride) は、変数の 
%   strided セクションを読み込みます。
%
%   この関数は、最後の入力引数としてデータタイプの文字列を使うことで、
%   さらに修正して使用することができます。これは、netCDF ライブラリが変換を
%   許可する限り、指定する出力データタイプに影響します。
%
%   可能なデータタイプの文字列のリストは、'double', 'single', 'int32', 
%   'int16', 'int8', 'uint8' で構成されます。
%
%   倍精度として整数の変数全体を読み込むには、以下のように使用します。
%
%     data=netcdf.getVar(ncid,varid,'double');
%
%   この関数を使用するには、バージョン 3.6.2 の "NetCDF C Interface Guide" 内
%   に含まれる netCDF に関する情報を熟知している必要があります。
%   このドキュメンテーションは、
%   <http://www.unidata.ucar.edu/software/netcdf/old_docs/docs_3_6_2/> の 
%   Unidata の Web サイトにあります。この関数は、netCDF ライブラリ C API の 
%   "nc_get_var" 関数群に相当します。
%
%   詳細は、ファイル netcdfcopyright.txt と mexnccopyright.txt を参照してくだ
%   さい。


%   Copyright 2008-2009 The MathWorks, Inc.
