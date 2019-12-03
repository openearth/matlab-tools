/*
delete from dump.meetpunten;
delete from dump.meetwaarden;
*/

select "Dataset.naam",count(*) from dump.meetwaarden group by "Dataset.naam";

select oc.name,count(*) aantal
from observation obs
join observing_capability_observation oco on oco.obs_id=obs.obs_id
join observing_capability oc on oc.osc_id=oco.osc_id
join monitoring_object mo on mo.mno_id=obs.mno_id
group by oc.name
;
