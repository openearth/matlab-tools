%netcdf.open  netCDF ���J��
%
%   ncid = netcdf.open(filename, mode) �́A������ netCDF �t�@�C�����J���A
%   ncid �� netCDF �� ID ��Ԃ��܂��B
%
%   �A�N�Z�X�^�C�v�́A���[�h�p�����[�^�ŋL�q����܂��B���[�h�p�����[�^�́A
%   �ǂݎ��-�������݃A�N�Z�X�̏ꍇ�� 'WRITE'�A�t�@�C���X�V�̓��������ꍇ�� 
%   'SHARE'�A�ǂݎ���p�A�N�Z�X�̏ꍇ�� 'NOWRITE' �ɂȂ�܂��B���[�h�́A
%   netcdf.getConstant �Ŏ擾�\�Ȑ��l�ɂ��邱�Ƃ��ł��܂��B����ɁA���[�h�́A
%   ���l���[�h�̒l�̃r�b�g or �ɂ��邱�Ƃ��ł��܂��B
%
%   [chosen_chunksize, ncid] = netcdf.open(filename, mode, chunksize) �́A
%   I/O ���\�ɉe������ǉ��̐��\�����p�����[�^ chunksize ���g�p����ȊO�́A
%   ��L�Ɠ����ł��B���ۂ̒l�́A���͒l�ɑΉ����Ȃ� netCDF ���C�u������
%   �I������܂��B
%
%   ���̊֐����g�p����ɂ́A�o�[�W���� 3.6.2 �� "NetCDF C Interface Guide" ��
%   �Ɋ܂܂�� netCDF �Ɋւ�������n�m���Ă���K�v������܂��B
%   ���̃h�L�������e�[�V�����́A
%   <http://www.unidata.ucar.edu/software/netcdf/old_docs/docs_3_6_2/> �� 
%   Unidata �� Web �T�C�g�ɂ���܂��B���̊֐��́AnetCDF ���C�u���� C API �� 
%   "nc_open" �� "nc__open" �֐��ɑ������܂��B
%
%   �ڍׂ́A�t�@�C�� netcdfcopyright.txt �� mexnccopyright.txt ���Q�Ƃ��Ă���
%   �����B
%
%   �Q�l netcdf.getConstant.


%   Copyright 2008-2009 The MathWorks, Inc.
