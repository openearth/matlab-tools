%netcdf.getAtt  netCDF �����̏o��
%
%   attrvalue = netcdf.getAtt(ncid,varid,attname) �́A�����l��ǂݍ��݂܂��B
%   attrvalue �̃N���X�́A���������̃f�[�^�^�C�v�̃N���X�ƈ�v���܂��B
%   ���Ƃ��΁A������ netCDF �̃f�[�^�^�C�v NC_INT �����ꍇ�A�o�̓f�[�^��
%   �N���X�� int32 �ɂȂ�܂��B������ netCDF �̃f�[�^�^�C�v NC_BYTE ������
%   �ꍇ�́Aint8 �̒l�ɂȂ�܂��B
%
%   ���̊֐��́A�Ō�̓��͈����Ƃ��ăf�[�^�^�C�v�̕�������g�����ƂŁA�����
%   �C�����Ďg�p���邱�Ƃ��ł��܂��B����́AnetCDF ���C�u�������ϊ���������
%   ����A�w�肷��o�̓f�[�^�^�C�v�ɉe�����܂��B
%
%   �\�ȃf�[�^�^�C�v�̕�����̃��X�g�́A'double', 'single', 'int32', 
%   'int16', 'int8', 'uint8' �ō\������܂��B
%
%   �{���x�Ƃ��đ����l��ǂݍ��ނɂ́A�ȉ��̂悤�Ɏg�p���܂��B
%
%     data=netcdf.getAtt(ncid,varid,attname,'double');
%
%   ���̊֐����g�p����ɂ́A�o�[�W���� 3.6.2 �� "NetCDF C Interface Guide" ��
%   �Ɋ܂܂�� netCDF �Ɋւ�������n�m���Ă���K�v������܂��B
%   ���̃h�L�������e�[�V�����́A
%   <http://www.unidata.ucar.edu/software/netcdf/old_docs/docs_3_6_2/> �� 
%   Unidata �� Web �T�C�g�ɂ���܂��B���̊֐��́AnetCDF ���C�u���� C API �� 
%   "nc_get_att" �֐��Q�ɑ������܂��B
%
%   �ڍׂ́A�t�@�C�� netcdfcopyright.txt �� mexnccopyright.txt ���Q�Ƃ��Ă���
%   �����B
%
%   �Q�l netcdf.getConstant.


%   Copyright 2008-2009 The MathWorks, Inc.
