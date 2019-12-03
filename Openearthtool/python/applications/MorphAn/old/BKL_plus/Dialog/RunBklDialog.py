from BKL_plus.Dialog.BklPlusDialog import *

def RunDialog(function):
	"""function that runs the selection dialog and executes the correct function"""
	try:
		d = BklPlusDialog()
		d.FunctionToExecute = function
		d.Show()
	except:
		from System.Windows.Forms import MessageBoxIcon as _MessageBoxIcon
		from System.Windows.Forms import MessageBoxButtons as _MessageBoxButtons
		from System.Windows.Forms import MessageBox as _MessageBox
		from System.Windows.Forms import MessageBoxDefaultButton as _MessageBoxDefaultButton

		_MessageBox.Show("Please add a workspace that contains JARKUS data and a Coastal development model with results to your project before running this command!","Important Note",
		_MessageBoxButtons.OK,
		_MessageBoxIcon.Exclamation,
		_MessageBoxDefaultButton.Button1);