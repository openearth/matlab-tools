%netcdf.getConstant  名前付きの定数の数値を出力
%
%   val = netcdf.getConstant(param_name) は、netCDF ライブラリで定義された
%   定数の名前に対応する数値を返します。たとえば、netcdf.getConstant('noclobber') 
%   は、netCDF の定数 NC_NOCLOBBER に対応する数値を返します。
%
%   param_name に対する値は、大文字小文字のいずれにもすることができます。
%   また、先頭の 3 つの文字 'NC_' を含む必要はありません。
%
%   すべての名前のリストは、netcdf.getConstantNames で取り出すことができます。
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
%   参考 netcdf.getConstantNames


%   Copyright 2008-2009 The MathWorks, Inc.
