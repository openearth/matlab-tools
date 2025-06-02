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
%Create movie
%
%INPUT:
%   -path_folder:
%       cell = files to make the movie. If multidimensional, images are concatenated.
%       char = full path to the folder with the files to use

function make_video(path_folder,varargin)

%% PARSE

if iscell(path_folder) %files to use are given
    path_files=path_folder;
else %folder is given  
    dire=dir(path_folder);
    path_files={};
    for kf=1:numel(dire)
        fpath_file=fullfile(dire(kf).folder,dire(kf).name);
        if isfolder(fpath_file); continue; end
        path_files=cat(1,path_files,fpath_file);
    end    
end
[nf,np]=size(path_files);
if nf==1 
    error('It is not possible to make a movie with one frame only.')
end
[fdir,fname,~]=fileparts(path_files{1,1});

%varargin
parin=inputParser;

addOptional(parin,'frame_rate',20);
addOptional(parin,'quality',50);
addOptional(parin,'path_video',fullfile(fdir,fname));
addOptional(parin,'overwrite',1);
addOptional(parin,'fid_log',NaN);
addOptional(parin,'position',NaN);

parse(parin,varargin{:});

frame_rate=parin.Results.frame_rate;
quality=parin.Results.quality;
path_video=parin.Results.path_video;
do_over=parin.Results.overwrite;
fid_log=parin.Results.fid_log;
pos_fig=parin.Results.position;
if isnan(pos_fig)
    pos_fig=cell(1,np);
    for kp=1:np
        pos_fig{1,kp}=[1,kp];
    end
end
    
%% SHORTEN PATH

path_video_ext=sprintf('%s.mp4',path_video);
if numel(path_video_ext)>256
    fname=sprintf('m%d',randi(100));
    path_video=fullfile(fdir,fname);
    path_video_ext=sprintf('%s.mp4',path_video);
    messageOut(fid_log,sprintf('Name of video is too long, shortened to: %s',path_video_ext));
end

%% SKIP OR DELETE

if exist(path_video_ext,'file')==2
    if do_over
        messageOut(fid_log,sprintf('Movie exists, overwriting: %s',path_video_ext));
        delete(path_video_ext)
        pause(5) %we need to wait to be deleted
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
    for kp=1:np
        %This is far from perfect. The size of <im> is continuously changing.
        %2DO: we have to deal with the position of the images. 
        if kp==1
            im=imread(path_files{kf,kp});
        else
            im=cat(2,im,imread(path_files{kf,kp}));
        end
        if kf==1 && (size(im,1)>3000 || size(im,2)>3000)
            warning('If there is an error, it may be the image is too large')
        end
    end
    
    writeVideo(video_var,im)
    messageOut(fid_log,sprintf('Creating movie %5.1f %% \n',kf/nf*100));
end

close(video_var)