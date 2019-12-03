/*
"Demo" program for Netica-COM in Managed C++ using VS8

Works with  Netica 3.25 or later  and Microsoft CLR C++ in Visual Studio 2005

It is best to get this example project working first, before writing your own software.
Run the latest version of Netica.exe ("Netica Application"), and then exit, to register it as the COM server
   (which will remain until another version of Netica is run).
Then build this project (Build->Build Solution), and run it (Debug->Start Debugging).
If it reports the probability of Tuberculosis is 0.0104, then 0.09241, .3377, and .05 your Netica
   installation and C++ project appear to all be in good order.

Now you can replace the code below with your own.
Or, to add Netica to a different project:
   From that project, choose Project->Add Reference (the application in the Solution Explorer must be
   selected for this option to appear), then click the "Add New Reference..." button, 
   click the "COM" tab, and finally double-click "Netica 3.25 Object Library" (or similar) 
   from the list, and finally click Okay.

For documentation on Netica's objects and functions:
   Add Netica to your project, as described above.
   Choose View->Object Browser  (or View->Other Windows->Object Browser)  or  click on the Views 
      multi-purpose tool button down-arrow and choose "Object Browser".
   In the left pane of the Object Browser, one of the top level entries will be "Interop.Netica".  
      You can browse that, but it won't be as good as browsing the Netica library directly, 
      because it won't have a description of each function, and it may not even list the functions at all.
      If there is no entry at the top level for the library named simply "Netica" (with the books icon), 
      choose "Edit Custom Component Set..." from the "Browse" menu on the toolbar of the Object Browser 
      (with VS.Net 2003, click on the "Customize..." button at the top of the window, and then the 
      "Add..." button of the dialog box that appears).  Choose the COM tab, select the Netica library from 
      the list, click "Add" or "Select" and then "OK".  Now the books icon for the Netica library should 
      appear, and you can browse it.
   Choose a Netica object in the left pane, then click on a member function or property in the 
      top right pane to view its short description in the bottom pane.
   For more information on it, find its Netica-C equivalent name at the end of its short description, 
      and look up the function in the Netica-C manual or online at http://www.norsys.com/onLineAPIManual/index.html .
   If you are getting the wrong version of Netica's objects, then you need to run the correct version of 
      Netica.exe first, to register its COM definition.
*/

#include "stdafx.h"

using namespace System;
using namespace Netica;

int main (array<String ^> ^args)
{
	try {
		Console::WriteLine ("Welcome to Netica API for Managed C++ !");

		Netica::Application^ app = gcnew Netica::Application;
		app->Visible = true;
		String^ net_file_name = AppDomain::CurrentDomain->BaseDirectory + "..\\ChestClinic.dne";

		Streamer^ file = app->NewStream (net_file_name, nullptr);
		BNet^ net = app->ReadBNet (file, "");
		net->Compile();

		BNode^ TB = net->Node("Tuberculosis");
		double bel = TB->GetBelief ("present");
		Console::WriteLine ("The probability of tuberculosis is " + bel);

		BNode^ XRay = net->Nodes->Item ["XRay"];
		XRay->EnterFinding ("abnormal");
		bel = TB->GetBelief ("present");
		Console::WriteLine ("Given an abnormal X-Ray, the probability of tuberculosis is " + bel);

		net->Node("VisitAsia")->EnterFinding("visit");
		bel = TB->GetBelief ("present");
		Console::WriteLine ("Given abnormal X-Ray and visit to Asia, the probability of TB is " + bel);

		net->Node("Cancer")->EnterFinding("present");
		bel = TB->GetBelief ("present");
		Console::WriteLine ("Given abnormal X-Ray, Asia visit, and lung cancer, the probability of TB is " + bel);

		net->Delete();
		if (!app->UserControl) app->Quit();
	}
	catch (System::Runtime::InteropServices::COMException^ e){
		Console::WriteLine("Netica Demo: Error " + (e->ErrorCode & 0x7FFF) + ": " + e->Message);
	}

	Console::WriteLine ("Press <enter> to quit.");
	Console::ReadLine();

	return 0;
}
