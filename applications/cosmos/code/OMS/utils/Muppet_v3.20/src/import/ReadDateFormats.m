function DateFormats=ReadDateFormats;

d3dpath=[getenv('D3D_HOME') '\' getenv('ARCH') '\'];

DateFormats=ReadTextFile([getenv('D3D_HOME') '\' getenv('ARCH') '\muppet\settings\defaults\dateformats.def']);

