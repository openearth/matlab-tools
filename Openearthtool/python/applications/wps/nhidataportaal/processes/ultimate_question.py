
from pywps.app import Process
from pywps.inout.inputs import ComplexInput, LiteralInput
from pywps.inout.outputs import LiteralOutput, ComplexOutput
from pywps.app.Common import Metadata
from pywps import Format
import logging

logger = logging.getLogger('PYWPS')


class UltimateQuestion(Process):
    def __init__(self):
        inputs = [LiteralInput('input',
                                 'Input to Ultimate Question',
                                 data_type='integer')]
        outputs = [ComplexOutput('answer',
                                 'Answer to Ultimate Question',
                                 supported_formats=[Format("application/json")])]

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
        logger.warning("This should arrive in the PyWPS log.")
        response.outputs['answer'].data = {"a": 42}
        return response
