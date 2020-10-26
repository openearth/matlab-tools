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

%% PREAMBLE

close all
fclose all;
clear

%% INPUT

path_folder='C:\Users\chavarri\temporal\201022_vstep\a_003\figures\'; %path to the folder including the figures (and only the figures)
path_video=fullfile(path_folder,'m1'); %path including filename of the video
frame_rate=20; %25
quality=10; %[0,100]

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