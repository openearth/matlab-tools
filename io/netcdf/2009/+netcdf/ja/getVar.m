%netcdf.getVar  netCDF �ϐ�����f�[�^�̃f�[�^�̏o��
%
%   data = netcdf.getVar(ncid,varid) �́A�ϐ��S�̂�ǂݍ��݂܂��B
%   �o�̓f�[�^�̃N���X�́AnetCDF �ϐ��̃N���X�ƈ�v���܂��B
%
%   data = netcdf.getVar(ncid,varid,start) �́A�w�肵���C���f�b�N�X�Ŏn�܂�
%   �P��̒l��ǂݍ��݂܂��B
%
%   data = netcdf.getVar(ncid,varid,start,count) �́A�ϐ��̃Z�N�V������
%   �A���I�ɓǂݍ��݂܂��B
%
%   data = netcdf.getVar(ncid,varid,start,count,stride) �́A�ϐ��� 
%   strided �Z�N�V������ǂݍ��݂܂��B
%
%   ���̊֐��́A�Ō�̓��͈����Ƃ��ăf�[�^�^�C�v�̕�������g�����ƂŁA
%   ����ɏC�����Ďg�p���邱�Ƃ��ł��܂��B����́AnetCDF ���C�u�������ϊ���
%   ���������A�w�肷��o�̓f�[�^�^�C�v�ɉe�����܂��B
%
%   �\�ȃf�[�^�^�C�v�̕�����̃��X�g�́A'double', 'single', 'int32', 
%   'int16', 'int8', 'uint8' �ō\������܂��B
%
%   �{���x�Ƃ��Đ����̕ϐ��S�̂�ǂݍ��ނɂ́A�ȉ��̂悤�Ɏg�p���܂��B
%
%     data=netcdf.getVar(ncid,varid,'double');
%
%   ���̊֐����g�p����ɂ́A�o�[�W���� 3.6.2 �� "NetCDF C Interface Guide" ��
%   �Ɋ܂܂�� netCDF �Ɋւ�������n�m���Ă���K�v������܂��B
%   ���̃h�L�������e�[�V�����́A
%   <http://www.unidata.ucar.edu/software/netcdf/old_docs/docs_3_6_2/> �� 
%   Unidata �� Web �T�C�g�ɂ���܂��B���̊֐��́AnetCDF ���C�u���� C API �� 
%   "nc_get_var" �֐��Q�ɑ������܂��B
%
%   �ڍׂ́A�t�@�C�� netcdfcopyright.txt �� mexnccopyright.txt ���Q�Ƃ��Ă���
%   �����B


%   Copyright 2008-2009 The MathWorks, Inc.
