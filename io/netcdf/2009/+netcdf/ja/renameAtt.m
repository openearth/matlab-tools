%netcdf.renameAtt  netCDF �������̕ύX
%
%   netcdf.renameAtt(ncid,varid,oldName,newName) �́AoldName �Ŏ��ʂ����
%   ������ newName �ɕύX���܂��B�����́Avarid �Ŏ��ʂ����ϐ��Ɋ֘A���܂��B
%   �O���[�o�������́Avarid �ɑ΂��� netcdf.getConstant('GLOBAL') ���g�p����
%   ���ƂŎw�肷�邱�Ƃ��ł��܂��B
%
%   ���̊֐����g�p����ɂ́A�o�[�W���� 3.6.2 �� "NetCDF C Interface Guide" ��
%   �Ɋ܂܂�� netCDF �Ɋւ�������n�m���Ă���K�v������܂��B
%   ���̃h�L�������e�[�V�����́A
%   <http://www.unidata.ucar.edu/software/netcdf/old_docs/docs_3_6_2/> �� 
%   Unidata �� Web �T�C�g�ɂ���܂��B���̊֐��́AnetCDF ���C�u���� C API �� 
%   "nc_rename_att" �֐��ɑ������܂��B
%
%   �ڍׂ́A�t�@�C�� netcdfcopyright.txt �� mexnccopyright.txt ���Q�Ƃ��Ă���
%   �����B
%
%   �Q�l netcdf.getConstant.


%   Copyright 2008-2009 The MathWorks, Inc.
