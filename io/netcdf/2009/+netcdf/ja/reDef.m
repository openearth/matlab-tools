%netcdf.reDef  netCDF  ファイルを定義モードに設定
%
%   netcdf.reDef(ncid) は、次元、変数、属性の追加、または、名前の変更が可能に
%   なるように、開いている netCDF のデータセットを定義モードに設定します。
%   さらに、属性を定義モード内で削除することができます。
%
%   この関数を使用するには、バージョン 3.6.2 の "NetCDF C Interface Guide" 内
%   に含まれる netCDF に関する情報を熟知している必要があります。
%   このドキュメンテーションは、
%   <http://www.unidata.ucar.edu/software/netcdf/old_docs/docs_3_6_2/> の 
%   Unidata の Web サイトにあります。この関数は、netCDF ライブラリ C API の 
%   "nc_redef" 関数に相当します。
%
%   詳細は、ファイル netcdfcopyright.txt と mexnccopyright.txt を参照してくだ
%   さい。


%   Copyright 2008-2009 The MathWorks, Inc.
