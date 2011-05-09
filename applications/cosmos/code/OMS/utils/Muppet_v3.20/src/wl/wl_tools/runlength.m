function Coded=runlength(X,SepCode);
% RUNLENGTH Applies runlength encoding to a vector
%
%        Coded=RUNLENGTH(UnCoded,SepCode)
%
%        Example:
%          X=[2,14,14,14,14,0,0,0,0,6,25,49,23,23,23,0,0,0,0,0,0];
%          C=runlength(X,51)
%          gives
%          C=[2,51,4,14,51,4,0,6,25,49,51,3,23,51,6,0];

% created by:
% 28/10/1999 H.R.A. Jagers, University of Twente, WL | Delft Hydraulics
%            The Netherlands

I=find([1 diff(X) 1]); % find changes in data
Coded=[repmat(NaN,1,size(I,2)-1); X(I(1:end-1)); diff(I)]; % code
RLE1=Coded(3,:)==1; % find runlength one
Coded(3,RLE1)=NaN; % remove runlength one
Coded(1,~RLE1)=SepCode; % add separation code, e.g. 51
Coded=Coded(:)'; % convert to row vector
Coded(isnan(Coded))=[]; % remove NaNs

%decode

%I=find(Coded==SepCode); % find separation codes
%RLE=Coded([I+1;I+2])'; % backup encoding sequences
%Coded([I+1 I+2])=[]; % remove encoding sequences
%X=Coded'; % column vector
%X(:,2)=1; % add default length one
%I=find(X(:,1)==SepCode); % find separation codes
%X(I,:)=RLE; % insert encoding sequences

% or

%I=find(Coded==SepCode); % find separation codes
%X=zeros(1,length(Coded)-3*length(I)+sum(Coded(I+2)));
