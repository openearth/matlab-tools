%netcdf.defVar  netCDF 変数の作成
%
%   varid = netcdf.defVar(ncid,varname,xtype,dimids) は、名前、データタイプ、
%   次元 ID のリストを与えて、新規変数を作成します。データタイプは、xtype で
%   与えられ、'double' のような文字列表現、または、netcdf.getConstant で与えられる
%   ものと等価な数値のいずれかにすることができます。戻り値は、新規変数に対応する
%   数値 ID です。
%
%   この関数は、netCDF ライブラリ C API の "nc_def_var" 関数に相当しますが、
%   MATLAB は FORTRAN スタイルの並びを使用するため、最速で可変の次元は 
%   1 番目に、最も遅い次元は最後になります。そのため、制限のない次元は、
%   次元 ID のリストの最後になります。この順番は、C API の並びと逆です。
%
%   この関数を使用するには、バージョン 3.6.2 の "NetCDF C Interface Guide" 内
%   に含まれる netCDF に関する情報を熟知している必要があります。
%   このドキュメンテーションは、
%   <http://www.unidata.ucar.edu/software/netcdf/old_docs/docs_3_6_2/> の 
%   Unidata の Web サイトにあります。
%
%   詳細は、ファイル netcdfcopyright.txt と mexnccopyright.txt を参照して
%   ください。
%
%   参考 netcdf.getConstant.


%   Copyright 2008-2009 The MathWorks, Inc.
