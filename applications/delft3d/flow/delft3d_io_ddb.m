function ddb = delft3d_io_ddb(ddbFile)

% read ddb file
[domainA m1A n1A m2A n2A domainB m1B n1B m2B n2B]=textread(ddbFile,'%s%n%n%n%n%s%n%n%n%n','delimiter',' ');


domainNames=unique([domainA;domainB]); % alle voorkomende grids
nameDomain=char(domainNames);

for ii=1:length(domainNames) % laad grid-files    
    [~,~,ext] = fileparts(domainNames{ii});
    if strcmpi(ext,'.mdf')
        mdfData = delft3d_io_mdf('read',[fileparts(ddbFile),filesep,char(domainNames(ii))]);
        grd(ii)=delft3d_io_grd('read',[fileparts(ddbFile),filesep,mdfData.keywords.filcco]);
    else
        grd(ii)=delft3d_io_grd('read',[fileparts(ddbFile),filesep,char(domainNames(ii))]);
    end
end

for dd = 1:length(domainA)
   domainID=find(~cellfun('isempty',regexp(domainA{dd},domainNames)));
   
   ddb(dd).X = grd(domainID).cor.x(n1A(dd):n2A(dd),m1A(dd):m2A(dd));
   ddb(dd).Y = grd(domainID).cor.y(n1A(dd):n2A(dd),m1A(dd):m2A(dd));
end


