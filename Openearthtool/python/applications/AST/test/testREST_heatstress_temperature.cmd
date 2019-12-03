curl --insecure -X POST -H "Content-Type: application/json" -d @test_heatstress_temperature.json https://tl-ng045.xtr.deltares.nl/api/heatstress/temperature
curl --insecure -X POST -H "Content-Type: application/json" -d @test_heatstress_temperature.json localhost:5000/api/heatstress/temperature
