-- SELECT * FROM public.substance_group_element
-- DELETE FROM public.substance_group_element

INSERT INTO public.substance_group_element (
ssge_id, chs_id
)
SELECT ssg_id, chs_id FROM chemische_stof_type
JOIN substance_group ON substance_group.name = chemische_stof_type.naam