%netcdf.putVar  �f�[�^�� netCDF �ϐ��ɏ�������
%
%   netcdf.putVar(ncid,varid,data) �́A�f�[�^�� netCDF �ϐ��S�̂ɏ������݂܂��B
%   �ϐ��� varid �Ŏ��ʂ���AnetCDF �t�@�C���� ncid �Ŏ��ʂ���܂��B
%
%   netcdf.putVar(ncid,varid,start,data) �́A�P��̃f�[�^�l���w�肵��
%   �C���f�b�N�X�ŕϐ��ɏ������݂܂��B
%
%   netcdf.putVar(ncid,varid,start,count,data) �́A�l�̔z��Z�N�V������ 
%   netCDF �ϐ��ɏ������݂܂��B�z��Z�N�V�����́Astart �� count �̃x�N�g����
%   �w�肳��A�w�肵���ϐ��̊e�����ɉ������l�̊J�n�C���f�b�N�X�ƃJ�E���g��
%   �^�����܂��B
%
%   netcdf.putVar(ncid,varid,start,count,stride,data) �́Astride �����ŗ^����
%   �ꂽ�T���v�����O��Ԃ��g�p���܂��B
%
%   ���̊֐����g�p����ɂ́A�o�[�W���� 3.6.2 �� "NetCDF C Interface Guide" ��
%   �Ɋ܂܂�� netCDF �Ɋւ�������n�m���Ă���K�v������܂��B
%   ���̃h�L�������e�[�V�����́A
%   <http://www.unidata.ucar.edu/software/netcdf/old_docs/docs_3_6_2/> �� 
%   Unidata �� Web �T�C�g�ɂ���܂��B���̊֐��́AnetCDF ���C�u���� C API �� 
%   "nc_put_var" �֐��Q�ɑ������܂��B
%
%   �ڍׂ́A�t�@�C�� netcdfcopyright.txt �� mexnccopyright.txt ���Q�Ƃ��Ă���
%   �����B


%   Copyright 2008-2009 The MathWorks, Inc.
