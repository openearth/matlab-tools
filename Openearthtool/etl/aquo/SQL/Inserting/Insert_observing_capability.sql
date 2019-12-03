--SELECT * FROM public.observing_capability
--DELETE FROM public.observing_capability

INSERT INTO public.observing_capability
(name, observing_time_begin, observing_time_end, last_change_time, wkrv_id)
SELECT 
mw."Dataset.naam" as name,
min((mw.begindatum || ' ' || 
(CASE WHEN mw.begintijd is null THEN '00:00:00'
	ELSE mw.begintijd
END))::timestamp) as observing_time_begin,
max(
(CASE WHEN mw.einddatum is null THEN 
	(mw.begindatum || ' ' ||
	(CASE WHEN mw.begintijd is null THEN '00:00:00'
		ELSE mw.begintijd
	END))::timestamp
	ELSE (mw.einddatum || ' ' || 
		(CASE WHEN mw.eindtijd is null THEN '00:00:00'
			ELSE mw.eindtijd
		END))::timestamp
	END)) as observing_time_end,
NOW() as last_change_time,
wk.wkrv_id as wkrv_id
FROM dump2.meetwaarden mw,
wkr_version wk
WHERE wk.wkrv_id = (
SELECT wkrv_id 
FROM wkr_version 
order by begin_lifespan_version desc limit 1!)
AND NOT EXISTS
(SELECT osc.name FROM public.observing_capability osc
WHERE osc.name = mw."Dataset.naam")
GROUP BY mw."Dataset.naam", wk.wkrv_id