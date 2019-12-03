from Libraries.Utils.Project import *

#region tests import
from TestBed.Tests.ReferenceProfileTest import *
#endregion


#Define tests
tests = [ReferenceProfileTest()]

#region Run all tests
for test in tests:
	if isinstance(test,TestBase):
		try:
			PrintMessage("Starting test %s" % (test.name),2)
			test.RunTest()
			PrintMessage("Finished test %s" % (test.name),2)
		except:
			PrintMessage("Error running test %s" (test.name),0)
#endregion