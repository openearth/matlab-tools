%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17102 $
%$Date: 2021-03-02 22:30:16 +0100 (Tue, 02 Mar 2021) $
%$Author: chavarri $
%$Id: D3D_plot.m 17102 2021-03-02 21:30:16Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D_plot.m $
%
function [tim_f,val_f]=lowpassfilter(tim,val,fpass,steepness)
                    
%uniform, unique
data_r=timetable(tim,val);
data_r=rmmissing(data_r);
data_r=sortrows(data_r);
tim_u=unique(data_r.tim);
data_r=retime(data_r,tim_u,'mean'); 
data_r=retime(data_r,'regular','linear','TimeStep',minutes(1));
t1=data_r.tim(1);
data_r.tim=data_r.tim-t1;
data_r.tim.Format='s';

%check

if isregular(data_r)==0
    unique(diff(data_r.tim))
    error('it must be regular')
end
if any(isnan(data_r.val))
    error('it must not contain NaN')
end

% fpass=1/(2*24*3600);
% steepness=0.99999;

%filter
data_f=lowpass(data_r,fpass,'Steepness',steepness,'ImpulseResponse','iir');

tim_f=t1+data_f.tim;
val_f=data_f.val;

%% fourier

% tim_s=data_r.tim;
% y=[data_r.val,data_f.val];
% %         varname_1='water level [m]';
% %         varname_2='spectral power [m^2/s]';
% 
% %         varname_1='streamwise velocity [m/s]';
% %         varname_2='spectral power [m^2/s^3]';
% aux=diff(tim_s);
% dt_s=seconds(aux(1));
% nt=numel(tim_s);
% fs=1/dt_s; %[Hz]
% f=(0:nt-1)*(fs/nt); %[Hz]
% 
% yf=fft(y); 
% % pf=abs(yf).^2/nt;    % power of the DFT (also correct, but check the units above)
% pf=abs(yf).^2/dt_s;    % power of the DFT

