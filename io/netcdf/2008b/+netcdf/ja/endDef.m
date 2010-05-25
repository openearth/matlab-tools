%netcdf.endDef  netCDF ファイル定義モードの終端
%
%   netcdf.endDef(ncid) は、定義モード範囲外の ncid で識別される netCDF を
%   取得します。
%
%   netcdf.endDef(ncid,h_minfree,v_align,v_minfree,r_align) は、4 つの性能
%   調整パラメータの追加を使う以外は、netcdf.endDef と同じです。
%
%   性能パラメータを使用する理由の 1 つは、h_minfree パラメータを使って 
%   netCDF ファイルのヘッダ内の余分な空白を予約するためです。たとえば、
%
%       ncid = netcdf.endDef(ncid,20000,4,0,4);
%
%   は、属性を追加する場合に後で使用されるヘッダ内の 20000 バイトを予約します。
%   これは、非常に大きいファイルで作業する場合に、極めて効率がよくなります。
%
%   この関数を使用するには、バージョン 3.6.2 の "NetCDF C Interface Guide" 内
%   に含まれる netCDF に関する情報を熟知している必要があります。
%   このドキュメンテーションは、
%   <http://www.unidata.ucar.edu/software/netcdf/old_docs/docs_3_6_2/> の 
%   Unidata の Web サイトにあります。この関数は、netCDF ライブラリ C API の 
%   "nc_del_att" 関数に相当します。この関数は、netCDF ライブラリ C API の 
%   "nc_enddef" と "nc__enddef" 関数に相当します。
%
%   詳細は、ファイル netcdfcopyright.txt と mexnccopyright.txt を参照してくだ
%   さい。


%   Copyright 2008-2009 The MathWorks, Inc.
