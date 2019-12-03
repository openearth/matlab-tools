import unittest
from processes.yourownfunctions import deepthought


class TestDeepThought(unittest.TestCase):

    def test_bad_http_verb(self):
        answer = deepthought()
        self.assertEqual(answer, 42)
