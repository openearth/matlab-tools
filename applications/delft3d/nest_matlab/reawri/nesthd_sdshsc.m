      function [conc] =  sdshsc(filename,istat,nfs_inf,l)

      % sdshsc : Get transport data out of an SDS file

%----------------------------------------------------------------------
%     Get the constituent data
%----------------------------------------------------------------------

      sds      = qpfopen (filename);

      conc     = waquaio  (sds,[],['stsubst: ' strtrim(nfs_inf.namcon(l,:))],0,istat);
