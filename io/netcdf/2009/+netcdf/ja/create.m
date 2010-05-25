%netcdf.create  新規 netCDF ファイルの作成
%
%   ncid = netcdf.create(filename, mode) は、ファイル作成モードに従い、
%   新規 netCDF ファイルを作成します。戻り値は、ファイル ID です。
%
%   アクセスタイプは、モードパラメータで記述されます。モードパラメータは、
%   既存のファイルを保護する場合は 'noclobber'、ファイル更新の同期を取る場合は 
%   'share'、2 GB より大きいファイルの作成を許可する場合は '64bit_offset' の
%   いずれかです。モードは、netcdf.getConstant で取得可能な数値にも、または、
%   数値モード値のビット or にすることもできます。
%
%   [chunksize_out, ncid]=netcdf.create(filename,mode,initsz,chunksize) は、
%   追加の性能調整パラメータを使って、新規の netCDF ファイルを作成します。
%   initsz は、ファイルの初期サイズを設定します。chunksize は、I/O 性能に
%   影響します。実際の値は、入力値に対応しない netCDF ライブラリで選択されます。
%
%   この関数を使用するには、バージョン 3.6.2 の "NetCDF C Interface Guide" 内
%   に含まれる netCDF に関する情報を熟知している必要があります。
%   このドキュメンテーションは、
%   <http://www.unidata.ucar.edu/software/netcdf/old_docs/docs_3_6_2/> の 
%   Unidata の Web サイトにあります。この関数は、netCDF ライブラリ C API の 
%   "nc_create" と "nc__create" 関数に相当します。
%
%   詳細は、ファイル netcdfcopyright.txt と mexnccopyright.txt を参照して
%   ください。
%
%   参考 netcdf.getConstant.


%   Copyright 2008-2009 The MathWorks, Inc.
