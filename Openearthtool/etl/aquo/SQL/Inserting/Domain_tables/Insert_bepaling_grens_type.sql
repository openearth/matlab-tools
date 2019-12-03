-- SELECT * FROM public.bepaling_grens_type
-- DELETE FROM public.bepaling_grens_type
-- 'bepaling_grens_type_bpg_id_seq'

INSERT INTO public.bepaling_grens_type 
(code, omschrijving, last_changed_date, d_status)
VALUES 
('?','Deze kolom moet symbolen bevatten.
=><≠≤≥
Wordt gebruikt door Aquo-kit-import.
Dus niet html-coderingen als &gt; en ook niet echte omschrijvingen als "groter dan".
   Dit record 0 is dan ook niet nodig; het bestaat alleen om de situatie op te vangen dat de AQ-import geen match vindt op de symbolen.
',NOW(),'Gepubliceerd'),
('>','>',NOW(),'Gepubliceerd'),
('<','<',NOW(),'Gepubliceerd'),
('>=','≥',NOW(),'Gepubliceerd'),
('<=','≤',NOW(),'Gepubliceerd'),
('<>','≠',NOW(),'Gepubliceerd'),
('=','=',NOW(),'Gepubliceerd')