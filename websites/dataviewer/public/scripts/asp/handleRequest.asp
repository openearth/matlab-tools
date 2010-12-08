<body>
Welcome
<%
response.write(request.form("title"))
response.write("<br> " & request.form("kml"))
%>

<%
dim fs,f
set fs=Server.CreateObject("Scripting.FileSystemObject")
set f=fs.CreateTextFile("D:\temp\web\test.txt",true)
f.WriteLine("Hello World!")
f.Close
set f=nothing
set fs=nothing
%>

</body>