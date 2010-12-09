<FORM>
<SCRIPT LANGUAGE="JavaScript" SRC="CalendarPopup.js"></SCRIPT>
<SCRIPT LANGUAGE="JavaScript" ID="js1">
	var cal1 = new CalendarPopup();
</SCRIPT>
Specify period:<br />
<INPUT TYPE="text" NAME="date1" VALUE="start date" SIZE=25 onClick="cal1.select(document.forms[0].date1,'anchor1','MM/dd/yyyy'); return false;" TITLE="cal1.select(document.forms[0].date1,'anchor1','MM/dd/yyyy'); return false;" NAME="anchor1" ID="anchor1">
<br />
<INPUT TYPE="text" NAME="date2" VALUE="stop date" SIZE=25 onClick="cal1.select(document.forms[0].date2,'anchor1','MM/dd/yyyy'); return false;" TITLE="cal1.select(document.forms[0].date2,'anchor1','MM/dd/yyyy'); return false;" NAME="anchor1" ID="anchor1">
</FORM>
