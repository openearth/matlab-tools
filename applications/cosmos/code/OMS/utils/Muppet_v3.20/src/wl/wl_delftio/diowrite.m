function diowrite(dsh,varargin)
%DIOWRITE  Write to DelftIO stream.
%        DIOWRITE(dsh,data1,data2,data3,...)
%        where data should be one of the following types
%           float32 (single), int32 (int), or
%           uint8

for i=1:length(varargin)
  dio_core('write',dsh,varargin{i});
end
