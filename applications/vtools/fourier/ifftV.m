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
%INPUT
%
%E.G.
%   [fx,fy,P2]=fftV(x,y,noise);
%   noise_rec=ifftV(x,v,P2);




function [varargout]=ifftV(varargin)

%% PARSE

ni=numel(varargin);
if mod(ni,2)==0 %there are 2 input plus pair-input argument
    x=varargin{1,1};
    P2=varargin{1,2};
    if ni>2
        varargin_pi=varargin{3:end};
    end
    is1d=1;
    y=42; %by giving it one value, dy qill be empty but ny=1
elseif mod(ni-3,2)==0 %there are 3 input plus pair-input argument
    x=varargin{1,1};
    y=varargin{1,2};
    P2=varargin{1,3};
    if ni>3
        varargin_pi=varargin{4:end};
    end
    is1d=0;
else
    error('Input number does not match expectations.');
end

%% CALC

[dx,fx2,fx1,dy,fy2,fy1]=fourier_freq(x,y);

[noise_rec_2d,noise_rec]=ifftV_frequency(fx2,fy2,x,y,P2);

%% OUT

varargout{1,1}=noise_rec_2d;
varargout{1,2}=noise_rec;

end %function