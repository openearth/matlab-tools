model DistributionModel
  import SI = Modelica.SIunits;

  // Boundary conditions
  Deltares.ChannelFlow.SimpleRouting.BoundaryConditions.Inflow IN_Nederrijn;
  Deltares.ChannelFlow.SimpleRouting.BoundaryConditions.Inflow IN_Waal;
  Deltares.ChannelFlow.SimpleRouting.BoundaryConditions.Terminal OUT_Amsterdamrijnkanaal;
  Deltares.ChannelFlow.SimpleRouting.BoundaryConditions.Terminal OUT_Nieuwemaas;
  Deltares.ChannelFlow.SimpleRouting.BoundaryConditions.Terminal OUT_Wiericke;

  // Nodes
  Deltares.ChannelFlow.SimpleRouting.Nodes.Node NO_4040(n_QForcing=0, nin=1, nout=1);
  Deltares.ChannelFlow.SimpleRouting.Nodes.Node NO_4095(n_QForcing=0, nin=2, nout=2);
  Deltares.ChannelFlow.SimpleRouting.Nodes.Node NO_4104(n_QForcing=0, nin=1, nout=2);
  Deltares.ChannelFlow.SimpleRouting.Nodes.Node NO_4124(n_QForcing=0, nin=1, nout=2);
  Deltares.ChannelFlow.SimpleRouting.Nodes.Node NO_6034(n_QForcing=0, nin=1, nout=2);
  Deltares.ChannelFlow.SimpleRouting.Nodes.Node NO_6037(n_QForcing=0, nin=3, nout=1);

  // Branches
  Deltares.ChannelFlow.SimpleRouting.Branches.Integrator DW_AmsterdamrijnkanaalIrenesluizenDoorslag(n_QForcing=0, n_QLateral=0, V(min= 0.0, max=12486010.0, nominal=10000000.0));
  Deltares.ChannelFlow.SimpleRouting.Branches.Integrator DW_Doorslagsluis(n_QForcing=0, n_QLateral=0, V(min= 0.0, max=2795374.0, nominal=900000.0));
  Deltares.ChannelFlow.SimpleRouting.Branches.Integrator DW_Gekanaliseerdehollandseijssel(n_QForcing=0, n_QLateral=0, V(min= 0.0, max=2807999.0, nominal=500000.0));
  Deltares.ChannelFlow.SimpleRouting.Branches.Integrator DW_Gemaalkeulevaart(n_QForcing=0, n_QLateral=0, V(min= 408.0, max=492491.0, nominal=250000.0));
  Deltares.ChannelFlow.SimpleRouting.Branches.Integrator DW_LekAmsterdamrijnkanaalGemaalkoekoek(n_QForcing=0, n_QLateral=0, V(min= 224015.0, max=39862661.0, nominal=10000000.0));
  Deltares.ChannelFlow.SimpleRouting.Branches.Integrator DW_LekGemaalkoekoekKrimpen(n_QForcing=0, n_QLateral=0, V(min= 938438.0, max=82518293.0, nominal=15000000.0));
  Deltares.ChannelFlow.SimpleRouting.Branches.Integrator DW_Wiericke(n_QForcing=0, n_QLateral=2, V(min= 0.0, max=1457044.0, nominal=600000.0));
  Deltares.ChannelFlow.SimpleRouting.Branches.Steady DW_AmsterdamrijnkanaalDoorslag(n_QForcing=0, n_QLateral=0);
  Deltares.ChannelFlow.SimpleRouting.Branches.Steady DW_Hollandseijssel(n_QForcing=0, n_QLateral=0);
  Deltares.ChannelFlow.SimpleRouting.Branches.Steady DW_Nederrijn(n_QForcing=0, n_QLateral=0);
  Deltares.ChannelFlow.SimpleRouting.Branches.Steady DW_NieuwemaasKrimpen(n_QForcing=0, n_QLateral=0);
  Deltares.ChannelFlow.SimpleRouting.Branches.Steady DW_Waal(n_QForcing=0, n_QLateral=0);
  Deltares.ChannelFlow.SimpleRouting.Storage.QSO HV_District43(n_QForcing=1, V(min= 0.0, max=73864.0, nominal=50000.0));
  Deltares.ChannelFlow.SimpleRouting.Storage.QSO HV_District966(n_QForcing=1, V(min= 0.0, max=73864.0, nominal=50000.0));

  // Input. These come either as time series (fixed = true) or from the optimizer (fixed = false), which is the default.
  input SI.VolumeFlowRate DW_Doorslagsluis_QIn(min=0.0, max=12.0);
  input SI.VolumeFlowRate DW_Gekanaliseerdehollandseijssel_QIn(min=-50.0, max=50.0);
  input SI.VolumeFlowRate DW_Gemaalkeulevaart_QIn(min=0.0, max=4.9);
  input SI.VolumeFlowRate DW_LekAmsterdamrijnkanaalGemaalkoekoek_QIn(min=0.0, max=1000.0);
  input SI.VolumeFlowRate HV_District43_QForcing(min=-1000, max=1000);
  input SI.VolumeFlowRate HV_District966_QForcing(min=-1000, max=1000);
  input SI.VolumeFlowRate IN_Nederrijn_Q(fixed=true);
  input SI.VolumeFlowRate IN_Waal_Q(fixed=true);

  // Output
  output SI.Volume DW_AmsterdamrijnkanaalIrenesluizenDoorslag_V;
  output SI.Volume DW_Doorslagsluis_V;
  output SI.Volume DW_Gekanaliseerdehollandseijssel_V;
  output SI.Volume DW_Gemaalkeulevaart_V;
  output SI.Volume DW_LekAmsterdamrijnkanaalGemaalkoekoek_V;
  output SI.Volume DW_LekGemaalkoekoekKrimpen_V;
  output SI.Volume DW_Wiericke_V;
  output SI.Volume HV_District43_V;
  output SI.Volume HV_District966_V;
  output SI.VolumeFlowRate DW_AmsterdamrijnkanaalDoorslag_QIn(min=0.0, max=1000.0);
  output SI.VolumeFlowRate DW_AmsterdamrijnkanaalDoorslag_QOut(min=0.0, max=1000.0);
  output SI.VolumeFlowRate DW_AmsterdamrijnkanaalIrenesluizenDoorslag_QIn(min=0.0, max=60.0);
  output SI.VolumeFlowRate DW_AmsterdamrijnkanaalIrenesluizenDoorslag_QOut(min=0.0, max=60.0);
  output SI.VolumeFlowRate DW_Doorslagsluis_QOut(min=0.0, max=12.0);
  output SI.VolumeFlowRate DW_Gekanaliseerdehollandseijssel_QOut(min=-50.0, max=50.0);
  output SI.VolumeFlowRate DW_Gemaalkeulevaart_QOut(min=0.0, max=4.9);
  output SI.VolumeFlowRate DW_Hollandseijssel_QIn(min=-100.0, max=100.0);
  output SI.VolumeFlowRate DW_Hollandseijssel_QOut(min=-100.0, max=400.0);
  output SI.VolumeFlowRate DW_LekAmsterdamrijnkanaalGemaalkoekoek_QOut(min=0.0, max=1000.0);
  output SI.VolumeFlowRate DW_LekGemaalkoekoekKrimpen_QIn(min=0.0, max=1000.0);
  output SI.VolumeFlowRate DW_LekGemaalkoekoekKrimpen_QOut(min=0.0, max=1000.0);
  output SI.VolumeFlowRate DW_Nederrijn_QIn(min=0.0, max=5000.0);
  output SI.VolumeFlowRate DW_Nederrijn_QOut(min=0.0, max=5000.0);
  output SI.VolumeFlowRate DW_NieuwemaasKrimpen_QIn(min=0.0, max=20000.0);
  output SI.VolumeFlowRate DW_NieuwemaasKrimpen_QOut(min=0.0, max=20000.0);
  output SI.VolumeFlowRate DW_Waal_QIn(min=0.0, max=20000.0);
  output SI.VolumeFlowRate DW_Waal_QOut(min=0.0, max=20000.0);
  output SI.VolumeFlowRate DW_Wiericke_QIn(min=-6.0, max=6.2);
  output SI.VolumeFlowRate DW_Wiericke_QOut;
  output SI.VolumeFlowRate HV_District43_QOut(min=-10.0, max=10.0);
  output SI.VolumeFlowRate HV_District966_QOut(min=-10.0, max=10.0);
  output SI.VolumeFlowRate OUT_Amsterdamrijnkanaal_Q;
  output SI.VolumeFlowRate OUT_Nieuwemaas_Q;
  output SI.VolumeFlowRate OUT_Wiericke_Q;

equation
  // Connectors
  connect(DW_AmsterdamrijnkanaalDoorslag.QOut, OUT_Amsterdamrijnkanaal.QIn) annotation(Line);
  connect(DW_AmsterdamrijnkanaalIrenesluizenDoorslag.QOut, NO_4124.QIn[1]) annotation(Line);
  connect(DW_Doorslagsluis.QOut, NO_4095.QIn[2]) annotation(Line);
  connect(DW_Gekanaliseerdehollandseijssel.QOut, NO_4040.QIn[1]) annotation(Line);
  connect(DW_Gemaalkeulevaart.QOut, NO_4095.QIn[1]) annotation(Line);
  connect(DW_Hollandseijssel.QOut, NO_6037.QIn[2]) annotation(Line);
  connect(DW_LekAmsterdamrijnkanaalGemaalkoekoek.QOut, NO_4104.QIn[1]) annotation(Line);
  connect(DW_LekGemaalkoekoekKrimpen.QOut, NO_6037.QIn[1]) annotation(Line);
  connect(DW_Nederrijn.QOut, NO_6034.QIn[1]) annotation(Line);
  connect(DW_NieuwemaasKrimpen.QOut, OUT_Nieuwemaas.QIn) annotation(Line);
  connect(DW_Waal.QOut, NO_6037.QIn[3]) annotation(Line);
  connect(DW_Wiericke.QOut, OUT_Wiericke.QIn) annotation(Line);
  connect(HV_District43.QOut, DW_Wiericke.QLateral[1]) annotation(Line);
  connect(HV_District966.QOut, DW_Wiericke.QLateral[2]) annotation(Line);
  connect(IN_Nederrijn.QOut, DW_Nederrijn.QIn) annotation(Line);
  connect(IN_Waal.QOut, DW_Waal.QIn) annotation(Line);
  connect(NO_4040.QOut[1], DW_Hollandseijssel.QIn) annotation(Line);
  connect(NO_4095.QOut[1], DW_Gekanaliseerdehollandseijssel.QIn) annotation(Line);
  connect(NO_4095.QOut[2], DW_Wiericke.QIn) annotation(Line);
  connect(NO_4104.QOut[1], DW_Gemaalkeulevaart.QIn) annotation(Line);
  connect(NO_4104.QOut[2], DW_LekGemaalkoekoekKrimpen.QIn) annotation(Line);
  connect(NO_4124.QOut[1], DW_Doorslagsluis.QIn) annotation(Line);
  connect(NO_4124.QOut[2], DW_AmsterdamrijnkanaalDoorslag.QIn) annotation(Line);
  connect(NO_6034.QOut[1], DW_LekAmsterdamrijnkanaalGemaalkoekoek.QIn) annotation(Line);
  connect(NO_6034.QOut[2], DW_AmsterdamrijnkanaalIrenesluizenDoorslag.QIn) annotation(Line);
  connect(NO_6037.QOut[1], DW_NieuwemaasKrimpen.QIn) annotation(Line);

  // Assign inputs
  IN_Nederrijn.Q = IN_Nederrijn_Q;
  IN_Waal.Q = IN_Waal_Q;
  OUT_Amsterdamrijnkanaal.Q = OUT_Amsterdamrijnkanaal_Q;
  OUT_Nieuwemaas.Q = OUT_Nieuwemaas_Q;
  OUT_Wiericke.Q = OUT_Wiericke_Q;

  // Aliasing control variables: discharge
  NO_4095.QOut_control[1] = DW_Gekanaliseerdehollandseijssel_QIn;
  NO_4104.QOut_control[1] = DW_Gemaalkeulevaart_QIn;
  NO_4124.QOut_control[1] = DW_Doorslagsluis_QIn;
  NO_6034.QOut_control[1] = DW_LekAmsterdamrijnkanaalGemaalkoekoek_QIn;

  // Aliasing control variables: forcings
  HV_District43.QForcing[1] = HV_District43_QForcing;
  HV_District966.QForcing[1] = HV_District966_QForcing;

  // Alias outputs for volume
  DW_AmsterdamrijnkanaalIrenesluizenDoorslag.V = DW_AmsterdamrijnkanaalIrenesluizenDoorslag_V;
  DW_Doorslagsluis.V = DW_Doorslagsluis_V;
  DW_Gekanaliseerdehollandseijssel.V = DW_Gekanaliseerdehollandseijssel_V;
  DW_Gemaalkeulevaart.V = DW_Gemaalkeulevaart_V;
  DW_LekAmsterdamrijnkanaalGemaalkoekoek.V = DW_LekAmsterdamrijnkanaalGemaalkoekoek_V;
  DW_LekGemaalkoekoekKrimpen.V = DW_LekGemaalkoekoekKrimpen_V;
  DW_Wiericke.V = DW_Wiericke_V;
  HV_District43.V = HV_District43_V;
  HV_District966.V = HV_District966_V;

  // Alias outputs for discharge
  DW_AmsterdamrijnkanaalDoorslag.QIn.Q = DW_AmsterdamrijnkanaalDoorslag_QIn;
  DW_AmsterdamrijnkanaalDoorslag.QOut.Q = DW_AmsterdamrijnkanaalDoorslag_QOut;
  DW_AmsterdamrijnkanaalIrenesluizenDoorslag.QIn.Q = DW_AmsterdamrijnkanaalIrenesluizenDoorslag_QIn;
  DW_AmsterdamrijnkanaalIrenesluizenDoorslag.QOut.Q = DW_AmsterdamrijnkanaalIrenesluizenDoorslag_QOut;
  DW_Doorslagsluis.QOut.Q = DW_Doorslagsluis_QOut;
  DW_Gekanaliseerdehollandseijssel.QOut.Q = DW_Gekanaliseerdehollandseijssel_QOut;
  DW_Gemaalkeulevaart.QOut.Q = DW_Gemaalkeulevaart_QOut;
  DW_Hollandseijssel.QIn.Q = DW_Hollandseijssel_QIn;
  DW_Hollandseijssel.QOut.Q = DW_Hollandseijssel_QOut;
  DW_LekAmsterdamrijnkanaalGemaalkoekoek.QOut.Q = DW_LekAmsterdamrijnkanaalGemaalkoekoek_QOut;
  DW_LekGemaalkoekoekKrimpen.QIn.Q = DW_LekGemaalkoekoekKrimpen_QIn;
  DW_LekGemaalkoekoekKrimpen.QOut.Q = DW_LekGemaalkoekoekKrimpen_QOut;
  DW_Nederrijn.QIn.Q = DW_Nederrijn_QIn;
  DW_Nederrijn.QOut.Q = DW_Nederrijn_QOut;
  DW_NieuwemaasKrimpen.QIn.Q = DW_NieuwemaasKrimpen_QIn;
  DW_NieuwemaasKrimpen.QOut.Q = DW_NieuwemaasKrimpen_QOut;
  DW_Waal.QIn.Q = DW_Waal_QIn;
  DW_Waal.QOut.Q = DW_Waal_QOut;
  DW_Wiericke.QIn.Q = DW_Wiericke_QIn;
  DW_Wiericke.QOut.Q = DW_Wiericke_QOut;
  HV_District43.QOut.Q = HV_District43_QOut;
  HV_District966.QOut.Q = HV_District966_QOut;

  // Series fixed by equal min/max range
  DW_Wiericke_QOut = 0.0;

end DistributionModel;
