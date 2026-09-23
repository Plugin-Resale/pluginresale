-- Repairs the euro sign and arrow garbled by a clipboard encoding issue when 0003 was pasted.
update public.developers set
  fee = replace(replace(fee, chr(8218) || chr(199) || chr(168), chr(8364)), chr(8218) || chr(220) || chr(237), chr(8594)),
  process = replace(replace(process, chr(8218) || chr(199) || chr(168), chr(8364)), chr(8218) || chr(220) || chr(237), chr(8594)),
  restrictions = replace(replace(restrictions, chr(8218) || chr(199) || chr(168), chr(8364)), chr(8218) || chr(220) || chr(237), chr(8594));
