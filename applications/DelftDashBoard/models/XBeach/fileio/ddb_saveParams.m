function ddb_saveParams(handles)

id = 1;
ii = strmatch('XBeach',{handles.Model.name},'exact');

% Go from DDB structure to XBeach structure
ixb = 1;
fieldNamesDDB = fieldnames(handles.Model(ii).Input);
% xbdum = xb_read_input('d:\projects\DDB_xb\SlufterModel\params.txt');

for is = 1:length(fieldNamesDDB)
    % TO DO: If statement so only adjusted / non-default input is saved
    if isnumeric(handles.Model(ii).Input.(fieldNamesDDB{is}))
        xbs.data(ixb).name = fieldNamesDDB{is};
        xbs.data(ixb).value= handles.Model(ii).Input.(fieldNamesDDB{is});
        ixb = ixb + 1;
    elseif ischar(handles.Model(ii).Input.(fieldNamesDDB{is}))
        xbs.data(ixb).name = fieldNamesDDB{is};
        xbs.data(ixb).value= handles.Model(ii).Input.(fieldNamesDDB{is});
        ixb = ixb + 1; 
    elseif isstruct(handles.Model(ii).Input.(fieldNamesDDB{is}))
        xbs.data(ixb).name = fieldNamesDDB{is};
        if strcmp(fieldNamesDDB{is},'zs0file')
            xbs.data(ixb).value.data(1).name = 'time';
            xbs.data(ixb).value.data(1).value= handles.Model(ii).Input.(fieldNamesDDB{is}).time;
            xbs.data(ixb).value.data(2).name = 'tide';
            xbs.data(ixb).value.data(2).value= handles.Model(ii).Input.(fieldNamesDDB{is}).data;
        elseif strcmp(fieldNamesDDB{is},'bcfile')
            xbw = xs_empty();
            wavefnames = fieldnames(handles.Model(ii).Input.(fieldNamesDDB{is}));
            for jf = 1:length(wavefnames)
                xbw = xs_set(xbw, wavefnames{jf},...
                handles.Model(ii).Input.(fieldNamesDDB{is}).(wavefnames{jf}));
            end
            xbw = xs_consolidate(xbw);
            
            % add meta data (file names etc.)
            [fdir fname ext]=fileparts(handles.Model(ii).Input.ParamsFile);
            [Hm0] = xs_get(xbw, 'Hm0');
            filenames{1} = [fdir 'filelist.txt'];
            for jf = 1:length(Hm0)
                filenames{jf+1} = [fdir 'jonswap_' num2str(jf)];
            end            
            xbw = xs_meta(xbw, 'Delft Dashboard', 'waves', filenames);
            xbs.data(ixb).value = xbw;     
        else
            
            disp(fieldNamesDDB{is})
            error()
         end
    end
end
%% CONTINUE HERE AVR
% Replace default values with model input
fieldNames = fieldnames(ddb_xbmi);
for i = 1:size(fieldNames,1)
    handles.Model(handles.activeModel.nr).Input(handles.activeDomain).(fieldNames{i}) = ddb_xbmi.(fieldNames{i});
end



xb_write_params(filename, xbs) % possibly add header to include run description?




% %% general constants
% xb.txt10            = ['--------------------------------'];
% xb.txt20            = [' General Constants'];
% xb.txt30            = ['--------------------------------'];
% xb.rho              = handles.Model(ii).Input(id).rho;
% xb.g                = handles.Model(ii).Input(id).g;
% 
% %% grid input
% xb.txt11            = ['--------------------------------'];
% xb.txt21            = [' Grid Input'];
% xb.txt31            = ['--------------------------------'];
% xb.nx               = handles.Model(ii).Input(id).nx;
% xb.ny               = handles.Model(ii).Input(id).ny;
% xb.xori             = handles.Model(ii).Input(id).xori;
% xb.yori             = handles.Model(ii).Input(id).yori;
% xb.alfa             = handles.Model(ii).Input(id).alfa;
% if ~isempty(handles.Model(ii).Input(id).depfile);
%     xb.depfile      = handles.Model(ii).Input(id).depfile;
% else
%     xb.depfile = ['h.dep'];
%     % make uniform depfile
%     temp = zeros(xb.nax+1,xb.ny+1);
%     temp = handles.Model(ii).Input(id).UniformDepth;
%     save([path,xb.depfile],'temp');
% end
% xb.posdwn           = handles.Model(ii).Input(id).posdwn;
% xb.vardx            = handles.Model(ii).Input(id).vardx;
% if xb.vardx == 0
%     xb.dx           = handles.Model(ii).Input(id).dx;
%     xb.dy           = handles.Model(ii).Input(id).dy;
% else
%     xb.xfile        = handles.Model(ii).Input(id).xfile;
%     xb.yfile        = handles.Model(ii).Input(id).yfile;
% end
% xb.thetamin         = handles.Model(ii).Input(id).thetamin;
% xb.thetamin         = handles.Model(ii).Input(id).thetamax;
% xb.dtheta           = handles.Model(ii).Input(id).dtheta;
% xb.thetanaut        = handles.Model(ii).Input(id).thetanaut;
% 
% %% Time input
% xb.txt12            = ['--------------------------------'];
% xb.txt22            = [' Time Input'];
% xb.txt32            = ['--------------------------------'];
% xb.tstop            = handles.Model(ii).Input(id).tstop;
% 
% %% Numerics input
% xb.txt13            = ['--------------------------------'];
% xb.txt23            = [' Numerics Input'];
% xb.txt33            = ['--------------------------------'];
% xb.CFL              = handles.Model(ii).Input(id).CFL;
% xb.scheme           = handles.Model(ii).Input(id).scheme;
% xb.thetanum         = handles.Model(ii).Input(id).thetanum;
% 
% %% Limiters
% xb.txt14            = ['--------------------------------'];
% xb.txt24            = [' Limiters'];
% xb.txt34            = ['--------------------------------'];
% xb.gammax           = handles.Model(ii).Input(id).gammax;
% xb.hmin             = handles.Model(ii).Input(id).hmin;
% xb.eps              = handles.Model(ii).Input(id).eps;
% xb.umin             = handles.Model(ii).Input(id).umin;
% xb.hwci             = handles.Model(ii).Input(id).hwci;
% 
% %% Boundary numerics
% xb.txt15            = ['--------------------------------'];
% xb.txt25            = [' Boundary Numerics'];
% xb.txt35            = ['--------------------------------'];
% xb.front            = handles.Model(ii).Input(id).front;
% xb.back             = handles.Model(ii).Input(id).back;
% xb.left             = handles.Model(ii).Input(id).left;
% xb.right            = handles.Model(ii).Input(id).right;
% 
% %% Advanced wave boundary options
% xb.txt16            = ['--------------------------------'];
% xb.txt26            = [' Advanced Wave Boundary Options'];
% xb.txt36            = ['--------------------------------'];
% xb.fcutoff          = handles.Model(ii).Input(id).fcutoff;
% xb.sprdthr          = handles.Model(ii).Input(id).sprdthr;
% xb.carspan          = handles.Model(ii).Input(id).carspan;
% xb.nspr             = handles.Model(ii).Input(id).nspr;
% xb.epsi             = handles.Model(ii).Input(id).epsi;
% 
% %% Boundary tide options
% xb.txt16            = ['--------------------------------'];
% xb.txt26            = [' Boundary Tide Options'];
% xb.txt36            = ['--------------------------------'];
% xb.tideloc          = handles.Model(ii).Input(id).tideloc;
% if xb.tideloc == 0
%     xb.zs0          = handles.Model(ii).Input(id).zs0;
% else
%     xb.zs0file      = handles.Model(ii).Input(id).zs0file;
%     xb.tidelen      = handles.Model(ii).Input(id).tidelen;
%     xb.paulrevere   = handles.Model(ii).Input(id).paulrevere;
% end
% 
% %% Wave generating boundaries
% xb.txt17            = ['--------------------------------'];
% xb.txt27            = [' Wave Generating Boundaries'];
% xb.txt37            = ['--------------------------------'];
% xb.taper            = handles.Model(ii).Input(id).taper;
% xb.instat           = handles.Model(ii).Input(id).instat;
% xb.ARC              = handles.Model(ii).Input(id).ARC;
% xb.order            = handles.Model(ii).Input(id).order;
% if xb.instat == 0 || 1 || 2
%     xb.dir0         = handles.Model(ii).Input(id).dir0;
%     xb.Hrms         = handles.Model(ii).Input(id).Hrms;
%     xb.Trep         = handles.Model(ii).Input(id).Trep;
%     xb.m            = handles.Model(ii).Input(id).m;
%     if xb.instat == 0
%         xb.wavint   = handles.Model(ii).Input(id).wavint;
%     elseif xb.instat == 1
%         xb.Tlong    = handles.Model(ii).Input(id).Tlong;    
%     end
% elseif xb.instat == 4 || 5 ||  6
%     xb.bcfile       = handles.Model(ii).Input(id).bcfile;
%     if strcmp('lst',xb.bcfile(end-2:end))==1
%         xb.rt       = handles.Model(ii).Input(id).rt;
%         xb.dtbc     = handles.Model(ii).Input(id).dtbc;
%     end    
%     if xb.instat == 5
%         xb.dthetaS_XB = handles.Model(ii).Input(id).dthetaS_XB;
%     end
% end
% 
% %% Wind options
% xb.txt18            = ['--------------------------------'];
% xb.txt28            = [' Wind Options'];
% xb.txt38            = ['--------------------------------'];
% xb.rhoa             = handles.Model(ii).Input(id).rhoa;
% xb.Cd               = handles.Model(ii).Input(id).Cd;
% xb.windv            = handles.Model(ii).Input(id).windv;
% xb.windth           = handles.Model(ii).Input(id).windth;
% 
% %% Coriolis options
% xb.txt19            = ['--------------------------------'];
% xb.txt29            = [' Coriolis Options'];
% xb.txt39            = ['--------------------------------'];
% xb.lat              = handles.Model(ii).Input(id).lat;
% xb.wearth           = handles.Model(ii).Input(id).wearth;
% 
% %% Wave calculation options
% xb.txt110           = ['--------------------------------'];
% xb.txt210           = [' Wave Calculation Options'];
% xb.txt310           = ['--------------------------------'];
% xb.wci              = handles.Model(ii).Input(id).wci;
% xb.break            = handles.Model(ii).Input(id).break;
% xb.roller           = handles.Model(ii).Input(id).roller;
% xb.beta             = handles.Model(ii).Input(id).beta;
% xb.rfb              = handles.Model(ii).Input(id).rfb;
% xb.gamma            = handles.Model(ii).Input(id).gamma;
% xb.alpha            = handles.Model(ii).Input(id).alpha;
% xb.delta            = handles.Model(ii).Input(id).delta;
% xb.n                = handles.Model(ii).Input(id).n;
% xb.swtable          = handles.Model(ii).Input(id).swtable;
% 
% %% Flow calculation options
% xb.txt111           = ['--------------------------------'];
% xb.txt211           = [' Flow Calculation Options'];
% xb.txt311           = ['--------------------------------'];
% xb.C                = handles.Model(ii).Input(id).C;
% xb.nuh              = handles.Model(ii).Input(id).nuh;
% xb.nuhfac           = handles.Model(ii).Input(id).nuhfac;
% xb.nuhv             = handles.Model(ii).Input(id).nuhv;
% 
% %% Ground Water options
% xb.txt112           = ['--------------------------------'];
% xb.txt212           = [' Ground Water Options'];
% xb.txt312           = ['--------------------------------'];
% xb.gwflow           = handles.Model(ii).Input(id).gwflow;
% xb.kx               = handles.Model(ii).Input(id).kx;
% xb.ky               = handles.Model(ii).Input(id).ky;
% xb.kz               = handles.Model(ii).Input(id).kz;
% xb.aquiferbot       = handles.Model(ii).Input(id).aquiferbot;
% xb.aquiferbotfile   = handles.Model(ii).Input(id).aquiferbotfile;
% xb.dwetlayer        = handles.Model(ii).Input(id).dwetlayer;
% xb.gw0              = handles.Model(ii).Input(id).gw0;
% xb.gw0file          = handles.Model(ii).Input(id).gw0file;
% 
% %% Sediment transport calculation options
% xb.txt113           = ['--------------------------------'];
% xb.txt213           = [' Sediment Transport Calculation Options'];
% xb.txt313           = ['--------------------------------'];
% xb.form             = handles.Model(ii).Input(id).form;
% xb.smax             = handles.Model(ii).Input(id).smax;
% xb.tsfac            = handles.Model(ii).Input(id).tsfac;
% xb.dico             = handles.Model(ii).Input(id).dico;
% xb.Tsmin            = handles.Model(ii).Input(id).Tsmin;
% xb.facua            = handles.Model(ii).Input(id).facua;
% if xb.form == 1
%     xb.z0           = handles.Model(ii).Input(id).z0;
% end
% xb.facsl            = handles.Model(ii).Input(id).facsl;
% xb.ndg              = handles.Model(ii).Input(id).ndg;
% xb.ngd              = handles.Model(ii).Input(id).ngd;
% xb.D50              = handles.Model(ii).Input(id).D50;
% xb.D90              = handles.Model(ii).Input(id).D90;
% xb.sedcal           = handles.Model(ii).Input(id).sedcal;
% xb.rhos             = handles.Model(ii).Input(id).rhos;
% xb.turb             = handles.Model(ii).Input(id).turb;
% 
% %% Morphological calculation options
% xb.txt114           = ['--------------------------------'];
% xb.txt214           = [' Moprhological Calculation Options'];
% xb.txt314           = ['--------------------------------'];
% xb.morfac           = handles.Model(ii).Input(id).morfac;
% xb.morstart         = handles.Model(ii).Input(id).morstart;
% xb.por              = handles.Model(ii).Input(id).por;
% xb.dryslp           = handles.Model(ii).Input(id).dryslp;
% xb.wetslp           = handles.Model(ii).Input(id).wetslp;
% xb.hswitch          = handles.Model(ii).Input(id).hswitch;
% xb.dzmax            = handles.Model(ii).Input(id).dzmax;
% 
% %% Output options
% xb.txt115           = ['--------------------------------'];
% xb.txt215           = [' Output Options'];
% xb.txt315           = ['--------------------------------'];
% xb.tstart           = handles.Model(ii).Input(id).tstart;
% xb.tintg            = handles.Model(ii).Input(id).tintg;
% xb.tintp            = handles.Model(ii).Input(id).tintp;
% xb.tintm            = handles.Model(ii).Input(id).tintm;
% xb.tsglobal         = handles.Model(ii).Input(id).tsglobal;
% xb.tspoints         = handles.Model(ii).Input(id).tspoints;
% xb.tsmean           = handles.Model(ii).Input(id).tsmean;
% 
% xb.nglobalvar       = handles.Model(ii).Input(id).nglobalvar;
% xb.npoints          = handles.Model(ii).Input(id).npoints;
% xb.nrugauge         = handles.Model(ii).Input(id).nrugauge;
% xb.nmeanvar         = handles.Model(ii).Input(id).nmeanvar;
% 
% %%
% Names = fieldnames(xb);
% 
% for i=1:length(Names)
%     p=xb.(Names{i});
%     if ischar(p)
%         Par.(Names{i})={p,0,1};
%     else
%         Par.(Names{i})={p,1,1};
%     end
% end
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% fid=fopen(handles.Model(ii).Input(id).ParamsFile,'w');
% 
% for i=1:length(Names)
%     nm=getfield(Par,Names{i});
%     name=Names{i};
%         %switch(lower(name))
%         %case{'description','depth','depthz','gridx','gridy','gridxz','gridyz','itdate','mmax','nmax','kmax'}
%         % otherwise
%         lname=length(name);
%         p=nm{1};
%         iopt1=nm{2};
%         iopt2=nm{3};
%         n=length(p);
%         if ~isempty(p) && strcmp('txt',name(1:min(length(name),3)))==0
%             if iopt1==0
%                 str=[name repmat(' ',1,13-lname) '= ' p];
%             elseif iopt1==1
%                 fmt=[repmat(' %5i',1,n)];
%                 str=[name repmat(' ',1,13-lname) '= ' num2str(p,fmt) ];
%             else
%                 fmt=[repmat(' %15.7e',1,n)];
%                 str=[name repmat(' ',1,13-lname) '= ' num2str(p,fmt) ];
%             end
%         elseif ~isempty(p) && strcmp('txt',name(1:3))==1
%             str=p;
%         else
%             str=[name repmat(' ',1,13-lname)];
%         end
%         fprintf(fid,'%s\n',str);
%        %end
% end
% fclose(fid);

%ddb_writeBatchFile(runid);
