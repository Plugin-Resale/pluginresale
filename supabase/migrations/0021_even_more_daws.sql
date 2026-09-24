-- Step 21: complete the DAW landscape further — 9 more DAW makers, including some with
-- no transferable license at all (still listed: a developer's rules are useful info even
-- when the answer is "no"). Checked 2026-09-26.

insert into public.developers
  (name, slug, website, transferable, fee, who_pays, process, typical_delay, restrictions, source_url, last_verified, no_fee)
values
('Apple', 'apple', 'https://www.apple.com/logic-pro', false,
 null, null, null, null,
 'Logic Pro is sold only through the Mac App Store, tied to the buyer''s Apple ID; Apple app licenses are non-transferable.',
 'https://www.apple.com/legal/sla/docs/LogicPro.pdf', '2026-09-26', false),
('Adobe', 'adobe', 'https://www.adobe.com/products/audition.html', false,
 null, null, null, null,
 'Adobe Audition is subscription-only (Creative Cloud) — there is no perpetual license to own or transfer.',
 null, '2026-09-26', false),
('Magix', 'magix', 'https://www.magix.com', null,
 null, null,
 'No formal transfer program: some sellers just update the account email/profile to the buyer''s details, but this isn''t an official MAGIX process.',
 null,
 'No clear official transfer policy is published. Ask MAGIX support before buying or selling Samplitude or Sequoia.',
 'https://www.magix.com/int/support/technical-support/pro-audio-support/', null, false),
('Harrison Audio', 'harrison-audio', 'https://harrisonconsoles.com', false,
 null, null, null, null,
 'Harrison has stated on its own forum that there is currently no way to transfer a Mixbus license to another user.',
 'https://forum.harrisonconsoles.com/thread-12375-post-70132.html', '2026-09-26', false),
('Renoise', 'renoise', 'https://www.renoise.com', true,
 null, null,
 'The seller notifies Renoise of the transfer, hands over the complete original software to the buyer and destroys every copy they keep; Renoise then issues the buyer a personalized copy.',
 null, null,
 'https://www.renoise.com/license-agreement', '2026-09-26', true),
('n-Track', 'n-track', 'https://ntrack.com', null,
 null, null, null, null,
 'n-Track doesn''t publish a clear resale/transfer policy. Ask their support before buying or selling.',
 null, null, false),
('Acoustica', 'acoustica', 'https://acoustica.com', false,
 null, null, null, null,
 'Acoustica support has confirmed Mixcraft licenses are not transferable to another person.',
 'https://forums.acoustica.com/viewtopic.php?t=21166', '2026-09-26', false),
('Cakewalk', 'cakewalk', 'https://www.cakewalk.com', false,
 null, null, null, null,
 'Cakewalk Sonar (the BandLab relaunch) runs on a free app plus a paid BandLab Membership subscription, not a resellable perpetual license.',
 'https://help.cakewalk.com/hc/en-us/articles/41129734682393-Cakewalk-Sonar-FAQ', '2026-09-26', false),
('Ardour', 'ardour', 'https://ardour.org', null,
 null, null, null, null,
 'Ardour is free, open-source (GPLv2) software: there is no license to buy or resell, only an optional paid subscription that supports development.',
 'https://ardour.org/faq.html', '2026-09-26', false);

update public.developers set
  transferable = true,
  restrictions = 'Tracktion''s Terms of Use describe licenses as non-transferable, but support has said in practice they will move a license to a new owner''s email if the current owner contacts them first.',
  source_url = 'https://www.tracktion.com/terms-of-use',
  last_verified = '2026-09-26'
where slug = 'tracktion';

insert into public.plugins (developer_id, name, slug, category)
select d.id, p.name, p.slug, 'daw'
from (values
  ('apple', 'Logic Pro', 'logic-pro'),
  ('magix', 'Samplitude Pro X', 'samplitude-pro-x'),
  ('magix', 'Sequoia', 'sequoia'),
  ('harrison-audio', 'Mixbus 11', 'mixbus-11'),
  ('renoise', 'Renoise', 'renoise'),
  ('n-track', 'n-Track Studio', 'n-track-studio'),
  ('acoustica', 'Mixcraft', 'mixcraft'),
  ('tracktion', 'Waveform Pro 14', 'waveform-pro-14')
) as p(dev_slug, name, slug)
join public.developers d on d.slug = p.dev_slug
on conflict (developer_id, slug) do nothing;
