function EHY_movieMaker(imageDir,varargin)
%% EHY_movieMaker(varargin)
%
% This functions makes a .avi file based on a folder
% with images. Make sure the filenames are in ascending order.

% Example1: EHY_movieMaker
% Example2: EHY_movieMaker('D:\pngFiles\')
% Example3: EHY_movieMaker('D:\pngFiles\','outputFile','D:\animation.avi','frameRate',3)

% created by Julien Groenenboom, June 2018
%% OPT
if nargin==0
    EHY_movieMaker_interactive;
    return
else
    OPT.outputFile=[imageDir filesep 'EHY_movieMaker_OUTPUT' filesep 'movie.avi'];
    OPT.frameRate=4;
    OPT=setproperty(OPT,varargin);
end

%% images 2 movie
imageFiles=[dir([imageDir filesep '*.png']),...
    dir([imageDir filesep '*.jpg'])];

if isempty(imageFiles)
    if isnumeric(filename); disp('EHY_convert stopped by user.'); return; end
end
%create output directory
if ~exist(fileparts(OPT.outputFile))
    mkdir(fileparts(OPT.outputFile))
end

writerObj = VideoWriter(OPT.outputFile);
writerObj.FrameRate = OPT.frameRate;
open(writerObj);

for iF=1:length(imageFiles)
    disp(['progress: ' num2str(iF) '/' num2str(length(imageFiles))]);  
    thisimage=imread([imageDir filesep imageFiles(iF).name]);
    writeVideo(writerObj, thisimage);
end
close(writerObj);
disp(['EHY_movieMaker created:' char(10) OPT.outputFile])
disp('If the resolution of the images is too large, you might not be able to play the video.')
EHYs(mfilename);
end

%% EHY_movieMaker_interactive
function EHY_movieMaker_interactive
% get imageDir
disp('Open a directory containing images (.png / .jpg)')
imageDir=uigetdir('*.*','Open a directory containing images (.png / .jpg)');
if isnumeric(imageDir); disp('EHY_movieMaker stopped by user.'); return; end

% get OPT.frameRate
answer=inputdlg('Frame rate in frames per seconde (fps):','Frame rate',1,{'4'});
if isempty(answer); disp('EHY_movieMaker stopped by user.'); return; end
OPT.frameRate=str2num(answer{1});

%
disp([char(10) 'Note that next time you want to get this data, you can also use:'])
disp(['EHY_movieMaker(''' imageDir ''',''frameRate'',' num2str(OPT.frameRate) ');'])

disp('start writing the screenplay') 
disp('start making the movie') 
EHY_movieMaker(imageDir,OPT);
end