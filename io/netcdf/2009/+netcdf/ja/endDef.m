%netcdf.endDef  netCDF �t�@�C����`���[�h�̏I�[
%
%   netcdf.endDef(ncid) �́A��`���[�h�͈͊O�� ncid �Ŏ��ʂ���� netCDF ��
%   �擾���܂��B
%
%   netcdf.endDef(ncid,h_minfree,v_align,v_minfree,r_align) �́A4 �̐��\
%   �����p�����[�^�̒ǉ����g���ȊO�́Anetcdf.endDef �Ɠ����ł��B
%
%   ���\�p�����[�^���g�p���闝�R�� 1 �́Ah_minfree �p�����[�^���g���� 
%   netCDF �t�@�C���̃w�b�_���̗]���ȋ󔒂�\�񂷂邽�߂ł��B���Ƃ��΁A
%
%       ncid = netcdf.endDef(ncid,20000,4,0,4);
%
%   �́A������ǉ�����ꍇ�Ɍ�Ŏg�p�����w�b�_���� 20000 �o�C�g��\�񂵂܂��B
%   ����́A���ɑ傫���t�@�C���ō�Ƃ���ꍇ�ɁA�ɂ߂Č������悭�Ȃ�܂��B
%
%   ���̊֐����g�p����ɂ́A�o�[�W���� 3.6.2 �� "NetCDF C Interface Guide" ��
%   �Ɋ܂܂�� netCDF �Ɋւ�������n�m���Ă���K�v������܂��B
%   ���̃h�L�������e�[�V�����́A
%   <http://www.unidata.ucar.edu/software/netcdf/old_docs/docs_3_6_2/> �� 
%   Unidata �� Web �T�C�g�ɂ���܂��B���̊֐��́AnetCDF ���C�u���� C API �� 
%   "nc_del_att" �֐��ɑ������܂��B���̊֐��́AnetCDF ���C�u���� C API �� 
%   "nc_enddef" �� "nc__enddef" �֐��ɑ������܂��B
%
%   �ڍׂ́A�t�@�C�� netcdfcopyright.txt �� mexnccopyright.txt ���Q�Ƃ��Ă���
%   �����B


%   Copyright 2008-2009 The MathWorks, Inc.
