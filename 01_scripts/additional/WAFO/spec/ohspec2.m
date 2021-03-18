function [S, S1] = ohspec2(w,sdata,plotflag)
% OHSPEC2 Calculates and plots a bimodal Ochi-Hubble spectral density
% 
%  CALL:  [S S1] = ohspec2(w,data,plotflag); 
%
%        S    = a struct containing the total spectral density
%        S1   = a 2D struct array containing the swell and wind generated 
%               part of the spectral density
%        w    = angular frequency (default linspace(0,3,257))
%        data = [Hm0 def]
%               Hm0 = significant wave height (default 7 (m))
%               def = defines the parametrization (default 1)
%                     1 : The most probable spectrum
%                     2,3,...11 : gives 95% Confidence spectra
%    plotflag = 0, do not plot the spectrum (default).
%               1, plot the  spectrum.
%
%  The OH spectrum is a six parameter spectrum, all functions of Hm0.
%  The values of these parameters are determined from a analysis of data
%  obtained in the North Atlantic. The source of the data is the same as
%  that for the development of the Pierson-Moskowitz spectrum, but
%  analysis is carried out on over 800 spectra including those in
%  partially developed seas and those having a bimodal shape. From a
%  statistical analysis of the data, a family of wave spectra consisting
%  of 11 members is generated for a desired sea severity (Hm0) with the
%  coefficient of 0.95. 
%  A significant advantage of using a family of spectra for design  of
%  marine systems is that one of the family members yields the largest
%  response such as motions or wave induced forces for a specified sea
%  severity, while another yields the smallest response with confidence
%  coefficient of 0.95. 
%
% See also  ohspec, jonswap, torsethaugen

% References:
% Ochi, M.K. and Hubble, E.N. (1976)
% 'On six-parameter wave spectra.'
% In proc. 15th Conf. Coastal Engng.,1,pp301-328

% Tested on: matlab 5.2
% History:
% by pab 16.02.2000

monitor=0;

if nargin<3|isempty(plotflag)
  plotflag=0;
end
if nargin<1|isempty(w)
  w=linspace(0,3,257).';
end
sdata2=[7 1]; % default values
if nargin<2|isempty(sdata)
else
 ns1=length(sdata);
 k=find(~isnan(sdata(1:min(ns1,2))));
 if any(k)
   sdata2(k)=sdata(k);
 end
end %


Hm0=sdata2(1);
def=sdata2(2);


switch def, % 95% Confidence spectra
  case 2, hp=[0.84 0.54];wa=[.93 1.5]; wb=[0.056 0.046];Li=[3.00 2.77*exp(-0.112*Hm0)];
  case 3, hp=[0.84 0.54];wa=[.41 .88]; wb=[0.016 0.026];Li=[2.55 1.82*exp(-0.089*Hm0)];
  case 4, hp=[0.84 0.54];wa=[.74 1.3]; wb=[0.052 0.039];Li=[2.65 3.90*exp(-0.085*Hm0)];
  case 5, hp=[0.84 0.54];wa=[.62 1.03];wb=[0.039 0.030];Li=[2.60 0.53*exp(-0.069*Hm0)];
  case 6, hp=[0.95 0.31];wa=[.70 1.50];wb=[0.046 0.046];Li=[1.35 2.48*exp(-0.102*Hm0)];
  case 7, hp=[0.65 0.76];wa=[.61 0.94];wb=[0.039 0.036];Li=[4.95 2.48*exp(-0.102*Hm0)];  
  case 8, hp=[0.90 0.44];wa=[.81 1.60];wb=[0.052 0.033];Li=[1.80 2.95*exp(-0.105*Hm0)];  
  case 9, hp=[0.77 0.64];wa=[0.54 .61];wb=[0.039 0.000];Li=[4.50 1.95*exp(-0.082*Hm0)];  
  case 10,hp=[0.73 0.68];wa=[.70 0.99];wb=[0.046 0.039];Li=[6.40 1.78*exp(-0.069*Hm0)];    
  case 11,hp=[0.92 0.39];wa=[.70 1.37];wb=[0.046 0.039];Li=[0.70 1.78*exp(-0.069*Hm0)];     
  otherwise % The most probable spectrum
    def=1;
    hp=[0.84 0.54]; wa= [.7 1.15];wb=[0.046 0.039];  Li=[3 1.54*exp(-0.062*Hm0)];
end
Hm0i=hp*Hm0;
Tpi= 2*pi.*exp(wb*Hm0)./wa;

for ix=1:2,
  S1(ix)=ohspec(w,[Hm0i(ix), Tpi(ix),Li(ix)]);
end
S=S1(1);
S.S=S1(1).S+S1(2).S;

%S.note=['Ochi-Hubble2, Hm0 = ' num2str(Hm0i)  ', Tp = ' num2str(Tpi) , ' L = ' num2str(Li)];
S.note=['Ochi-Hubble2, Hm0 = ' num2str(Hm0)  ', def = ' num2str(def) ];
if monitor
  disp(['Hm0, Tp      = ' num2str([Hm0i Tpi])])
end

if plotflag
  ih=ishold;
  wspecplot(S,plotflag)
  hold on
  wspecplot(S1,plotflag,'k--')
  if ~ih,hold off,end
end
