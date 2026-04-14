%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision$
%$Date$
%$Author$
%$Id$
%$HeadURL$
%
%Check computational time
%
%INPUT:
%   -simdef: structure, path to dia file, path to simulation folder
%
%OUTPUT:
%   -sim_efficiency = simulation time / (clock time * # processes)
%
%E.G.:

function [tim_dur,t0,tf,processes,tim_sim,sim_efficiency,num_dt,timervals,timloop_sim]=D3D_computation_time(simdef,varargin)
   OPT.timernames = [];
   OPT.display = false;
   OPT = setproperty(OPT,varargin{:});
   
   [fpath_dia,structure]=D3D_simdef_2_dia(simdef);
   
   switch structure
      case 1
         [tim_dur,t0,tf,processes,tim_sim,num_dt,timervals,timloop_sim]=D3D_computation_time_D3D4(fpath_dia,OPT.timernames);
      case 2
         [tim_dur,t0,tf,processes,tim_sim,num_dt,timervals,timloop_sim]=D3D_computation_time_FM(fpath_dia,OPT.timernames);
   end
   
   sim_efficiency=tim_sim./(tim_dur*processes);
   
   %% display

   if OPT.display
      fprintf('Computation time: %s\n',string(tim_dur));
      fprintf('Start time: %s\n',string(t0));
      fprintf('End time: %s\n',string(tf));
      fprintf('Number of processes: %d\n',processes);
      fprintf('Simulated time: %s\n',string(tim_sim));
      fprintf('Time in timeloop: %s\n',string(timloop_sim));
      fprintf('Number of time steps: %d\n',num_dt);
      fprintf('Average time step: %f s\n',seconds(tim_sim/num_dt));
      for ii=1:length(OPT.timernames)
         fprintf('Timer %s: %f s, %4.2f %%\n',OPT.timernames{ii},timervals(ii),timervals(ii)/seconds(tim_dur)*100);
      end
   end

end %function

%%
%% FUNCTIONS
%%

function [tim_dur,t0,tf,processes,tim_sim,num_dt,timervals,timloop_sim]=D3D_computation_time_D3D4(fpath_dia,timernames)
   timervals=[];
   if ~exist('timernames','var') || isempty(timernames)
      timernames=[];
   end
   
   %t0
   % ***           date,time  : 2022-07-27, 16:41:07
   [kl_s,fline]=D3D_search_dia(fpath_dia,'***           date,time  :',1);
   if isnan(kl_s)
      error('No start time found in simulation: %s',fpath_dia)
   end
   if numel(kl_s)>1
      messageOut(NaN,sprintf('Simulation run more than once. Last one is considered: %s',fpath_dia));
      kl_s=kl_s(end);
   end
   tok=regexp(fline{end},'***           date,time  : (\d{4})-(\d{2})-(\d{2}), (\d{2}):(\d{2}):(\d{2})','tokens');
   tok_num=str2double(tok{1,1});
   t0=datetime(tok_num(1),tok_num(2),tok_num(3),tok_num(4),tok_num(5),tok_num(6));
   
   %number of time steps
   [kl_g,fline]=D3D_search_dia(fpath_dia,'|   TimeSteps   :',kl_s);
   if isnan(kl_g)
      error('No time steps found in simulation: %s',fpath_dia)
   end
   tok=regexp(fline{end},'|   TimeSteps   :\s*(\d*)','tokens');
   num_dt=str2double(tok{1,1})*2; % model reports number of whole timesteps, but all calcs are perofrmed twice
   
   %tf
   [kl_g,fline]=D3D_search_dia(fpath_dia,'***             date, time :',kl_s); %attention, different number of spaces than t0
   if isnan(kl_g)
      error('I could not find the end time')
   end
   if numel(kl_g)>1
      error('After the last start time there are more than one stop time. Something is not correct.')
   end
   tok=regexp(fline{end},'***             date, time : (\d{4})-(\d{2})-(\d{2}), (\d{2}):(\d{2}):(\d{2})','tokens');
   tok_num=str2double(tok{1,1});
   tf=datetime(tok_num(1),tok_num(2),tok_num(3),tok_num(4),tok_num(5),tok_num(6));
   
   %duration
   tim_dur=tf-t0;
   
   %simulated time
   tim_sim=NaT-NaT;
   
   %time in timeloop
   timloop_sim=NaT-NaT;

   %processes
   processes=NaN; %check where it is
   
   %extra timers
   for ii=1:length(timernames)
      [kl_s,fline]=D3D_search_dia(fpath_dia,['|' timernames{ii}],1);
      if isnan(kl_s)
         timervals(ii,:) = zeros(1,1);
         continue
      end
      tok=regexp(fline{end},['|' timernames{1} '\s*|\s*(\d+\.?\d*)\s*|\s*(\d+\.?\d*)\s*|\s*(\d+\.?\d*)\s*|\s*(\d+\.?\d*)\s*|'],'tokens');
      tok_num=str2double([tok{[2]}]); % wallclock time
      timervals(ii,:) = tok_num;
   end
   
end %function

%%

function [tim_dur,t0,tf,processes,tim_sim,num_dt,timervals,timloop_sim]=D3D_computation_time_FM(fpath_dia,timernames)
   timervals=[];
   if ~exist('timernames','var') || isempty(timernames)
      timernames=[];
   end
   %number of time steps
   % ** INFO   : nr of timesteps        ( )  :            22.0000000000
   % ** INFO   : nr of timesteps        ( )  :          5365.0000000000
   [kl_g,fline]=D3D_search_dia(fpath_dia,'** INFO   : nr of timesteps        ( )  :',1);
   if isnan(kl_g)
      error('No number of time steps found in simulation: %s',fpath_dia)
   end
   % tok=regexp(fline{end},'** INFO   : nr of timesteps        ( )  :\s*(\d*)','tokens'); %I do not know why this is not captured.
   tok=regexp(fline{end},'(\d*)','tokens');
   num_dt=str2double(tok{1,1}{1,1});
   
   % I think it would be better to follow the same approach as for D3D4.
   
   
   % ** INFO   : Computation started  at: 11:28:10, 04-09-2022
   % ** INFO   : Computation finished at: 08:13:17, 05-09-2022
   % ** INFO   :
   % ** INFO   : simulation period      (h)  :            48.0000000000
   % ** INFO   : total time in timeloop (h)  :            20.7510759225
   % ** INFO   : MPI    : yes.         #processes   : 8, my_rank: 0
   % ** INFO   : OpenMP : unavailable.
   
   fid=fopen(fpath_dia,'r');
   kl=0;
   while ~feof(fid)
      fline=fgetl(fid);
      kl=kl+1;
      tok=regexp(fline,'** INFO   : Computation started  at: (\d{2}):(\d{2}):(\d{2}), (\d{2})-(\d{2})-(\d{4})','tokens');
      if ~isempty(tok)
         %t0
         tok_num=str2double(tok{1,1});
         t0=datetime(tok_num(6),tok_num(5),tok_num(4),tok_num(1),tok_num(2),tok_num(3));
         %tf
         fline=fgetl(fid);
         tok=regexp(fline,'** INFO   : Computation finished at: (\d{2}):(\d{2}):(\d{2}), (\d{2})-(\d{2})-(\d{4})','tokens');
         tok_num=str2double(tok{1,1});
         tf=datetime(tok_num(6),tok_num(5),tok_num(4),tok_num(1),tok_num(2),tok_num(3));
         %duration
         tim_dur=tf-t0;
         %simulation period
         for kloop=1:2
            fline=fgetl(fid);
         end
         tok=regexp(fline,'** INFO   : simulation period      \(h\)  :\s*(\d*.\d*)','tokens');
         tim_sim=hours(str2double(tok{1,1}{1,1}));
         %time in timeloop
         fline=fgetl(fid);
         tok=regexp(fline,'** INFO   : total time in timeloop \(h\)  :\s*(\d*.\d*)','tokens');
         timloop_sim=hours(str2double(tok{1,1}{1,1}));
         %MPI 
         fline=fgetl(fid);
         %processes
         tok=regexp(fline,'#processes   : (\d*)','tokens');
         if ~isempty(tok)
            processes=str2double(tok{1,1}{1,1});
         else
            processes=1;
         end
         break
      end
      %             computation finished marker handled above.
   end %while
   
   %timers
% ** INFO   : time inistep           (s)  :          1040.4329617023
% ** INFO   : time setumod           (s)  :           417.5179953575
% ** INFO   : time furu              (s)  :            65.6280305386
% ** INFO   : time solve             (s)  :           936.3839931488
% ** INFO   : time gausselimination  (s)  :            54.5190000003
% ** INFO   : time gausssubstitution (s)  :            12.3190000000
% ** INFO   : time totalsolve        (s)  :           936.9830000001
% ** INFO   : time setexternalforc.  (s)  :             0.0000000000
% ** INFO   : time setext.forc.fetch (s)  :             0.0000000000
% ** INFO   : time setexternalfbnd.  (s)  :             2.9349970818
% ** INFO   : time steps             (s)  :          4715.7439985275
% ** INFO   : time transport         (s)  :            36.9600000000
% ** INFO   : time debug             (s)  :             0.0000000000
% ** INFO   : time erosed            (s)  :          1691.4059999999

   %extra timers
   for ii=1:length(timernames)
      [kl_s,fline]=D3D_search_dia(fpath_dia,['** INFO   : extra timer:' timernames{ii}],1);
      if ~isnan(kl_s)
%       '** INFO   : extra timer:Erosed_call                                        194.0309901237'
         tok=regexp(fline{end},['** INFO   : extra timer:' regexptranslate('escape',timernames{ii}) '\s*([0-9eEdD\+\-\.]*)'],'tokens');
         if ~isempty(tok)
            timervals(ii,:) = str2double(tok{1}{1});
            continue
         end
      end

      % Standard FM timers, e.g.:
      % ** INFO   : time inistep           (s)  :          1040.4329617023
      [kl_s,fline]=D3D_search_dia(fpath_dia,['** INFO   : time ' timernames{ii}],1);
      if isnan(kl_s)
         timervals(ii,:) = zeros(1,1);
         continue
      end

      tok=regexp(fline{end},['\*\* INFO\s*:\s*time\s+' regexptranslate('escape',timernames{ii}) '\s*\(s\)\s*:\s*([0-9eEdD\+\-\.]*)'],'tokens');
      if isempty(tok)
         timervals(ii,:) = zeros(1,1);
         continue
      end

      timervals(ii,:) = str2double(tok{1}{1});
   end
   
   fclose(fid);
   
end %function