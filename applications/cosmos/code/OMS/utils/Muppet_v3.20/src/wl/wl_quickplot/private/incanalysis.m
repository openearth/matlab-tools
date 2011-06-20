function Vals = incanalysis(D,valtype,q,t1,t2,iclass)
%INCANALYSIS Analyse incremental data.
%    VALS = INCANALYSIS(INCDATA,VALTYPE,QUANT,TIME1,TIME2,CLASS) analyses
%    the selected quantity QUANT of the incremental data stored in INCDATA
%    in one of the following ways indicated by the string VALTYPE:
%
%        min               minimum class number during period TIME1 to TIME2
%        max               maximum class number during period TIME1 to TIME2
%        last              class number at TIME1
%        t_of_min          first time of minimum during period TIME1 to TIME2
%        t_of_max          first time of maximum during period TIME1 to TIME2
%        t_first_dry       first time during period TIME1 to TIME2 at which
%                          the point is dry. Similarly for t_first_wet,
%                          t_last_dry and t_last_wet.
%        t_first_eq_class  first time at which class number equals CLASS
%                          during period TIME1 to TIME2. Similarly for
%                          t_first_ge_class, t_first_gt_class,
%                          t_first_le_class, t_first_lt_class,
%                          t_last_eq_class, t_last_ge_class,
%                          t_last_gt_class, t_last_le_class and
%                          t_last_lt_class.
%        t_dry             total time during period TIME1 to TIME2 at which
%                          the point is dry. Similarly for t_wet.
%        t_eq_class        total time during period TIME1 to TIME2 that
%                          class number equals CLASS. Similarly for
%                          t_ge_class, t_gt_class, t_le_class, t_lt_class.
%
%    TIME2 and ICLASS don't have to be specified for VALTYPE='last'. ICLASS
%    does not have to be specified for VALTYPE='min', 'max', 't_of_min',
%    't_of_max', 't_first_dry', 't_last_dry', 't_first_wet', 't_last_wet',
%    't_dry' and 't_wet'.
%
%    See also FLS.

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
