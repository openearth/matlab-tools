%netcdf.getAtt  netCDF 属性の出力
%
%   attrvalue = netcdf.getAtt(ncid,varid,attname) は、属性値を読み込みます。
%   attrvalue のクラスは、内部属性のデータタイプのクラスと一致します。
%   たとえば、属性が netCDF のデータタイプ NC_INT を持つ場合、出力データの
%   クラスは int32 になります。属性が netCDF のデータタイプ NC_BYTE を持つ
%   場合は、int8 の値になります。
%
%   この関数は、最後の入力引数としてデータタイプの文字列を使うことで、さらに
%   修正して使用することができます。これは、netCDF ライブラリが変換を許可する
%   限り、指定する出力データタイプに影響します。
%
%   可能なデータタイプの文字列のリストは、'double', 'single', 'int32', 
%   'int16', 'int8', 'uint8' で構成されます。
%
%   倍精度として属性値を読み込むには、以下のように使用します。
%
%     data=netcdf.getAtt(ncid,varid,attname,'double');
%
%   この関数を使用するには、バージョン 3.6.2 の "NetCDF C Interface Guide" 内
%   に含まれる netCDF に関する情報を熟知している必要があります。
%   このドキュメンテーションは、
%   <http://www.unidata.ucar.edu/software/netcdf/old_docs/docs_3_6_2/> の 
%   Unidata の Web サイトにあります。この関数は、netCDF ライブラリ C API の 
%   "nc_get_att" 関数群に相当します。
%
%   詳細は、ファイル netcdfcopyright.txt と mexnccopyright.txt を参照してくだ
%   さい。
%
%   参考 netcdf.getConstant.


%   Copyright 2008-2009 The MathWorks, Inc.
