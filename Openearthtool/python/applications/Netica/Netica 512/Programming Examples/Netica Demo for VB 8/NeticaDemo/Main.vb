
'  "Demo" program for Netica-COM in Visual Basic using VS8

'  Works with  Netica 3.25 or later  and Microsoft Visual Basic in Visual Studio 2005

'  It is best to get this example project working first, before writing your own software.
'  Run the latest version of Netica.exe ("Netica Application"), and then exit, to register it as the COM server
'     (which will remain until another version of Netica is run).
'  Then build this project (Build->Build Solution), and run it (Debug->Start Debugging).
'  If it reports the probability of Tuberculosis is 0.010399.., then 0.09241.., then .337711.. your Netica
'     installation and VB project appear to all be in good order.

'  Now you can replace the code below with your own.
'  Or, to add Netica to a different project:
'     From that project, choose Project->Add Reference, then the "COM" tab, 
'     then double-click  "Netica 3.25 Object Library" (or similar).

'  For documentation on Netica's objects and functions:
'     Add Netica to your project, as described above.
'     Choose View->Object Browser  (or View->Other Windows->Object Browser)  or  click on the Views 
'        multi-purpose tool button down-arrow and choose "Object Browser".
'     In the left pane of the Object Browser, one of the top level entries will be "Interop.Netica".  
'        You can browse that, but it won't be as good as browsing the Netica library directly, 
'        because it won't have a description of each function, and it may not even list the functions at all.
'        If there is no entry at the top level for the library named simply "Netica" (with the books icon), 
'        choose "Edit Custom Component Set..." from the "Browse" menu on the toolbar of the Object Browser 
'        (with VS.Net 2003, click on the "Customize..." button at the top of the pane, and then the "Add..." 
'        button of the dialog box that appears).  Choose the COM tab, select the Netica library from the list, 
'        click "Add" or "Select" and then "OK".  Now the books icon for the Netica library should appear, 
'        and you can browse it.
'     Choose a Netica object in the left hand pane, then click on a member function or property in the 
'        top right pane to view its short description in the bottom pane.
'     For more information on it, find its Netica-C equivalent name at the end of its short description, 
'        and look up the function in the Netica-C manual or online at http://www.norsys.com/onLineAPIManual/index.html .
'     If you are getting the wrong version of Netica's objects, then you need to run the correct version of 
'        Netica.exe first, to register its COM definition.

Module Main

    Sub Main()
        On Error GoTo Failed

        Dim app As Netica.Application
        app = New Netica.Application
        app.Visible = True

        Dim net_file_name As String
        net_file_name = System.AppDomain.CurrentDomain.BaseDirectory() & "..\..\..\ChestClinic.dne"
        Dim net As Netica.BNet
        net = app.ReadBNet(app.NewStream(net_file_name))
        net.Compile()

        Dim TB As Netica.BNode
        TB = net.Node("Tuberculosis")
        Dim belief As Double
        belief = TB.GetBelief("present")
        MsgBox("The probability of tuberculosis is " & belief)

        net.Node("XRay").EnterFinding("abnormal")
        belief = TB.GetBelief("present")
        MsgBox("Given an abnormal X-Ray, the probability of tuberculosis is " & belief)

        net.Node("VisitAsia").EnterFinding("visit")
        belief = TB.GetBelief("present")
        MsgBox("Given abnormal X-Ray and visit to Asia, the probability of tuberculosis is " & belief)

        net.Node("Cancer").EnterFinding("present")
        belief = TB.GetBelief("present")
        MsgBox("Given abnormal X-Ray, Asia visit, and lung cancer, the probability of tuberculosis is " & belief)

        net.Delete()
        If Not app.UserControl Then
            app.Quit()
        End If

        Exit Sub

Failed:

        MsgBox("NeticaDemo: Error " & (Err.Number And &H7FFFS) & ": " & Err.Description)

    End Sub

End Module
