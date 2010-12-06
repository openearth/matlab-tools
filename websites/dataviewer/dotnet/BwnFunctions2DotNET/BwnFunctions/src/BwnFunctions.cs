/*
* MATLAB Compiler: 4.14 (R2010b)
* Date: Mon Dec 06 15:51:15 2010
* Arguments: "-B" "macro_default" "-W"
* "dotnet:BwnFunctions,BwnFunctions,2.0,D:\Projects\1002637 - Building with
* Nature\TempCompile\Interpolate.snk" "-T" "link:lib" "-d" "D:\Projects\1002637 -
* Building with Nature\TempCompile\BwnFunctions\src" "-N" "-w"
* "enable:specified_file_mismatch" "-w" "enable:repeated_file" "-w"
* "enable:switch_ignored" "-w" "enable:missing_lib_sentinel" "-w" "enable:demo_license"
* "-v" "class{BwnFunctions:D:\Projects\1002637 - Building with
* Nature\TempCompile\Initialize.m,D:\Projects\1002637 - Building with
* Nature\TempCompile\InterpolateToLine.m,D:\Projects\1002637 - Building with
* Nature\TempCompile\PlotTimeSeries.m}" "-a"
* "F:\OpenEarthTools\matlab\applications\SuperTrans\data\EPSG.mat" 
*/
using System;
using System.Reflection;
using System.IO;
using MathWorks.MATLAB.NET.Arrays;
using MathWorks.MATLAB.NET.Utility;

#if SHARED
[assembly: System.Reflection.AssemblyKeyFile(@"D:\Projects\1002637 - Building with Nature\TempCompile\Interpolate.snk")]
#endif

namespace BwnFunctions
{
  /// <summary>
  /// The BwnFunctions class provides a CLS compliant, MWArray interface to the
  /// M-functions contained in the files:
  /// <newpara></newpara>
  /// D:\Projects\1002637 - Building with Nature\TempCompile\Initialize.m
  /// <newpara></newpara>
  /// D:\Projects\1002637 - Building with Nature\TempCompile\InterpolateToLine.m
  /// <newpara></newpara>
  /// D:\Projects\1002637 - Building with Nature\TempCompile\PlotTimeSeries.m
  /// <newpara></newpara>
  /// deployprint.m
  /// <newpara></newpara>
  /// printdlg.m
  /// </summary>
  /// <remarks>
  /// @Version 2.0
  /// </remarks>
  public class BwnFunctions : IDisposable
  {
    #region Constructors

    /// <summary internal= "true">
    /// The static constructor instantiates and initializes the MATLAB Compiler Runtime
    /// instance.
    /// </summary>
    static BwnFunctions()
    {
      if (MWMCR.MCRAppInitialized)
      {
        Assembly assembly= Assembly.GetExecutingAssembly();

        string ctfFilePath= assembly.Location;

        int lastDelimiter= ctfFilePath.LastIndexOf(@"\");

        ctfFilePath= ctfFilePath.Remove(lastDelimiter, (ctfFilePath.Length - lastDelimiter));

        string ctfFileName = "BwnFunctions.ctf";

        Stream embeddedCtfStream = null;

        String[] resourceStrings = assembly.GetManifestResourceNames();

        foreach (String name in resourceStrings)
        {
          if (name.Contains(ctfFileName))
          {
            embeddedCtfStream = assembly.GetManifestResourceStream(name);
            break;
          }
        }
        mcr= new MWMCR("",
                       ctfFilePath, embeddedCtfStream, true);
      }
      else
      {
        throw new ApplicationException("MWArray assembly could not be initialized");
      }
    }


    /// <summary>
    /// Constructs a new instance of the BwnFunctions class.
    /// </summary>
    public BwnFunctions()
    {
    }


    #endregion Constructors

    #region Finalize

    /// <summary internal= "true">
    /// Class destructor called by the CLR garbage collector.
    /// </summary>
    ~BwnFunctions()
    {
      Dispose(false);
    }


    /// <summary>
    /// Frees the native resources associated with this object
    /// </summary>
    public void Dispose()
    {
      Dispose(true);

      GC.SuppressFinalize(this);
    }


    /// <summary internal= "true">
    /// Internal dispose function
    /// </summary>
    protected virtual void Dispose(bool disposing)
    {
      if (!disposed)
      {
        disposed= true;

        if (disposing)
        {
          // Free managed resources;
        }

        // Free native resources
      }
    }


    #endregion Finalize

    #region Methods

    /// <summary>
    /// Provides a void output, 0-input MWArrayinterface to the Initialize M-function.
    /// </summary>
    /// <remarks>
    /// </remarks>
    ///
    public void Initialize()
    {
      mcr.EvaluateFunction(0, "Initialize", new MWArray[]{});
    }


    /// <summary>
    /// Provides a void output, 1-input MWArrayinterface to the Initialize M-function.
    /// </summary>
    /// <remarks>
    /// </remarks>
    /// <param name="varargin">Array of MWArrays representing the input arguments 1
    /// through varargin.length</param>
    ///
    public void Initialize(params MWArray[] varargin)
    {
      mcr.EvaluateFunction(0, "Initialize", varargin);
    }


    /// <summary>
    /// Provides the standard 0-input MWArray interface to the Initialize M-function.
    /// </summary>
    /// <remarks>
    /// </remarks>
    /// <param name="numArgsOut">The number of output arguments to return.</param>
    /// <returns>An Array of length "numArgsOut" containing the output
    /// arguments.</returns>
    ///
    public MWArray[] Initialize(int numArgsOut)
    {
      return mcr.EvaluateFunction(numArgsOut, "Initialize", new MWArray[]{});
    }


    /// <summary>
    /// Provides the standard 1-input MWArray interface to the Initialize M-function.
    /// </summary>
    /// <remarks>
    /// </remarks>
    /// <param name="numArgsOut">The number of output arguments to return.</param>
    /// <param name="varargin">Array of MWArrays representing the input arguments 1
    /// through varargin.length</param>
    /// <returns>An Array of length "numArgsOut" containing the output
    /// arguments.</returns>
    ///
    public MWArray[] Initialize(int numArgsOut, params MWArray[] varargin)
    {
      return mcr.EvaluateFunction(numArgsOut, "Initialize", varargin);
    }


    /// <summary>
    /// Provides a single output, 0-input MWArrayinterface to the InterpolateToLine
    /// M-function.
    /// </summary>
    /// <remarks>
    /// M-Documentation:
    /// specify possible ncVariable names for longitude, latitude
    /// </remarks>
    /// <returns>An MWArray containing the first output argument.</returns>
    ///
    public MWArray InterpolateToLine()
    {
      return mcr.EvaluateFunction("InterpolateToLine", new MWArray[]{});
    }


    /// <summary>
    /// Provides a single output, 1-input MWArrayinterface to the InterpolateToLine
    /// M-function.
    /// </summary>
    /// <remarks>
    /// M-Documentation:
    /// specify possible ncVariable names for longitude, latitude
    /// </remarks>
    /// <param name="ncfile">Input argument #1</param>
    /// <returns>An MWArray containing the first output argument.</returns>
    ///
    public MWArray InterpolateToLine(MWArray ncfile)
    {
      return mcr.EvaluateFunction("InterpolateToLine", ncfile);
    }


    /// <summary>
    /// Provides a single output, 2-input MWArrayinterface to the InterpolateToLine
    /// M-function.
    /// </summary>
    /// <remarks>
    /// M-Documentation:
    /// specify possible ncVariable names for longitude, latitude
    /// </remarks>
    /// <param name="ncfile">Input argument #1</param>
    /// <param name="ncVariable">Input argument #2</param>
    /// <returns>An MWArray containing the first output argument.</returns>
    ///
    public MWArray InterpolateToLine(MWArray ncfile, MWArray ncVariable)
    {
      return mcr.EvaluateFunction("InterpolateToLine", ncfile, ncVariable);
    }


    /// <summary>
    /// Provides a single output, 3-input MWArrayinterface to the InterpolateToLine
    /// M-function.
    /// </summary>
    /// <remarks>
    /// M-Documentation:
    /// specify possible ncVariable names for longitude, latitude
    /// </remarks>
    /// <param name="ncfile">Input argument #1</param>
    /// <param name="ncVariable">Input argument #2</param>
    /// <param name="Centre">Input argument #3</param>
    /// <returns>An MWArray containing the first output argument.</returns>
    ///
    public MWArray InterpolateToLine(MWArray ncfile, MWArray ncVariable, MWArray Centre)
    {
      return mcr.EvaluateFunction("InterpolateToLine", ncfile, ncVariable, Centre);
    }


    /// <summary>
    /// Provides a single output, 4-input MWArrayinterface to the InterpolateToLine
    /// M-function.
    /// </summary>
    /// <remarks>
    /// M-Documentation:
    /// specify possible ncVariable names for longitude, latitude
    /// </remarks>
    /// <param name="ncfile">Input argument #1</param>
    /// <param name="ncVariable">Input argument #2</param>
    /// <param name="Centre">Input argument #3</param>
    /// <param name="Vertex">Input argument #4</param>
    /// <returns>An MWArray containing the first output argument.</returns>
    ///
    public MWArray InterpolateToLine(MWArray ncfile, MWArray ncVariable, MWArray Centre, 
                               MWArray Vertex)
    {
      return mcr.EvaluateFunction("InterpolateToLine", ncfile, ncVariable, Centre, Vertex);
    }


    /// <summary>
    /// Provides a single output, 5-input MWArrayinterface to the InterpolateToLine
    /// M-function.
    /// </summary>
    /// <remarks>
    /// M-Documentation:
    /// specify possible ncVariable names for longitude, latitude
    /// </remarks>
    /// <param name="ncfile">Input argument #1</param>
    /// <param name="ncVariable">Input argument #2</param>
    /// <param name="Centre">Input argument #3</param>
    /// <param name="Vertex">Input argument #4</param>
    /// <param name="varargin">Array of MWArrays representing the input arguments 5
    /// through varargin.length+4</param>
    /// <returns>An MWArray containing the first output argument.</returns>
    ///
    public MWArray InterpolateToLine(MWArray ncfile, MWArray ncVariable, MWArray Centre, 
                               MWArray Vertex, params MWArray[] varargin)
    {
      MWArray[] args = {ncfile, ncVariable, Centre, Vertex};
      int nonVarargInputNum = args.Length;
      int varargInputNum = varargin.Length;
      int totalNumArgs = varargInputNum > 0 ? (nonVarargInputNum + varargInputNum) : nonVarargInputNum;
      Array newArr = Array.CreateInstance(typeof(MWArray), totalNumArgs);

      int idx = 0;

      for (idx = 0; idx < nonVarargInputNum; idx++)
        newArr.SetValue(args[idx],idx);

      if (varargInputNum > 0)
      {
        for (int i = 0; i < varargInputNum; i++)
        {
          newArr.SetValue(varargin[i], idx);
          idx++;
        }
      }

      return mcr.EvaluateFunction("InterpolateToLine", (MWArray[])newArr );
    }


    /// <summary>
    /// Provides the standard 0-input MWArray interface to the InterpolateToLine
    /// M-function.
    /// </summary>
    /// <remarks>
    /// M-Documentation:
    /// specify possible ncVariable names for longitude, latitude
    /// </remarks>
    /// <param name="numArgsOut">The number of output arguments to return.</param>
    /// <returns>An Array of length "numArgsOut" containing the output
    /// arguments.</returns>
    ///
    public MWArray[] InterpolateToLine(int numArgsOut)
    {
      return mcr.EvaluateFunction(numArgsOut, "InterpolateToLine", new MWArray[]{});
    }


    /// <summary>
    /// Provides the standard 1-input MWArray interface to the InterpolateToLine
    /// M-function.
    /// </summary>
    /// <remarks>
    /// M-Documentation:
    /// specify possible ncVariable names for longitude, latitude
    /// </remarks>
    /// <param name="numArgsOut">The number of output arguments to return.</param>
    /// <param name="ncfile">Input argument #1</param>
    /// <returns>An Array of length "numArgsOut" containing the output
    /// arguments.</returns>
    ///
    public MWArray[] InterpolateToLine(int numArgsOut, MWArray ncfile)
    {
      return mcr.EvaluateFunction(numArgsOut, "InterpolateToLine", ncfile);
    }


    /// <summary>
    /// Provides the standard 2-input MWArray interface to the InterpolateToLine
    /// M-function.
    /// </summary>
    /// <remarks>
    /// M-Documentation:
    /// specify possible ncVariable names for longitude, latitude
    /// </remarks>
    /// <param name="numArgsOut">The number of output arguments to return.</param>
    /// <param name="ncfile">Input argument #1</param>
    /// <param name="ncVariable">Input argument #2</param>
    /// <returns>An Array of length "numArgsOut" containing the output
    /// arguments.</returns>
    ///
    public MWArray[] InterpolateToLine(int numArgsOut, MWArray ncfile, MWArray ncVariable)
    {
      return mcr.EvaluateFunction(numArgsOut, "InterpolateToLine", ncfile, ncVariable);
    }


    /// <summary>
    /// Provides the standard 3-input MWArray interface to the InterpolateToLine
    /// M-function.
    /// </summary>
    /// <remarks>
    /// M-Documentation:
    /// specify possible ncVariable names for longitude, latitude
    /// </remarks>
    /// <param name="numArgsOut">The number of output arguments to return.</param>
    /// <param name="ncfile">Input argument #1</param>
    /// <param name="ncVariable">Input argument #2</param>
    /// <param name="Centre">Input argument #3</param>
    /// <returns>An Array of length "numArgsOut" containing the output
    /// arguments.</returns>
    ///
    public MWArray[] InterpolateToLine(int numArgsOut, MWArray ncfile, MWArray 
                                 ncVariable, MWArray Centre)
    {
      return mcr.EvaluateFunction(numArgsOut, "InterpolateToLine", ncfile, ncVariable, Centre);
    }


    /// <summary>
    /// Provides the standard 4-input MWArray interface to the InterpolateToLine
    /// M-function.
    /// </summary>
    /// <remarks>
    /// M-Documentation:
    /// specify possible ncVariable names for longitude, latitude
    /// </remarks>
    /// <param name="numArgsOut">The number of output arguments to return.</param>
    /// <param name="ncfile">Input argument #1</param>
    /// <param name="ncVariable">Input argument #2</param>
    /// <param name="Centre">Input argument #3</param>
    /// <param name="Vertex">Input argument #4</param>
    /// <returns>An Array of length "numArgsOut" containing the output
    /// arguments.</returns>
    ///
    public MWArray[] InterpolateToLine(int numArgsOut, MWArray ncfile, MWArray 
                                 ncVariable, MWArray Centre, MWArray Vertex)
    {
      return mcr.EvaluateFunction(numArgsOut, "InterpolateToLine", ncfile, ncVariable, Centre, Vertex);
    }


    /// <summary>
    /// Provides the standard 5-input MWArray interface to the InterpolateToLine
    /// M-function.
    /// </summary>
    /// <remarks>
    /// M-Documentation:
    /// specify possible ncVariable names for longitude, latitude
    /// </remarks>
    /// <param name="numArgsOut">The number of output arguments to return.</param>
    /// <param name="ncfile">Input argument #1</param>
    /// <param name="ncVariable">Input argument #2</param>
    /// <param name="Centre">Input argument #3</param>
    /// <param name="Vertex">Input argument #4</param>
    /// <param name="varargin">Array of MWArrays representing the input arguments 5
    /// through varargin.length+4</param>
    /// <returns>An Array of length "numArgsOut" containing the output
    /// arguments.</returns>
    ///
    public MWArray[] InterpolateToLine(int numArgsOut, MWArray ncfile, MWArray 
                                 ncVariable, MWArray Centre, MWArray Vertex, params 
                                 MWArray[] varargin)
    {
      MWArray[] args = {ncfile, ncVariable, Centre, Vertex};
      int nonVarargInputNum = args.Length;
      int varargInputNum = varargin.Length;
      int totalNumArgs = varargInputNum > 0 ? (nonVarargInputNum + varargInputNum) : nonVarargInputNum;
      Array newArr = Array.CreateInstance(typeof(MWArray), totalNumArgs);

      int idx = 0;

      for (idx = 0; idx < nonVarargInputNum; idx++)
        newArr.SetValue(args[idx],idx);

      if (varargInputNum > 0)
      {
        for (int i = 0; i < varargInputNum; i++)
        {
          newArr.SetValue(varargin[i], idx);
          idx++;
        }
      }

      return mcr.EvaluateFunction(numArgsOut, "InterpolateToLine", (MWArray[])newArr );
    }


    /// <summary>
    /// Provides an interface for the InterpolateToLine function in which the input and
    /// output
    /// arguments are specified as an array of MWArrays.
    /// </summary>
    /// <remarks>
    /// This method will allocate and return by reference the output argument
    /// array.<newpara></newpara>
    /// M-Documentation:
    /// specify possible ncVariable names for longitude, latitude
    /// </remarks>
    /// <param name="numArgsOut">The number of output arguments to return</param>
    /// <param name= "argsOut">Array of MWArray output arguments</param>
    /// <param name= "argsIn">Array of MWArray input arguments</param>
    ///
    public void InterpolateToLine(int numArgsOut, ref MWArray[] argsOut, MWArray[] argsIn)
    {
      mcr.EvaluateFunction("InterpolateToLine", numArgsOut, ref argsOut, argsIn);
    }


    /// <summary>
    /// Provides a single output, 0-input MWArrayinterface to the PlotTimeSeries
    /// M-function.
    /// </summary>
    /// <remarks>
    /// M-Documentation:
    /// function [output] = PlotTimeSeries(ncfile,ncVariable, startTime, stopTime)
    /// with startTime and stopTime optional time strings:
    /// (ISO 8601)  'yyyymmddTHHMMSS'        20000301T154517
    /// </remarks>
    /// <returns>An MWArray containing the first output argument.</returns>
    ///
    public MWArray PlotTimeSeries()
    {
      return mcr.EvaluateFunction("PlotTimeSeries", new MWArray[]{});
    }


    /// <summary>
    /// Provides a single output, 1-input MWArrayinterface to the PlotTimeSeries
    /// M-function.
    /// </summary>
    /// <remarks>
    /// M-Documentation:
    /// function [output] = PlotTimeSeries(ncfile,ncVariable, startTime, stopTime)
    /// with startTime and stopTime optional time strings:
    /// (ISO 8601)  'yyyymmddTHHMMSS'        20000301T154517
    /// </remarks>
    /// <param name="ncfile">Input argument #1</param>
    /// <returns>An MWArray containing the first output argument.</returns>
    ///
    public MWArray PlotTimeSeries(MWArray ncfile)
    {
      return mcr.EvaluateFunction("PlotTimeSeries", ncfile);
    }


    /// <summary>
    /// Provides a single output, 2-input MWArrayinterface to the PlotTimeSeries
    /// M-function.
    /// </summary>
    /// <remarks>
    /// M-Documentation:
    /// function [output] = PlotTimeSeries(ncfile,ncVariable, startTime, stopTime)
    /// with startTime and stopTime optional time strings:
    /// (ISO 8601)  'yyyymmddTHHMMSS'        20000301T154517
    /// </remarks>
    /// <param name="ncfile">Input argument #1</param>
    /// <param name="ncVariable">Input argument #2</param>
    /// <returns>An MWArray containing the first output argument.</returns>
    ///
    public MWArray PlotTimeSeries(MWArray ncfile, MWArray ncVariable)
    {
      return mcr.EvaluateFunction("PlotTimeSeries", ncfile, ncVariable);
    }


    /// <summary>
    /// Provides a single output, 3-input MWArrayinterface to the PlotTimeSeries
    /// M-function.
    /// </summary>
    /// <remarks>
    /// M-Documentation:
    /// function [output] = PlotTimeSeries(ncfile,ncVariable, startTime, stopTime)
    /// with startTime and stopTime optional time strings:
    /// (ISO 8601)  'yyyymmddTHHMMSS'        20000301T154517
    /// </remarks>
    /// <param name="ncfile">Input argument #1</param>
    /// <param name="ncVariable">Input argument #2</param>
    /// <param name="varargin">Array of MWArrays representing the input arguments 3
    /// through varargin.length+2</param>
    /// <returns>An MWArray containing the first output argument.</returns>
    ///
    public MWArray PlotTimeSeries(MWArray ncfile, MWArray ncVariable, params MWArray[] 
                            varargin)
    {
      MWArray[] args = {ncfile, ncVariable};
      int nonVarargInputNum = args.Length;
      int varargInputNum = varargin.Length;
      int totalNumArgs = varargInputNum > 0 ? (nonVarargInputNum + varargInputNum) : nonVarargInputNum;
      Array newArr = Array.CreateInstance(typeof(MWArray), totalNumArgs);

      int idx = 0;

      for (idx = 0; idx < nonVarargInputNum; idx++)
        newArr.SetValue(args[idx],idx);

      if (varargInputNum > 0)
      {
        for (int i = 0; i < varargInputNum; i++)
        {
          newArr.SetValue(varargin[i], idx);
          idx++;
        }
      }

      return mcr.EvaluateFunction("PlotTimeSeries", (MWArray[])newArr );
    }


    /// <summary>
    /// Provides the standard 0-input MWArray interface to the PlotTimeSeries M-function.
    /// </summary>
    /// <remarks>
    /// M-Documentation:
    /// function [output] = PlotTimeSeries(ncfile,ncVariable, startTime, stopTime)
    /// with startTime and stopTime optional time strings:
    /// (ISO 8601)  'yyyymmddTHHMMSS'        20000301T154517
    /// </remarks>
    /// <param name="numArgsOut">The number of output arguments to return.</param>
    /// <returns>An Array of length "numArgsOut" containing the output
    /// arguments.</returns>
    ///
    public MWArray[] PlotTimeSeries(int numArgsOut)
    {
      return mcr.EvaluateFunction(numArgsOut, "PlotTimeSeries", new MWArray[]{});
    }


    /// <summary>
    /// Provides the standard 1-input MWArray interface to the PlotTimeSeries M-function.
    /// </summary>
    /// <remarks>
    /// M-Documentation:
    /// function [output] = PlotTimeSeries(ncfile,ncVariable, startTime, stopTime)
    /// with startTime and stopTime optional time strings:
    /// (ISO 8601)  'yyyymmddTHHMMSS'        20000301T154517
    /// </remarks>
    /// <param name="numArgsOut">The number of output arguments to return.</param>
    /// <param name="ncfile">Input argument #1</param>
    /// <returns>An Array of length "numArgsOut" containing the output
    /// arguments.</returns>
    ///
    public MWArray[] PlotTimeSeries(int numArgsOut, MWArray ncfile)
    {
      return mcr.EvaluateFunction(numArgsOut, "PlotTimeSeries", ncfile);
    }


    /// <summary>
    /// Provides the standard 2-input MWArray interface to the PlotTimeSeries M-function.
    /// </summary>
    /// <remarks>
    /// M-Documentation:
    /// function [output] = PlotTimeSeries(ncfile,ncVariable, startTime, stopTime)
    /// with startTime and stopTime optional time strings:
    /// (ISO 8601)  'yyyymmddTHHMMSS'        20000301T154517
    /// </remarks>
    /// <param name="numArgsOut">The number of output arguments to return.</param>
    /// <param name="ncfile">Input argument #1</param>
    /// <param name="ncVariable">Input argument #2</param>
    /// <returns>An Array of length "numArgsOut" containing the output
    /// arguments.</returns>
    ///
    public MWArray[] PlotTimeSeries(int numArgsOut, MWArray ncfile, MWArray ncVariable)
    {
      return mcr.EvaluateFunction(numArgsOut, "PlotTimeSeries", ncfile, ncVariable);
    }


    /// <summary>
    /// Provides the standard 3-input MWArray interface to the PlotTimeSeries M-function.
    /// </summary>
    /// <remarks>
    /// M-Documentation:
    /// function [output] = PlotTimeSeries(ncfile,ncVariable, startTime, stopTime)
    /// with startTime and stopTime optional time strings:
    /// (ISO 8601)  'yyyymmddTHHMMSS'        20000301T154517
    /// </remarks>
    /// <param name="numArgsOut">The number of output arguments to return.</param>
    /// <param name="ncfile">Input argument #1</param>
    /// <param name="ncVariable">Input argument #2</param>
    /// <param name="varargin">Array of MWArrays representing the input arguments 3
    /// through varargin.length+2</param>
    /// <returns>An Array of length "numArgsOut" containing the output
    /// arguments.</returns>
    ///
    public MWArray[] PlotTimeSeries(int numArgsOut, MWArray ncfile, MWArray ncVariable, 
                              params MWArray[] varargin)
    {
      MWArray[] args = {ncfile, ncVariable};
      int nonVarargInputNum = args.Length;
      int varargInputNum = varargin.Length;
      int totalNumArgs = varargInputNum > 0 ? (nonVarargInputNum + varargInputNum) : nonVarargInputNum;
      Array newArr = Array.CreateInstance(typeof(MWArray), totalNumArgs);

      int idx = 0;

      for (idx = 0; idx < nonVarargInputNum; idx++)
        newArr.SetValue(args[idx],idx);

      if (varargInputNum > 0)
      {
        for (int i = 0; i < varargInputNum; i++)
        {
          newArr.SetValue(varargin[i], idx);
          idx++;
        }
      }

      return mcr.EvaluateFunction(numArgsOut, "PlotTimeSeries", (MWArray[])newArr );
    }


    /// <summary>
    /// Provides an interface for the PlotTimeSeries function in which the input and
    /// output
    /// arguments are specified as an array of MWArrays.
    /// </summary>
    /// <remarks>
    /// This method will allocate and return by reference the output argument
    /// array.<newpara></newpara>
    /// M-Documentation:
    /// function [output] = PlotTimeSeries(ncfile,ncVariable, startTime, stopTime)
    /// with startTime and stopTime optional time strings:
    /// (ISO 8601)  'yyyymmddTHHMMSS'        20000301T154517
    /// </remarks>
    /// <param name="numArgsOut">The number of output arguments to return</param>
    /// <param name= "argsOut">Array of MWArray output arguments</param>
    /// <param name= "argsIn">Array of MWArray input arguments</param>
    ///
    public void PlotTimeSeries(int numArgsOut, ref MWArray[] argsOut, MWArray[] argsIn)
    {
      mcr.EvaluateFunction("PlotTimeSeries", numArgsOut, ref argsOut, argsIn);
    }


    /// <summary>
    /// This method will cause a MATLAB figure window to behave as a modal dialog box.
    /// The method will not return until all the figure windows associated with this
    /// component have been closed.
    /// </summary>
    /// <remarks>
    /// An application should only call this method when required to keep the
    /// MATLAB figure window from disappearing.  Other techniques, such as calling
    /// Console.ReadLine() from the application should be considered where
    /// possible.</remarks>
    ///
    public void WaitForFiguresToDie()
    {
      mcr.WaitForFiguresToDie();
    }



    #endregion Methods

    #region Class Members

    private static MWMCR mcr= null;

    private bool disposed= false;

    #endregion Class Members
  }
}
