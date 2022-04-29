function D3D_convert_rst_to_ini(rstfilename, inifilename, filesuffix); 
[inipath,ininame,iniext] = fileparts(inifilename);

xz = ncread(rstfilename, 'FlowElem_xzw'); 
yz = ncread(rstfilename, 'FlowElem_yzw'); 

% s1 
s1 = ncread(rstfilename, 's1'); 

%ucx,uxy
ucx = ncread(rstfilename, 'ucx'); 
ucy = ncread(rstfilename, 'ucy'); 

ncinf = ncinfo(rstfilename); 
write_bl = false; 
if sum(strcmp({ncinf.Variables.Name}, 'FlowElem_bl'))==1; 
    bl = ncread(rstfilename, 'FlowElem_bl'); 
    write_bl = true; 
end

waterlevelfile = fullfile('waterlevel', sprintf('waterlevel_%s.xyz',filesuffix));
savesamples( inipath, waterlevelfile, xz, yz, s1); 
if write_bl
    bedlevelfile = fullfile('bedlevel', sprintf('bedlevel_%s.xyz',filesuffix));
    savesamples( inipath, bedlevelfile, xz, yz, bl); 
end
velocityxfile = fullfile('velocity', sprintf('velocity_x_%s.xyz',filesuffix));
savesamples( inipath, velocityxfile, xz, yz, ucx); 

velocityyfile = fullfile('velocity', sprintf('velocity_y_%s.xyz',filesuffix));
savesamples( inipath, velocityyfile, xz, yz, ucy); 


%%
Info = inifile('new');
C='General'; 
[Info, IndexChapter] = inifile('add', Info, C);
K='fileVersion'; Value = '2.00';
Info = inifile('set', Info, C, K, Value);
K='fileType';    Value = 'iniField';
Info = inifile('set', Info, C, K, Value);

C='Initial'; 
[Info, IndexChapter] = inifile('add', Info, C);
K='quantity';            Value = 'waterlevel';
Info = inifile('set', Info, IndexChapter, K, Value);
K='dataFile';            Value = waterlevelfile;
Info = inifile('set', Info, IndexChapter, K, Value);
K='dataFileType';        Value = 'sample';
Info = inifile('set', Info, IndexChapter, K, Value);
K='interpolationMethod'; Value = 'triangulation';
Info = inifile('set', Info, IndexChapter, K, Value);
K='operand';             Value = 'o';
% Info = inifile('set', Info, IndexChapter, K, Value);
% K='averagingType';       Value = '';
% Info = inifile('set', Info, IndexChapter, K, Value);
% K='averagingRelSize';    Value = '';
% Info = inifile('set', Info, IndexChapter, K, Value);
% K='averagingNumMin';     Value = '';
% Info = inifile('set', Info, IndexChapter, K, Value);
% K='averagingPercentile'; Value = '';
% Info = inifile('set', Info, IndexChapter, K, Value);
% K='extrapolationMethod'; Value = '';
% Info = inifile('set', Info, IndexChapter, K, Value);
% K='locationType';        Value = '';
% Info = inifile('set', Info, IndexChapter, K, Value);
% K='value';               Value = '';
% Info = inifile('set', Info, IndexChapter, K, Value);

if write_bl
    C='Initial'; 
    [Info, IndexChapter] = inifile('add', Info, C);
    K='quantity';            Value = 'bedlevel';
    Info = inifile('set', Info, IndexChapter, K, Value);
    K='dataFile';            Value = bedlevelfile;
    Info = inifile('set', Info, IndexChapter, K, Value);
    K='dataFileType';        Value = 'sample';
    Info = inifile('set', Info, IndexChapter, K, Value);
    K='interpolationMethod'; Value = 'triangulation';
    Info = inifile('set', Info, IndexChapter, K, Value);
    K='operand';             Value = 'o';
    Info = inifile('set', Info, IndexChapter, K, Value);
end

C='Initial'; 
[Info, IndexChapter] = inifile('add', Info, C);
K='quantity';            Value = 'initialvelocityx';
Info = inifile('set', Info, IndexChapter, K, Value);
K='dataFile';            Value = velocityxfile;
Info = inifile('set', Info, IndexChapter, K, Value);
K='dataFileType';        Value = 'sample';
Info = inifile('set', Info, IndexChapter, K, Value);
K='interpolationMethod'; Value = 'triangulation';
Info = inifile('set', Info, IndexChapter, K, Value);
K='operand';             Value = 'o';
Info = inifile('set', Info, IndexChapter, K, Value);

C='Initial'; 
[Info, IndexChapter] = inifile('add', Info, C);
K='quantity';            Value = 'initialvelocityy';
Info = inifile('set', Info, IndexChapter, K, Value);
K='dataFile';            Value = velocityyfile;
Info = inifile('set', Info, IndexChapter, K, Value);
K='dataFileType';        Value = 'sample';
Info = inifile('set', Info, IndexChapter, K, Value);
K='interpolationMethod'; Value = 'triangulation';
Info = inifile('set', Info, IndexChapter, K, Value);
K='operand';             Value = 'o';
Info = inifile('set', Info, IndexChapter, K, Value);

Info = inifile('write', inifilename, Info);


end

function savesamples( samplepath, samplefile, xz, yz, zz); 
    samplefullfile = fullfile(samplepath, samplefile); 
    [samplefullpath,~,~] = fileparts(samplefullfile); 
    if ~(exist(samplefullpath) == 7); 
        mkdir(samplefullpath);
    end
    samples('write',samplefullfile,xz,yz,zz);
end
