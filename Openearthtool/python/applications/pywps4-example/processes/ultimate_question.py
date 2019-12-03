from pywps.app import Process
from pywps.inout.outputs import LiteralOutput
from pywps.app.Common import Metadata
from processes.yourownfunctions import deepthought


class UltimateQuestion(Process):
    """Test this process at:
    http://localhost:5000/wps?request=Execute&service=WPS&identifier=ultimate_question&version=1.0.0
    """

    def __init__(self):
        inputs = []
        outputs = [LiteralOutput('answer',
                                 'Answer to Ultimate Question',
                                 data_type='string')]

        super(UltimateQuestion, self).__init__(
            self._handler,
            identifier='ultimate_question',
            version='1.3.3.7',
            title='Answer to the ultimate question',
            abstract='The process gives the answer to the ultimate question\
             of "What is the meaning of life?',
            profile='',
            metadata=[Metadata('Ultimate Question'), Metadata('What is the meaning of life')],
            inputs=inputs,
            outputs=outputs,
            store_supported=False,
            status_supported=False
        )

    def _handler(self, request, response):
        """Only parse input, pass it to other function(s)
        and format the output."""
        # Parse & validate input
        # response.inputs etc

        # Call your own function(s)
        answer = deepthought()

        # Format output
        response.outputs['answer'].data = answer

        return response
