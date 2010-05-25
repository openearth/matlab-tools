%netcdf.putVar  データを netCDF 変数に書き込む
%
%   netcdf.putVar(ncid,varid,data) は、データを netCDF 変数全体に書き込みます。
%   変数は varid で識別され、netCDF ファイルは ncid で識別されます。
%
%   netcdf.putVar(ncid,varid,start,data) は、単一のデータ値を指定した
%   インデックスで変数に書き込みます。
%
%   netcdf.putVar(ncid,varid,start,count,data) は、値の配列セクションを 
%   netCDF 変数に書き込みます。配列セクションは、start と count のベクトルで
%   指定され、指定した変数の各次元に沿った値の開始インデックスとカウントで
%   与えられます。
%
%   netcdf.putVar(ncid,varid,start,count,stride,data) は、stride 引数で与えら
%   れたサンプリング区間を使用します。
%
%   この関数を使用するには、バージョン 3.6.2 の "NetCDF C Interface Guide" 内
%   に含まれる netCDF に関する情報を熟知している必要があります。
%   このドキュメンテーションは、
%   <http://www.unidata.ucar.edu/software/netcdf/old_docs/docs_3_6_2/> の 
%   Unidata の Web サイトにあります。この関数は、netCDF ライブラリ C API の 
%   "nc_put_var" 関数群に相当します。
%
%   詳細は、ファイル netcdfcopyright.txt と mexnccopyright.txt を参照してくだ
%   さい。


%   Copyright 2008-2009 The MathWorks, Inc.
