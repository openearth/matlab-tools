%netcdf.setDefaultFormat  �f�t�H���g�� netCDF �t�@�C���`���̕ύX
%
%   oldFormat = netcdf.setDefaultFormat(newFormat) �́A�����쐬����t�@�C����
%   �`���� newFormat �ɕύX���A�Â��`���̒l��Ԃ��܂��B
%   newFormat �́A'FORMAT_CLASSIC' �܂��� 'FORMAT_64BIT'�A���邢�́A
%   netcdf.getConstant �Ŏ擾�������̂Ɠ����Ȑ��l�̂����ꂩ�ɂȂ�܂��B
%
%   ��
%   --
%       newFormat = netcdf.getConstant('NC_FORMAT_64BIT');
%       oldFormat = netcdf.setDefaultFormat(newFormat);
%
%   ���̊֐����g�p����ɂ́A�o�[�W���� 3.6.2 �� "NetCDF C Interface Guide" ��
%   �Ɋ܂܂�� netCDF �Ɋւ�������n�m���Ă���K�v������܂��B
%   ���̃h�L�������e�[�V�����́A
%   <http://www.unidata.ucar.edu/software/netcdf/old_docs/docs_3_6_2/> �� 
%   Unidata �� Web �T�C�g�ɂ���܂��B���̊֐��́AnetCDF ���C�u���� C API �� 
%   "nc_set_default_format" �֐��ɑ������܂��B
%
%   �ڍׂ́A�t�@�C�� netcdfcopyright.txt �� mexnccopyright.txt ���Q�Ƃ��Ă���
%   �����B
%
%   �Q�l netcdf.getConstant.


%   Copyright 2008-2009 The MathWorks, Inc.
