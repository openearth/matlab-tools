-- SELECT * FROM public.object_group_element
-- DELETE FROM public.object_group_element

INSERT INTO public.object_group_element (
ojg_id, obj_id
)
SELECT ojg_id, obj_id FROM object_type
JOIN object_group ON object_group.name = object_type.omschrijving