%NETCDF  MATLAB NETCDF �@�\�̊T�v
%   MATLAB �́AnetCDF ���C�u������ 30 �ȏ�̊֐��ɒ��ڃA�N�Z�X���邱�Ƃ�
%   ���AnetCDF �t�@�C���ւ̒჌�x���A�N�Z�X�@�\��񋟂��܂��B������ 
%   MATLAB �֐����g�p����ɂ́AnetCDF C �C���^�t�F�[�X���n�m���Ă���K�v��
%   ����܂��B�o�[�W���� 3.6.2 �� "NetCDF C Interface Guide" �́A
%   <http://www.unidata.ucar.edu/software/netcdf/old_docs/docs_3_6_2/> ��
%   �����邱�Ƃ��ł��܂��B
%
%   �����̏ꍇ�AMATLAB �֐��̃V���^�b�N�X�́AnetCDF ���C�u�����֐���
%   �V���^�b�N�X�Ɠ����ł��B�֐��́A"netcdf" ���Ăяo���p�b�P�[�W�Ƃ���
%   ���s����܂��B�����̊֐����g�p����ɂ́A�ȉ��̂悤�Ɋ֐����̐擪��
%   �p�b�P�[�W�� "netcdf" ��t����K�v������܂��B
%
%      ncid = netcdf.open ( ncfile, mode );
%
%   �ȉ��̕\�́AnetCDF �p�b�P�[�W�ŃT�|�[�g����邷�ׂĂ� netCDF ���C�u����
%   �֐��̈ꗗ�ł��B
%
%      abort            - �ŐV�� netCDF �t�@�C����`�����ɖ߂�
%      close            - netCDF �t�@�C�������
%      create           - �V�K netCDF �t�@�C���̍쐬
%      endDef           - netCDF �t�@�C����`���[�h�̏I�[
%      inq              - netCDF �t�@�C���Ɋւ�����̏o��
%      inqLibVers       - netCDF ���C�u�����o�[�W�������̏o��
%      open             - netCDF ���J��
%      reDef            - netCDF  �t�@�C�����`���[�h�ɐݒ�
%      setDefaultFormat - �f�t�H���g�� netCDF �t�@�C���`����ύX
%      setFill          - netCDF �̖��ߍ��݃��[�h�̐ݒ�
%      sync             - netCDF �f�[�^�Z�b�g�ƃf�B�X�N�̓��������
%
%      defDim           - netCDF �����̍쐬
%      inqDim           - netCDF �����̖��O�ƒ����̏o��
%      inqDimID         - ���� ID �̏o��
%      renameDim        - netCDF �������̕ύX
%
%      defVar           - netCDF �ϐ��̍쐬
%      getVar           - netCDF �ϐ�����f�[�^�̃f�[�^�̏o��
%      inqVar           - �ϐ��Ɋւ�����̏o��
%      inqVarID         - �ϐ����Ɋ֘A���� ID �̏o��
%      putVar           - �f�[�^�� netCDF �ϐ��ɏ�������
%      renameVar        - netCDF �ϐ����̕ύX
%
%      copyAtt          - �V�K�ꏊ�ɑ������R�s�[
%      ndelAtt          - netCDF �����̍폜
%      getAtt           - netCDF �����̏o��
%      inqAtt           - netCDF �����Ɋւ�����̏o��
%      inqAttID         - netCDF ������ ID �̏o��
%      inqAttName       - netCDF �������̏o��
%      putAtt           - netCDF �����̏�������
%      renameAtt        - �������̕ύX
%
%
%   �ȉ��̊֐��́AnetCDF ���C�u�����Ɠ����ł͂���܂���B
%
%      getConstantNames - netCDF ���C�u�����ł��邱�Ƃ��������Ă���萔�̃��X�g���o��
%      getConstant      - ���O�t���̒萔�̐��l���o��
%
%   �ڍׂ́A�t�@�C�� netcdfcopyright.txt �� mexnccopyright.txt ���Q�Ƃ��Ă��������B


%   Copyright 2008-2009 The MathWorks, Inc.
