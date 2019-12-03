model RIBASIM020
  import SI = Modelica.SIunits;
  extends RIBASIM;
// the reservoir release, to be determined by the optimization.
// the nominal value comes from RIBASIM, Bin2Prt.log, Table 3.6, average flow. min is 0, max is taken from the NetHead flow relation.
  input SI.VolumeFlowRate RSV_3_release(fixed=false, nominal=200, min=0, max=9999);
  input SI.VolumeFlowRate RSV_47_release(fixed = false, nominal=1997.79, min=0, max=9999.0);
  input SI.VolumeFlowRate RSV_565_release(fixed = false, nominal=1526.71, min=0, max=9999.0);
  output SI.VolumeFlowRate LOWFL_1_Q;
// Equations
  equation  
// assign time series to the reservoir node quantity
  RSV_3.Q_release = RSV_3_release; 
  RSV_47.Q_release = RSV_47_release;
  RSV_565.Q_release = RSV_565_release;
  LOWFL_1_Q = LOWFL_1.QIn[1].Q;
end RIBASIM020;
