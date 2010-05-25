%netcdf.getConstantNames  netCDF ライブラリであることが分かっている定数のリストを出力
%
%   names = netcdf.getConstantNames() は、netCDF ライブラリの定数、定義、
%   列挙値の名前のリストを返します。これらの文字列が netCDF パッケージ関数に
%   実際のパラメータとして与えられる場合、自動的に適切な数値に変換されます。
%
%   この関数を使用するには、バージョン 3.6.2 の "NetCDF C Interface Guide" 内
%   に含まれる netCDF に関する情報を熟知している必要があります。
%   このドキュメンテーションは、
%   <http://www.unidata.ucar.edu/software/netcdf/old_docs/docs_3_6_2/> の 
%   Unidata の Web サイトにあります。
%
%   詳細は、ファイル netcdfcopyright.txt と mexnccopyright.txt を参照してくだ
%   さい。
%
%   参考 netcdf.create, netcdf.defVar, netcdf.open,
%        netcdf.setDefaultFormat, netcdf.setFill.


%   Copyright 2008-2009 The MathWorks, Inc.
