--backup
select * into public._backup_bio_observation from public.bio_observation;
select * into public._backup_monitoring_object from public.monitoring_object;
select * into public._backup_monitored_compartiment from public.monitored_compartiment;
select * into public._backup_observed_property_type from public.observed_property_type;
select * into public._backup_observation from public.observation;
select * into public._backup_observing_capability from public.observing_capability;
select * into public._backup_observing_capability_observation from public.observing_capability_observation;
select * into public._backup_observing_capability_sample from public.observing_capability_sample;
select * into public._backup_sampling_proces from public.sampling_proces;
select * into public._backup_sample from public.sample;

--te verwijderen data inventariseren
select * into public._teverwijderen from (
	select distinct oc.osc_id, oco.obs_id, obs.mno_id, obs.observed_property_type
	from observing_capability_observation oco 
	join observing_capability oc on oc.osc_id=oco.osc_id 
	join observation obs on obs.obs_id=oco.obs_id
	where oc.name like 'RIACON%'
	) q;

--schonen RIACON-data in public-tabellen
delete from public.bio_observation where obs_id in (select obs_id from public._teverwijderen);
delete from public.observing_capability_observation where obs_id in (select obs_id from public._teverwijderen);
delete from public.observation where obs_id in (select obs_id from public._teverwijderen) or mno_id in (select mno_id from public._teverwijderen);
delete from public.monitored_compartiment where mno_id in (select mno_id from public._teverwijderen);
delete from public.observed_property_type where opt_id in (select distinct observed_property_type from public._teverwijderen)
 	and opt_id not in (select distinct observed_property_type from public.observation);
delete from public.observing_capability_sample where osc_id in (select osc_id from public._teverwijderen);
delete from public.observing_capability where osc_id in (select osc_id from public._teverwijderen);
delete from public.sample where smpl_id in (select mno_id from public._teverwijderen);
delete from public.monitoring_object where mno_id in (select mno_id from public._teverwijderen);
-- sampling_proces: overgeslagen (niet herleidbaar)

drop table public._teverwijderen;
