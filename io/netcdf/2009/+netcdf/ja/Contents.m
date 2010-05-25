%NETCDF  MATLAB NETCDF 機能の概要
%   MATLAB は、netCDF ライブラリの 30 以上の関数に直接アクセスすることに
%   より、netCDF ファイルへの低レベルアクセス機能を提供します。これらの 
%   MATLAB 関数を使用するには、netCDF C インタフェースを熟知している必要が
%   あります。バージョン 3.6.2 の "NetCDF C Interface Guide" は、
%   <http://www.unidata.ucar.edu/software/netcdf/old_docs/docs_3_6_2/> で
%   見つけることができます。
%
%   多くの場合、MATLAB 関数のシンタックスは、netCDF ライブラリ関数の
%   シンタックスと同じです。関数は、"netcdf" を呼び出すパッケージとして
%   実行されます。これらの関数を使用するには、以下のように関数名の先頭に
%   パッケージ名 "netcdf" を付ける必要があります。
%
%      ncid = netcdf.open ( ncfile, mode );
%
%   以下の表は、netCDF パッケージでサポートされるすべての netCDF ライブラリ
%   関数の一覧です。
%
%      abort            - 最新の netCDF ファイル定義を元に戻す
%      close            - netCDF ファイルを閉じる
%      create           - 新規 netCDF ファイルの作成
%      endDef           - netCDF ファイル定義モードの終端
%      inq              - netCDF ファイルに関する情報の出力
%      inqLibVers       - netCDF ライブラリバージョン情報の出力
%      open             - netCDF を開く
%      reDef            - netCDF  ファイルを定義モードに設定
%      setDefaultFormat - デフォルトの netCDF ファイル形式を変更
%      setFill          - netCDF の埋め込みモードの設定
%      sync             - netCDF データセットとディスクの同期を取る
%
%      defDim           - netCDF 次元の作成
%      inqDim           - netCDF 次元の名前と長さの出力
%      inqDimID         - 次元 ID の出力
%      renameDim        - netCDF 次元名の変更
%
%      defVar           - netCDF 変数の作成
%      getVar           - netCDF 変数からデータのデータの出力
%      inqVar           - 変数に関する情報の出力
%      inqVarID         - 変数名に関連する ID の出力
%      putVar           - データを netCDF 変数に書き込む
%      renameVar        - netCDF 変数名の変更
%
%      copyAtt          - 新規場所に属性をコピー
%      ndelAtt          - netCDF 属性の削除
%      getAtt           - netCDF 属性の出力
%      inqAtt           - netCDF 属性に関する情報の出力
%      inqAttID         - netCDF 属性の ID の出力
%      inqAttName       - netCDF 属性名の出力
%      putAtt           - netCDF 属性の書き込み
%      renameAtt        - 属性名の変更
%
%
%   以下の関数は、netCDF ライブラリと同じではありません。
%
%      getConstantNames - netCDF ライブラリであることが分かっている定数のリストを出力
%      getConstant      - 名前付きの定数の数値を出力
%
%   詳細は、ファイル netcdfcopyright.txt と mexnccopyright.txt を参照してください。


%   Copyright 2008-2009 The MathWorks, Inc.
