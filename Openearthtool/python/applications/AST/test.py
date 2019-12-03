import unittest
import json
import pandas as pd

from ast_python.ast_heatstress import temperature_json, cost_json, waterquality_json
from ast_python.ast_selection import selection_json
from ast_python.ast_pluvflood import pluvflood_json


class TestAST(unittest.TestCase):
    def test_pluvflood(self):
        with open("test/test_pluvflood.json") as f:
            jsonstr = f.read()
        return_time = pluvflood_json(jsonstr)
        self.assertAlmostEqual(return_time["returnTime"], 4.45)

    def test_heatstress_temperature(self):
        with open("test/test_heatstress_temperature.json") as f:
            jsonstr = f.read()
        temp_reduction = temperature_json(jsonstr)
        self.assertAlmostEqual(temp_reduction["tempReduction"], 0.11)

    def test_heatstress_cost(self):
        with open("test/test_heatstress_cost.json") as f:
            jsonstr = f.read()
        res = cost_json(jsonstr)
        self.assertAlmostEqual(res['maintenanceCost'], 15.0)
        self.assertAlmostEqual(res['constructionCost'], 500.0)

    def test_heatstress_waterquality(self):
        with open("test/test_heatstress_waterquality.json") as f:
            jsonstr = f.read()
        res = waterquality_json(
            jsonstr
        )
        self.assertAlmostEqual(res['captureUnit'], 90.0)
        self.assertAlmostEqual(res['settlingUnit'], 93.0)
        self.assertAlmostEqual(res['filteringUnit'], 95.0)

    def test_selection(self):
        with open("test/test_selection.json") as f:
            jsonstr = f.read()
        measures_list = selection_json(jsonstr)
        df = pd.DataFrame(json.loads(measures_list))

        # check top three ranking by their AST_ID
        self.assertEqual(df["ast_id"][0], 72)
        self.assertEqual(df["ast_id"][1], 22)
        self.assertEqual(df["ast_id"][2], 27)


if __name__ == "__main__":
    unittest.main()
