%netcdf.create  �V�K netCDF �t�@�C���̍쐬
%
%   ncid = netcdf.create(filename, mode) �́A�t�@�C���쐬���[�h�ɏ]���A
%   �V�K netCDF �t�@�C�����쐬���܂��B�߂�l�́A�t�@�C�� ID �ł��B
%
%   �A�N�Z�X�^�C�v�́A���[�h�p�����[�^�ŋL�q����܂��B���[�h�p�����[�^�́A
%   �����̃t�@�C����ی삷��ꍇ�� 'noclobber'�A�t�@�C���X�V�̓��������ꍇ�� 
%   'share'�A2 GB ���傫���t�@�C���̍쐬��������ꍇ�� '64bit_offset' ��
%   �����ꂩ�ł��B���[�h�́Anetcdf.getConstant �Ŏ擾�\�Ȑ��l�ɂ��A�܂��́A
%   ���l���[�h�l�̃r�b�g or �ɂ��邱�Ƃ��ł��܂��B
%
%   [chunksize_out, ncid]=netcdf.create(filename,mode,initsz,chunksize) �́A
%   �ǉ��̐��\�����p�����[�^���g���āA�V�K�� netCDF �t�@�C�����쐬���܂��B
%   initsz �́A�t�@�C���̏����T�C�Y��ݒ肵�܂��Bchunksize �́AI/O ���\��
%   �e�����܂��B���ۂ̒l�́A���͒l�ɑΉ����Ȃ� netCDF ���C�u�����őI������܂��B
%
%   ���̊֐����g�p����ɂ́A�o�[�W���� 3.6.2 �� "NetCDF C Interface Guide" ��
%   �Ɋ܂܂�� netCDF �Ɋւ�������n�m���Ă���K�v������܂��B
%   ���̃h�L�������e�[�V�����́A
%   <http://www.unidata.ucar.edu/software/netcdf/old_docs/docs_3_6_2/> �� 
%   Unidata �� Web �T�C�g�ɂ���܂��B���̊֐��́AnetCDF ���C�u���� C API �� 
%   "nc_create" �� "nc__create" �֐��ɑ������܂��B
%
%   �ڍׂ́A�t�@�C�� netcdfcopyright.txt �� mexnccopyright.txt ���Q�Ƃ���
%   ���������B
%
%   �Q�l netcdf.getConstant.


%   Copyright 2008-2009 The MathWorks, Inc.
