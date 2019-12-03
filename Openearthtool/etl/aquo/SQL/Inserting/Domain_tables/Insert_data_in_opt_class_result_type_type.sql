-- select * from opt_class_result_type_type
-- DELETE FROM opt_class_result_type_type

-- select * from dump.bodemchemie limit 1!
-- select * from observation limit 1!
-- select * from observed_property_type limit 1!

INSERT into opt_class_result_type_type (observed_property_type_class_type, result_type_type, last_changed_date)
VALUES 
('Analysis', 'AnalysisResult', NOW()),
('BioObservation', 'MeasureResult', NOW()),
('Characteristic', 'ClassifiedResult', NOW()),
('PhysicalObservation', 'ClassifiedResult', NOW()),
('PhysicalObservation', 'MeasureResult', NOW());