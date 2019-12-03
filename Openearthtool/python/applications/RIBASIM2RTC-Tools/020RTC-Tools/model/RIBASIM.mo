model RIBASIM
  import SI = Modelica.SIunits;

  // Boundary conditions
  Deltares.ChannelFlow.SimpleRouting.BoundaryConditions.Inflow FIXINF_35;
  Deltares.ChannelFlow.SimpleRouting.BoundaryConditions.Inflow VARINF_25;
  Deltares.ChannelFlow.SimpleRouting.BoundaryConditions.Inflow VARINF_5;
  Deltares.ChannelFlow.SimpleRouting.BoundaryConditions.Terminal TERM_20;
  Deltares.ChannelFlow.SimpleRouting.BoundaryConditions.Terminal TERM_90;

  // Nodes
  Deltares.ChannelFlow.SimpleRouting.Nodes.Node CONFL_45(n_QForcing=0, nin=1, nout=1);
  Deltares.ChannelFlow.SimpleRouting.Nodes.Node CONFL_50(n_QForcing=0, nin=2, nout=1);
  Deltares.ChannelFlow.SimpleRouting.Nodes.Node CONFL_55(n_QForcing=0, nin=1, nout=1);
  Deltares.ChannelFlow.SimpleRouting.Nodes.Node CONFL_65(n_QForcing=0, nin=1, nout=1);
  Deltares.ChannelFlow.SimpleRouting.Nodes.Node CONFL_75(n_QForcing=0, nin=2, nout=1);
  Deltares.ChannelFlow.SimpleRouting.Nodes.Node DIV_10(n_QForcing=0, nin=1, nout=2);
  Deltares.ChannelFlow.SimpleRouting.Nodes.Node FIXIRR_30(n_QForcing=1, nin=1, nout=1);
  Deltares.ChannelFlow.SimpleRouting.Nodes.Node FIXIRR_80(n_QForcing=1, nin=1, nout=1);
  Deltares.ChannelFlow.SimpleRouting.Nodes.Node LOWFL_85(n_QForcing=0, nin=1, nout=1);
  Deltares.ChannelFlow.SimpleRouting.Nodes.Node PWS_15(n_QForcing=1, nin=1, nout=1);
  Deltares.ChannelFlow.SimpleRouting.Nodes.Node RUNOFRIV_60(n_QForcing=0, nin=1, nout=1);
  Deltares.ChannelFlow.SimpleRouting.Storage.Storage RSV_40(V(min= 0, max=9.9E+08, nominal=5.5E+08));
  Deltares.ChannelFlow.SimpleRouting.Storage.Storage RSV_70(V(min= 0, max=9.9E+09, nominal=5.5E+09));

  // Branches
  Deltares.ChannelFlow.SimpleRouting.Branches.Steady QDV_15(n_QForcing=0, n_QLateral=0);
  Deltares.ChannelFlow.SimpleRouting.Branches.Steady QSW_10(n_QForcing=0, n_QLateral=0);
  Deltares.ChannelFlow.SimpleRouting.Branches.Steady QSW_20(n_QForcing=0, n_QLateral=0);
  Deltares.ChannelFlow.SimpleRouting.Branches.Steady QSW_25(n_QForcing=0, n_QLateral=0);
  Deltares.ChannelFlow.SimpleRouting.Branches.Steady QSW_30(n_QForcing=0, n_QLateral=0);
  Deltares.ChannelFlow.SimpleRouting.Branches.Steady QSW_35(n_QForcing=0, n_QLateral=0);
  Deltares.ChannelFlow.SimpleRouting.Branches.Steady QSW_40(n_QForcing=0, n_QLateral=0);
  Deltares.ChannelFlow.SimpleRouting.Branches.Steady QSW_45(n_QForcing=0, n_QLateral=0);
  Deltares.ChannelFlow.SimpleRouting.Branches.Steady QSW_5(n_QForcing=0, n_QLateral=0);
  Deltares.ChannelFlow.SimpleRouting.Branches.Steady QSW_50(n_QForcing=0, n_QLateral=0);
  Deltares.ChannelFlow.SimpleRouting.Branches.Steady QSW_55(n_QForcing=0, n_QLateral=0);
  Deltares.ChannelFlow.SimpleRouting.Branches.Steady QSW_60(n_QForcing=0, n_QLateral=0);
  Deltares.ChannelFlow.SimpleRouting.Branches.Steady QSW_65(n_QForcing=0, n_QLateral=0);
  Deltares.ChannelFlow.SimpleRouting.Branches.Steady QSW_70(n_QForcing=0, n_QLateral=0);
  Deltares.ChannelFlow.SimpleRouting.Branches.Steady QSW_75(n_QForcing=0, n_QLateral=0);
  Deltares.ChannelFlow.SimpleRouting.Branches.Steady QSW_80(n_QForcing=0, n_QLateral=0);
  Deltares.ChannelFlow.SimpleRouting.Branches.Steady QSW_85(n_QForcing=0, n_QLateral=0);

  // Input. These come either as time series (fixed = true) or from the optimizer (fixed = false), which is the default.
  input SI.VolumeFlowRate FIXINF_35_Q(fixed=true);
  input SI.VolumeFlowRate VARINF_25_Q(fixed=true);
  input SI.VolumeFlowRate VARINF_5_Q(fixed=true);

  // Output
  output SI.Volume RSV_40_V;
  output SI.Volume RSV_70_V;
  output SI.VolumeFlowRate QDV_15_QIn(min=0, max=100000);
  output SI.VolumeFlowRate QDV_15_QOut(min=0, max=100000);
  output SI.VolumeFlowRate QSW_10_QIn(min=0, max=100000);
  output SI.VolumeFlowRate QSW_10_QOut(min=0, max=100000);
  output SI.VolumeFlowRate QSW_20_QIn(min=0, max=100000);
  output SI.VolumeFlowRate QSW_20_QOut(min=0, max=100000);
  output SI.VolumeFlowRate QSW_25_QIn(min=0, max=100000);
  output SI.VolumeFlowRate QSW_25_QOut(min=0, max=100000);
  output SI.VolumeFlowRate QSW_30_QIn(min=0, max=100000);
  output SI.VolumeFlowRate QSW_30_QOut(min=0, max=100000);
  output SI.VolumeFlowRate QSW_35_QIn(min=0, max=100000);
  output SI.VolumeFlowRate QSW_35_QOut(min=0, max=100000);
  output SI.VolumeFlowRate QSW_40_QIn(min=0, max=100000);
  output SI.VolumeFlowRate QSW_40_QOut(min=0, max=100000);
  output SI.VolumeFlowRate QSW_45_QIn(min=0, max=100000);
  output SI.VolumeFlowRate QSW_45_QOut(min=0, max=100000);
  output SI.VolumeFlowRate QSW_50_QIn(min=0, max=100000);
  output SI.VolumeFlowRate QSW_50_QOut(min=0, max=100000);
  output SI.VolumeFlowRate QSW_55_QIn(min=0, max=100000);
  output SI.VolumeFlowRate QSW_55_QOut(min=0, max=100000);
  output SI.VolumeFlowRate QSW_5_QIn(min=0, max=100000);
  output SI.VolumeFlowRate QSW_5_QOut(min=0, max=100000);
  output SI.VolumeFlowRate QSW_60_QIn(min=0, max=100000);
  output SI.VolumeFlowRate QSW_60_QOut(min=0, max=100000);
  output SI.VolumeFlowRate QSW_65_QIn(min=0, max=100000);
  output SI.VolumeFlowRate QSW_65_QOut(min=0, max=100000);
  output SI.VolumeFlowRate QSW_70_QIn(min=0, max=100000);
  output SI.VolumeFlowRate QSW_70_QOut(min=0, max=100000);
  output SI.VolumeFlowRate QSW_75_QIn(min=0, max=100000);
  output SI.VolumeFlowRate QSW_75_QOut(min=0, max=100000);
  output SI.VolumeFlowRate QSW_80_QIn(min=0, max=100000);
  output SI.VolumeFlowRate QSW_80_QOut(min=0, max=100000);
  output SI.VolumeFlowRate QSW_85_QIn(min=0, max=100000);
  output SI.VolumeFlowRate QSW_85_QOut(min=0, max=100000);
  output SI.VolumeFlowRate TERM_20_Q;
  output SI.VolumeFlowRate TERM_90_Q;

equation
  // Connectors
  connect(CONFL_45.QOut[1], QSW_45.QIn) annotation(Line);
  connect(CONFL_50.QOut[1], QSW_50.QIn) annotation(Line);
  connect(CONFL_55.QOut[1], QSW_55.QIn) annotation(Line);
  connect(CONFL_65.QOut[1], QSW_65.QIn) annotation(Line);
  connect(CONFL_75.QOut[1], QSW_75.QIn) annotation(Line);
  connect(DIV_10.QOut[1], QSW_10.QIn) annotation(Line);
  connect(DIV_10.QOut[2], QDV_15.QIn) annotation(Line);
  connect(FIXINF_35.QOut, QSW_35.QIn) annotation(Line);
  connect(FIXIRR_30.QOut[1], QSW_30.QIn) annotation(Line);
  connect(FIXIRR_80.QOut[1], QSW_80.QIn) annotation(Line);
  connect(LOWFL_85.QOut[1], QSW_85.QIn) annotation(Line);
  connect(PWS_15.QOut[1], QSW_20.QIn) annotation(Line);
  connect(QDV_15.QOut, PWS_15.QIn[1]) annotation(Line);
  connect(QSW_10.QOut, RSV_40.QIn) annotation(Line);
  connect(QSW_20.QOut, TERM_20.QIn) annotation(Line);
  connect(QSW_25.QOut, FIXIRR_30.QIn[1]) annotation(Line);
  connect(QSW_30.QOut, CONFL_50.QIn[1]) annotation(Line);
  connect(QSW_35.QOut, CONFL_75.QIn[1]) annotation(Line);
  connect(QSW_40.QOut, CONFL_45.QIn[1]) annotation(Line);
  connect(QSW_45.QOut, CONFL_50.QIn[2]) annotation(Line);
  connect(QSW_5.QOut, DIV_10.QIn[1]) annotation(Line);
  connect(QSW_50.QOut, CONFL_55.QIn[1]) annotation(Line);
  connect(QSW_55.QOut, RUNOFRIV_60.QIn[1]) annotation(Line);
  connect(QSW_60.QOut, CONFL_65.QIn[1]) annotation(Line);
  connect(QSW_65.QOut, RSV_70.QIn) annotation(Line);
  connect(QSW_70.QOut, CONFL_75.QIn[2]) annotation(Line);
  connect(QSW_75.QOut, FIXIRR_80.QIn[1]) annotation(Line);
  connect(QSW_80.QOut, LOWFL_85.QIn[1]) annotation(Line);
  connect(QSW_85.QOut, TERM_90.QIn) annotation(Line);
  connect(RSV_40.QOut, QSW_40.QIn) annotation(Line);
  connect(RSV_70.QOut, QSW_70.QIn) annotation(Line);
  connect(RUNOFRIV_60.QOut[1], QSW_60.QIn) annotation(Line);
  connect(VARINF_25.QOut, QSW_25.QIn) annotation(Line);
  connect(VARINF_5.QOut, QSW_5.QIn) annotation(Line);

  // Assign inputs
  FIXINF_35.Q = FIXINF_35_Q;
  TERM_20.Q = TERM_20_Q;
  TERM_90.Q = TERM_90_Q;
  VARINF_25.Q = VARINF_25_Q;
  VARINF_5.Q = VARINF_5_Q;

  // Alias outputs for volume
  RSV_40.V = RSV_40_V;
  RSV_70.V = RSV_70_V;

  // Alias outputs for discharge
  QDV_15.QIn.Q = QDV_15_QIn;
  QDV_15.QOut.Q = QDV_15_QOut;
  QSW_10.QIn.Q = QSW_10_QIn;
  QSW_10.QOut.Q = QSW_10_QOut;
  QSW_20.QIn.Q = QSW_20_QIn;
  QSW_20.QOut.Q = QSW_20_QOut;
  QSW_25.QIn.Q = QSW_25_QIn;
  QSW_25.QOut.Q = QSW_25_QOut;
  QSW_30.QIn.Q = QSW_30_QIn;
  QSW_30.QOut.Q = QSW_30_QOut;
  QSW_35.QIn.Q = QSW_35_QIn;
  QSW_35.QOut.Q = QSW_35_QOut;
  QSW_40.QIn.Q = QSW_40_QIn;
  QSW_40.QOut.Q = QSW_40_QOut;
  QSW_45.QIn.Q = QSW_45_QIn;
  QSW_45.QOut.Q = QSW_45_QOut;
  QSW_5.QIn.Q = QSW_5_QIn;
  QSW_5.QOut.Q = QSW_5_QOut;
  QSW_50.QIn.Q = QSW_50_QIn;
  QSW_50.QOut.Q = QSW_50_QOut;
  QSW_55.QIn.Q = QSW_55_QIn;
  QSW_55.QOut.Q = QSW_55_QOut;
  QSW_60.QIn.Q = QSW_60_QIn;
  QSW_60.QOut.Q = QSW_60_QOut;
  QSW_65.QIn.Q = QSW_65_QIn;
  QSW_65.QOut.Q = QSW_65_QOut;
  QSW_70.QIn.Q = QSW_70_QIn;
  QSW_70.QOut.Q = QSW_70_QOut;
  QSW_75.QIn.Q = QSW_75_QIn;
  QSW_75.QOut.Q = QSW_75_QOut;
  QSW_80.QIn.Q = QSW_80_QIn;
  QSW_80.QOut.Q = QSW_80_QOut;
  QSW_85.QIn.Q = QSW_85_QIn;
  QSW_85.QOut.Q = QSW_85_QOut;

end RIBASIM;
