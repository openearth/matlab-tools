import unittest
from processes.ultimate_question import UltimateQuestion
from pywps.app import WPSRequest
from pywps.response.execute import ExecuteResponse
import uuid


class TestUltimateQuestion(unittest.TestCase):

    def setUp(self):
        self.process = UltimateQuestion()
        self.uuid = uuid.uuid1()
        self.process._set_uuid(self.uuid)
        self.request = WPSRequest()

        # This is how you would fake some inputdata
        # if required. Not used in this test.
        self.request.json = {
            'operation': 'execute',
            'version': '1.0.0',
            'language': 'eng',
            'identifier': self.process.identifier,
            'identifiers': self.process.identifier,
            'store_execute': True,
            'status': True,
            'lineage': True,
            'inputs': {
                'datetime': [{
                    'identifier': 'datetime',
                    'type': 'literal',
                    'data_type': 'dateTime',
                    'data': '2017-04-20T12:00:00',
                    'allowed_values': [{'type': 'anyvalue'}],
                }],
                'date': [{
                    'identifier': 'date',
                    'type': 'literal',
                    'data_type': 'date',
                    'data': '2017-04-20',
                    'allowed_values': [{'type': 'anyvalue'}],
                }],
                'time': [{
                    'identifier': 'time',
                    'type': 'literal',
                    'data_type': 'time',
                    'data': '09:00:00',
                    'allowed_values': [{'type': 'anyvalue'}],
                }],
            },
            'outputs': {},
            'raw': False
        }
        self.response = ExecuteResponse(self.request, self.uuid,
                                        process=self.process)

    def test_bad_http_verb(self):
        self.process._handler(self.request, self.response)
        answer = self.response.outputs["answer"].data
        self.assertEqual(answer, '42')
