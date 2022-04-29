function D3D_convert_rst_to_ini(rstfile, inifile, fileprefix); 

xz = ncread(rstfile, 'FlowElem_xzw'); 
yz = ncread(rstfile, 'FlowElem_yzw'); 

xz_bnd = ncread(rstfile, 'FlowElem_xbnd'); 
yz_bnd = ncread(rstfile, 'FlowElem_ybnd'); 

% s1 
s1 = ncread(rstfile, 's1'); 
s1_bnd = ncread(rstfile, 's1_bnd'); 

%ucx,uxy
ucx = ncread(rstfile, 'ucx'); 
ucy = ncread(rstfile, 'ucy'); 

%bl
bl = ncread(rstfile, 'FlowElem_bl'); 
mor_bl = ncread(rstfile, 'mor_bl'); 
bl_bnd = ncread(rstfile, 'bl_bnd'); 

waterlevelfile = sprintf('%s_s1.xyz',fileprefix);
bedlevelfile = sprintf('%s_bl.xyz',fileprefix)
uvelocityfile = sprintf('%s_ucx.xyz',fileprefix)
vvelocityfile = sprintf('%s_ucy.xyz',fileprefix)

samples('write',waterlevelfile,xz,yz,s1)
samples('write',bedlevelfile,xz,yz,bl)
samples('write',uvelocityfile,xz,yz,ucx)
samples('write',vvelocityfile,xz,yz,ucy)

%%
Info = inifile('new')
C='General'; 
[Info, IndexChapter] = inifile('add', Info, C)
K='fileVersion'; Value = '2.00';
Info = inifile('set', Info, C, K, Value)
K='fileType';    Value = 'iniField';
Info = inifile('set', Info, C, K, Value)

C='Initial'; 
[Info, IndexChapter] = inifile('add', Info, C)
K='quantity';            Value = 'waterlevel';
Info = inifile('set', Info, IndexChapter, K, Value)
K='dataFile';            Value = waterlevelfile;
Info = inifile('set', Info, IndexChapter, K, Value)
K='dataFileType';        Value = 'sample';
Info = inifile('set', Info, IndexChapter, K, Value)
K='interpolationMethod'; Value = 'triangulation';
Info = inifile('set', Info, IndexChapter, K, Value)
K='operand';             Value = 'o';
Info = inifile('set', Info, IndexChapter, K, Value)
K='averagingType';       Value = '';
Info = inifile('set', Info, IndexChapter, K, Value)
K='averagingRelSize';    Value = '';
Info = inifile('set', Info, IndexChapter, K, Value)
K='averagingNumMin';     Value = '';
Info = inifile('set', Info, IndexChapter, K, Value)
K='averagingPercentile'; Value = '';
Info = inifile('set', Info, IndexChapter, K, Value)
K='extrapolationMethod'; Value = '';
Info = inifile('set', Info, IndexChapter, K, Value)
K='locationType';        Value = '';
Info = inifile('set', Info, IndexChapter, K, Value)
K='value';               Value = '';
Info = inifile('set', Info, IndexChapter, K, Value)

C='Initial'; 
[Info, IndexChapter] = inifile('add', Info, C)
K='quantity';            Value = 'bedlevel';
Info = inifile('set', Info, IndexChapter, K, Value)
K='dataFile';            Value = bedlevelfile;
Info = inifile('set', Info, IndexChapter, K, Value)
K='dataFileType';        Value = 'sample';
Info = inifile('set', Info, IndexChapter, K, Value)
K='interpolationMethod'; Value = 'triangulation';
Info = inifile('set', Info, IndexChapter, K, Value)
K='operand';             Value = 'o';
Info = inifile('set', Info, IndexChapter, K, Value)

C='Initial'; 
[Info, IndexChapter] = inifile('add', Info, C)
K='quantity';            Value = 'initialvelocityx';
Info = inifile('set', Info, IndexChapter, K, Value)
K='dataFile';            Value = uvelocityfile;
Info = inifile('set', Info, IndexChapter, K, Value)
K='dataFileType';        Value = 'sample';
Info = inifile('set', Info, IndexChapter, K, Value)
K='interpolationMethod'; Value = 'triangulation';
Info = inifile('set', Info, IndexChapter, K, Value)
K='operand';             Value = 'o';
Info = inifile('set', Info, IndexChapter, K, Value)

C='Initial'; 
[Info, IndexChapter] = inifile('add', Info, C)
K='quantity';            Value = 'initialvelocityy';
Info = inifile('set', Info, IndexChapter, K, Value)
K='dataFile';            Value = vvelocityfile;
Info = inifile('set', Info, IndexChapter, K, Value)
K='dataFileType';        Value = 'sample';
Info = inifile('set', Info, IndexChapter, K, Value)
K='interpolationMethod'; Value = 'triangulation';
Info = inifile('set', Info, IndexChapter, K, Value)
K='operand';             Value = 'o';
Info = inifile('set', Info, IndexChapter, K, Value)

Info = inifile('write', inifile, Info)
