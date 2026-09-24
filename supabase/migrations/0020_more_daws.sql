-- Step 20: complete the DAW category with 3 more major DAWs (REAPER, Bitwig, MOTU Digital
-- Performer) and fix Reason Studios, whose own DAW is transferable even though its Rack
-- Extension add-ons (already in the catalogue) are not. Checked 2026-09-26.

insert into public.developers
  (name, slug, website, transferable, fee, who_pays, process, typical_delay, restrictions, source_url, last_verified, no_fee)
values
('REAPER', 'reaper', 'https://www.reaper.fm', null,
 null, null,
 'Cockos'' EULA does not formally allow resale, but the company has said informally it is OK with a license resold if you ask first.',
 null,
 'No official transfer program: email support@cockos.com or licensing@cockos.com before buying or selling a used REAPER license.',
 'https://www.reaper.fm/dist-agreement.php', '2026-09-26', false),
('Bitwig', 'bitwig', 'https://www.bitwig.com', true,
 null, null,
 'The seller emails Bitwig support asking to transfer the license to the buyer''s account (buyer needs a Bitwig account), giving name, username and country.',
 null,
 'NFR licenses can''t be transferred. EDU and crossgrade licenses can transfer only if the new owner proves eligibility.',
 'https://www.bitwig.com/support/shop_license_activation/can-nfr-edu-crossgrade-licenses-be-transferred-18/', '2026-09-26', false),
('MOTU', 'motu', 'https://motu.com', true,
 null, null,
 'The registered owner contacts MOTU Customer Service to transfer ownership, providing their own and the buyer''s registration details with signed documentation.',
 null,
 'Only the registered owner can request a transfer. A previous version can''t be sold separately once you''ve upgraded past it.',
 'https://motu.com/techsupport/technotes/document.2004-12-21.7308589202', '2026-09-26', false);

update public.developers set
  transferable = true,
  restrictions = 'The Reason DAW license itself can be transferred to another user''s account by giving Reason Studios (or the buyer directly, per their transfer tool) the recipient''s email. Individual Rack Extension add-on licenses (already listed separately) can''t be transferred this way and stay with the original account.',
  source_url = 'https://help.reasonstudios.com/hc/en-us/articles/360002214773-How-does-the-license-number-transfer-process-work',
  last_verified = '2026-09-26'
where slug = 'reason-studios';

insert into public.plugins (developer_id, name, slug, category)
select d.id, p.name, p.slug, 'daw'
from (values
  ('reaper', 'REAPER Discounted License', 'reaper-discounted-license'),
  ('reaper', 'REAPER Commercial License', 'reaper-commercial-license'),
  ('bitwig', 'Bitwig Studio', 'bitwig-studio'),
  ('bitwig', 'Bitwig Studio Producer', 'bitwig-studio-producer'),
  ('bitwig', 'Bitwig Studio Essentials', 'bitwig-studio-essentials'),
  ('motu', 'Digital Performer 12', 'digital-performer-12'),
  ('reason-studios', 'Reason 14', 'reason-14')
) as p(dev_slug, name, slug)
join public.developers d on d.slug = p.dev_slug
on conflict (developer_id, slug) do nothing;
