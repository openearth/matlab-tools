function MakeDir(dr,varargin)
for i=1:nargin-1
    if ~exist([dr filesep varargin{i}],'dir')
        [status,message,messageid]=mkdir(dr,varargin{i});
    end
    dr=[dr filesep varargin{i}];
end
