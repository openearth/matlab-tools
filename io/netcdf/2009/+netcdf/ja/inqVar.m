%netcdf.inqVar  netCDF �ϐ��Ɋւ�����̏o��
%
%   [varname,xtype,dimids,natts] = netcdf.inqVar(ncid,varid) �́A���O�A
%   �f�[�^�^�C�v�A���� ID�Avarid �Ŏ��ʂ��ꂽ�ϐ��̑����̐���Ԃ��܂��B
%
%   ���̊֐����g�p����ɂ́A�o�[�W���� 3.6.2 �� "NetCDF C Interface Guide" ��
%   �Ɋ܂܂�� netCDF �Ɋւ�������n�m���Ă���K�v������܂��B
%   ���̃h�L�������e�[�V�����́A
%   <http://www.unidata.ucar.edu/software/netcdf/old_docs/docs_3_6_2/> �� 
%   Unidata �� Web �T�C�g�ɂ���܂��B���̊֐��́AnetCDF ���C�u���� C API �� 
%   "nc_inq_var" �֐��ɑ������܂��B
%   MATLAB �� FORTRAN �X�^�C���̕��т��g�p���邽�߁A���� ID �̕��т́A
%   C API ���瓾������тƋt�ɂȂ�܂��B
%
%   �ڍׂ́A�t�@�C�� netcdfcopyright.txt �� mexnccopyright.txt ���Q�Ƃ��Ă���
%   �����B


%   Copyright 2008-2009 The MathWorks, Inc.
