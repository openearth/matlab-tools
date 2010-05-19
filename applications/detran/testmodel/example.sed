[SedimentFileInformation]
   FileCreatedBy    = Delft3D FLOW-GUI, Version: 3.41.06.10958         
   FileCreationDate = Tue May 18 2010, 16:25:26         
   FileVersion      = 02.00                        
[SedimentOverall]
   Cref             =  1.6000000e+003      [kg/m3]  CSoil Reference density for hindered settling calculations
   IopSus           = 0                             If Iopsus = 1: susp. sediment size depends on local flow and wave conditions
[Sediment]
   Name             = #Sediment1#                   Name of sediment fraction
   SedTyp           = sand                          Must be "sand", "mud" or "bedload"
   RhoSol           =  2.6500000e+003      [kg/m3]  Specific density
   SedDia           =  1.4000000e-004      [m]      Median sediment diameter (D50)
   CDryB            =  1.6000000e+003      [kg/m3]  Dry bed density
   IniSedThick      =  5.0000000e+000      [m]      Initial sediment layer thickness at bed (uniform value or filename)
   FacDSS           =  1.0000000e+000      [-]      FacDss * SedDia = Initial suspended sediment diameter. Range [0.6 - 1.0]
[Sediment]
   Name             = #Sediment2#                   Name of sediment fraction
   SedTyp           = sand                          Must be "sand", "mud" or "bedload"
   RhoSol           =  2.6500000e+003      [kg/m3]  Specific density
   SedDia           =  2.0000000e-004      [m]      Median sediment diameter (D50)
   CDryB            =  1.6000000e+003      [kg/m3]  Dry bed density
   IniSedThick      =  5.0000000e+000      [m]      Initial sediment layer thickness at bed (uniform value or filename)
   FacDSS           =  1.0000000e+000      [-]      FacDss * SedDia = Initial suspended sediment diameter. Range [0.6 - 1.0]
