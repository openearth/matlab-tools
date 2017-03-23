function EHY_wait(time,path)
% EHY_wait(time,path)
% Onces TIME is reached, this function runs the PATH
% time can be either a datenum or datestr
% 
% Example: EHY_wait('23-Mar-2017 12:00','D:\script.m')
%
% created by Julien Groenenboom, March 2017
if ~isnumeric(time)
    time=datenum(time);
end

keepLooping=1;
while keepLooping
    if now > time
        run(path)
        keepLooping=0;
    else
        disp(['Waiting untill ' datestr(time) ' - time now: ' datestr(now)]);
         pause(10)
    end
end

