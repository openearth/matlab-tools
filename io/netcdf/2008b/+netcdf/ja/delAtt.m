%netcdf.delAtt  netCDF �����̍폜
%
%   netcdf.delAtt(ncid,varid,attName) �́Avarid �Ŏ��ʂ����ϐ����� attName 
%   �Ŏ��ʂ���鑮�����폜���܂��B�O���[�o���������폜����ɂ́Avarid �ɑ΂��� 
%   netcdf.getConstant('GLOBAL') ���g�p���Ă��������B
%
%   ���̊֐����g�p����ɂ́A�o�[�W���� 3.6.2 �� "NetCDF C Interface Guide" ��
%   �Ɋ܂܂�� netCDF �Ɋւ�������n�m���Ă���K�v������܂��B
%   ���̃h�L�������e�[�V�����́A
%   <http://www.unidata.ucar.edu/software/netcdf/old_docs/docs_3_6_2/> �� 
%   Unidata �� Web �T�C�g�ɂ���܂��B���̊֐��́AnetCDF ���C�u���� C API �� 
%   "nc_del_att" �֐��ɑ������܂��B
%
%   �ڍׂ́A�t�@�C�� netcdfcopyright.txt �� mexnccopyright.txt ���Q�Ƃ��Ă���
%   �����B
%
%   �Q�l netcdf.getConstant.


%   Copyright 2008-2009 The MathWorks, Inc.
