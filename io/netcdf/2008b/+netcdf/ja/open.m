%netcdf.open  netCDF を開く
%
%   ncid = netcdf.open(filename, mode) は、既存の netCDF ファイルを開き、
%   ncid に netCDF の ID を返します。
%
%   アクセスタイプは、モードパラメータで記述されます。モードパラメータは、
%   読み取り-書き込みアクセスの場合は 'WRITE'、ファイル更新の同期を取る場合は 
%   'SHARE'、読み取り専用アクセスの場合は 'NOWRITE' になります。モードは、
%   netcdf.getConstant で取得可能な数値にすることもできます。さらに、モードは、
%   数値モードの値のビット or にすることもできます。
%
%   [chosen_chunksize, ncid] = netcdf.open(filename, mode, chunksize) は、
%   I/O 性能に影響する追加の性能調整パラメータ chunksize を使用する以外は、
%   上記と同じです。実際の値は、入力値に対応しない netCDF ライブラリで
%   選択されます。
%
%   この関数を使用するには、バージョン 3.6.2 の "NetCDF C Interface Guide" 内
%   に含まれる netCDF に関する情報を熟知している必要があります。
%   このドキュメンテーションは、
%   <http://www.unidata.ucar.edu/software/netcdf/old_docs/docs_3_6_2/> の 
%   Unidata の Web サイトにあります。この関数は、netCDF ライブラリ C API の 
%   "nc_open" と "nc__open" 関数に相当します。
%
%   詳細は、ファイル netcdfcopyright.txt と mexnccopyright.txt を参照してくだ
%   さい。
%
%   参考 netcdf.getConstant.


%   Copyright 2008-2009 The MathWorks, Inc.
