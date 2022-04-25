%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision$
%$Date$
%$Author$
%$Id$
%$HeadURL$
%

function make_video(path_folder,varargin)

%% PARSE

if iscell(path_folder) %files to use are given
    path_files=path_folder;
else %folder is given  
    dire=dir(path_folder);
    nf=numel(dire)-2;
    path_files=cell(nf,1);
    for kf=1:nf
        kfa=kf+2;
        path_files{kf,1}=fullfile(dire(kfa).folder,dire(kfa).name);
    end    
end
nf=numel(path_files);
[fdir,fname,~]=fileparts(path_files{1,1});

%varargin
parin=inputParser;

addOptional(parin,'frame_rate',20);
addOptional(parin,'quality',50);
addOptional(parin,'path_video',fullfile(fdir,fname));
addOptional(parin,'overwrite',1);
addOptional(parin,'fid_log',NaN);

parse(parin,varargin{:});

frame_rate=parin.Results.frame_rate;
quality=parin.Results.quality;
path_video=parin.Results.path_video;
do_over=parin.Results.overwrite;

%% SKIP OR DELETE

path_video_ext=sprintf('%s.mp4',path_video);
if exist(path_video_ext,'file')==2
    if do_over
        messageOut(fid_log,sprintf('Movie exists, overwriting: %s',path_video_ext));
        delete(path_video_ext)
    else
        messageOut(fid_log,sprintf('Movie exists, not-overwriting: %s',path_video_ext));
        return
    end
end

%% MAKE VIDEO

video_var=VideoWriter(path_video,'MPEG-4');
video_var.FrameRate=frame_rate;
video_var.Quality=quality;

open(video_var)

for kf=1:nf
    im=imread(path_files{kf,1});
    writeVideo(video_var,im)
    fprintf('%5.1f %% done \n',kf/nf*100)
end

close(video_var)