model RIBASIM020
  extends RIBASIM;
  import SI = Modelica.SIunits;
// time series for control variables
  input SI.VolumeFlowRate RSV_40_release(fixed = false, nominal = 200, min = 0, max = 9999);
  input SI.VolumeFlowRate RSV_70_release(fixed = false, nominal = 200, min = 0, max = 9999);
  input SI.VolumeFlowRate DIV_10_control(fixed = false, nominal = 50, min = 0, max = 999);
  input SI.VolumeFlowRate FIXIRR_30_forcing(fixed = false, nominal = -10, min = -50, max = 0);
  input SI.VolumeFlowRate FIXIRR_80_forcing(fixed = false, nominal = -200, min = -1000, max =0);  
  input SI.VolumeFlowRate PWS_15_forcing(fixed = false, nominal = -2, min = -10, max=0);
  output SI.VolumeFlowRate LOWFL_85_Q;
equation
    RSV_40_release = RSV_40.Q_release;
    RSV_70_release = RSV_70.Q_release;
    DIV_10_control = DIV_10.QOut_control[1];
    LOWFL_85_Q = LOWFL_85.QIn[1].Q;
    FIXIRR_30_forcing = FIXIRR_30.QForcing[1];
    FIXIRR_80_forcing = FIXIRR_80.QForcing[1];  
    PWS_15_forcing = PWS_15.QForcing[1];  
end RIBASIM020;
