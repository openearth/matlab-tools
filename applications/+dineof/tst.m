function OK = tst(varargin)
%TST test for DINEOF
%
%  dineof.tst(<keyword,value>) tst for DINEOF
%
%See als0: DINEOF

OPT.plot = 1;

OPT = setproperty(OPT,varargin);

%% X x T

    nt      = 14;time    = [1:nt];
    nx      = 50;
    x       = linspace(-3,3,nx)';
    z       = peaks(x,0);
    mask    = rand(size(z)) < 1;
 
    for it=1:nt
      noise  = rand(size(z)).*z./100;
      clouds = double(rand(size(z)) < 0.95);
      clouds(clouds==0)=nan;
      data(:,it) =     z.*cos(2.*pi.*it./nt).*clouds + ...
                    abs(z).*cos(pi.*it./nt) + ...
                            noise;
    end
    
    [dataf,eofs] = dineof.run(data, time, mask, 'nev',5,'plot',OPT.plot);
    
    OK(1) = isequal(size(data),size(dataf));clear data

%% 1 x X x T

    nt      = 14;time    = [1:nt];
    nx      = 50;
    x       = linspace(-3,3,nx)';
    z       = peaks(x,0);
    mask    = rand(size(z)) < 1;
 
    for it=1:nt
      noise  = rand(size(z)).*z./100;
      clouds = double(rand(size(z)) < 0.95);
      clouds(clouds==0)=nan;
      data(:,:,it) =     z.*cos(2.*pi.*it./nt).*clouds + ...
                    abs(z).*cos(pi.*it./nt) + ...
                            noise;
    end
    
    [dataf,eofs] = dineof.run(data, time, mask, 'nev',5,'plot',OPT.plot);
    
    OK(2) = isequal(size(data),size(dataf));clear data
    
%% 1 x X x T

    nt      = 14;time    = [1:nt];
    nx      = 50;
    x       = linspace(-3,3,nx);
    z       = peaks(x,0);
    mask    = rand(size(z)) < 1;
 
    for it=1:nt
      noise  = rand(size(z)).*z./100;
      clouds = double(rand(size(z)) < 0.95);
      clouds(clouds==0)=nan;
      data(:,:,it) =     z.*cos(2.*pi.*it./nt).*clouds + ...
                    abs(z).*cos(pi.*it./nt) + ...
                            noise;
    end
    
    [dataf,eofs] = dineof.run(data, time, mask, 'nev',5,'plot',OPT.plot);
    
    OK(3) = isequal(size(data),size(dataf));clear data

%% X x Y x T

    nt      = 14;time    = [1:nt];
    ny      = 20;
    nx      = 21;
   [y,x]    = meshgrid(linspace(-3,3,ny),linspace(-3,3,nx));
    z       = peaks(x,y);
    mask    = rand(size(z)) < 1;
    mask(1:5,1:5) = 0; % land

    for it=1:nt
      noise  = rand(size(z)).*z./100;
      clouds = double(rand(size(z)) < 0.95);
      clouds(clouds==0)=nan;
      data(:,:,it) =     z.*cos(2.*pi.*it./nt).*clouds + ...
                    abs(z).*cos(pi.*it./nt) + ...
                            noise;
    end
    
    [dataf,eofs] = dineof.run(data, time, mask, 'nev',5,'plot',OPT.plot);
    
    OK(4) = isequal(size(data),size(dataf));clear data
    
%%

OK = all(OK);
    