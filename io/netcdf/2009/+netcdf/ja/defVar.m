%netcdf.defVar  netCDF �ϐ��̍쐬
%
%   varid = netcdf.defVar(ncid,varname,xtype,dimids) �́A���O�A�f�[�^�^�C�v�A
%   ���� ID �̃��X�g��^���āA�V�K�ϐ����쐬���܂��B�f�[�^�^�C�v�́Axtype ��
%   �^�����A'double' �̂悤�ȕ�����\���A�܂��́Anetcdf.getConstant �ŗ^������
%   ���̂Ɠ����Ȑ��l�̂����ꂩ�ɂ��邱�Ƃ��ł��܂��B�߂�l�́A�V�K�ϐ��ɑΉ�����
%   ���l ID �ł��B
%
%   ���̊֐��́AnetCDF ���C�u���� C API �� "nc_def_var" �֐��ɑ������܂����A
%   MATLAB �� FORTRAN �X�^�C���̕��т��g�p���邽�߁A�ő��ŉς̎����� 
%   1 �ԖڂɁA�ł��x�������͍Ō�ɂȂ�܂��B���̂��߁A�����̂Ȃ������́A
%   ���� ID �̃��X�g�̍Ō�ɂȂ�܂��B���̏��Ԃ́AC API �̕��тƋt�ł��B
%
%   ���̊֐����g�p����ɂ́A�o�[�W���� 3.6.2 �� "NetCDF C Interface Guide" ��
%   �Ɋ܂܂�� netCDF �Ɋւ�������n�m���Ă���K�v������܂��B
%   ���̃h�L�������e�[�V�����́A
%   <http://www.unidata.ucar.edu/software/netcdf/old_docs/docs_3_6_2/> �� 
%   Unidata �� Web �T�C�g�ɂ���܂��B
%
%   �ڍׂ́A�t�@�C�� netcdfcopyright.txt �� mexnccopyright.txt ���Q�Ƃ���
%   ���������B
%
%   �Q�l netcdf.getConstant.


%   Copyright 2008-2009 The MathWorks, Inc.
