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

parin=inputParser;

addOptional(parin,'frame_rate',20);
addOptional(parin,'quality',50);
addOptional(parin,'path_video',fullfile(path_folder,'movie'));

parse(parin,varargin{:});

frame_rate=parin.Results.frame_rate;
quality=parin.Results.quality;
path_video=parin.Results.path_video;

path_video_ext=sprintf('%s.mp4',path_video);
if exist(path_video_ext,'file')==2
    delete(path_video_ext)
end

%% MAKE VIDEO

dire=dir(path_folder);
nf=numel(dire)-2;

video_var=VideoWriter(path_video,'MPEG-4');
video_var.FrameRate=frame_rate;
video_var.Quality=quality;

open(video_var)

for kf=1:nf
    kfa=kf+2;
    im=imread(fullfile(dire(kfa).folder,dire(kfa).name));
    writeVideo(video_var,im)
    fprintf('%5.1f %% done \n',kf/nf*100)
end

close(video_var)