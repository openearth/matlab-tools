 ncfile = 'inspire_new.nc';
xmlfile = 'new.xml';

fid = fopen(xmlfile);xml = fscanf(fid,'%s');fclose(fid);

nc_create_empty(ncfile)
%nc_attput      (ncfile,nc_global,'INSPIRE',xml);

nc.Name      = 'INSPIRE';
nc.Nctype    = 'char';
nc.Dimension = {'dummy'};
nc_adddim(ncfile,'dummy',length(xml));
nc.Attribute(1) = struct('Name', 'Reference'   ,'Value', 'http://www.inspire-geoportal.eu/');
nc.Attribute(2) = struct('Name', 'Editor'      ,'Value', 'http://www.inspire-geoportal.eu/index.cfm/pageid/342');
nc.Attribute(3) = struct('Name', 'Validator'   ,'Value', 'http://www.inspire-geoportal.eu/index.cfm/pageid/48');
nc.Attribute(4) = struct('Name', 'Viewer'      ,'Value', 'http://www.inspire-geoportal.eu/index.cfm/pageid/341');

nc.Attribute(5) = struct('Name', 'created_at'  ,'Value', datestr(now,31));
nc.Attribute(6) = struct('Name', 'created_by'  ,'Value', mfilename);
nc.Attribute(7) = struct('Name', 'created_from','Value', xmlfile);

nc_addvar(ncfile,nc);
nc_varput(ncfile,'INSPIRE',xml);



