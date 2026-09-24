-- Step 15: fill catalogue gaps spotted after the previous passes.
-- 3 missing key developers (Serato, KV331 Audio, Synchro Arts), a deeper catalogue for
-- Spitfire Audio / Vienna Symphonic Library / UVI / ProjectSAM / Toontrack (previously
-- too thin for how big these developers actually are), and a re-checked Output policy.
-- Checked against each developer's official pages on 2026-09-25.

insert into public.developers
  (name, slug, website, transferable, fee, who_pays, process, typical_delay, restrictions, source_url, last_verified, no_fee)
values
('Serato', 'serato', 'https://serato.com', null,
 null, null,
 'Serato support can move an already-registered license code to another account on request.',
 null,
 'No public resale policy is published; Serato''s own terms only cover moving a license between your own computers.',
 'https://serato.com/legal/terms-of-sale', '2026-09-25', false),
('KV331 Audio', 'kv331-audio', 'https://www.kv331audio.com', true,
 '$15 per license', 'Seller',
 'The seller emails KV331 Audio a couple of days ahead of the sale, then uninstalls the software and hands over the license (not the original serial number) to the buyer.',
 null,
 'The license does not become NFR: the buyer can resell it again later.',
 'https://www.kv331audio.com/ReturnRefundPolicy.aspx', '2026-09-25', false),
('Synchro Arts', 'synchro-arts', 'https://www.synchroarts.com', null,
 null, null, null, null,
 'Synchro Arts doesn''t publish a clear resale/transfer policy; iLok-based licenses can in principle move via iLok License Manager. Ask their support before buying or selling.',
 'https://www.synchroarts.com/terms-and-conditions', '2026-09-25', false);

update public.developers set
  transferable = true,
  fee = 'Free',
  who_pays = null,
  process = 'The seller moves the license to the buyer''s Output account; both parties'' billing address must be in the EU or UK.',
  typical_delay = null,
  restrictions = 'Only allowed when both buyer and seller are based in the EU or UK. Arcade is a subscription and can''t be resold. Audio rendered from Output instruments/effects can never be resold as a sample or loop pack.',
  source_url = 'https://output.com/legal/eula',
  last_verified = '2026-09-25',
  no_fee = true
where slug = 'output';

insert into public.plugins (developer_id, name, slug, category)
select d.id, p.name, p.slug, p.category
from (values
  ('serato', 'Serato Studio', 'serato-studio', 'utilities'),
  ('serato', 'Serato Sample', 'serato-sample', 'utilities'),
  ('serato', 'Serato DJ Pro', 'serato-dj-pro', 'utilities'),

  ('kv331-audio', 'SynthMaster 2', 'synthmaster-2', 'synths'),
  ('kv331-audio', 'SynthMaster One', 'synthmaster-one', 'synths'),

  ('synchro-arts', 'VocALign Pro', 'vocalign-pro', 'utilities'),
  ('synchro-arts', 'Revoice Pro', 'revoice-pro', 'utilities'),

  ('spitfire-audio', 'Spitfire Studio Strings Professional', 'spitfire-studio-strings-professional', 'sample-libraries'),
  ('spitfire-audio', 'Spitfire Studio Brass', 'spitfire-studio-brass', 'sample-libraries'),
  ('spitfire-audio', 'Spitfire Chamber Strings Professional', 'spitfire-chamber-strings-professional', 'sample-libraries'),
  ('spitfire-audio', 'Eric Whitacre Choir', 'eric-whitacre-choir', 'sample-libraries'),
  ('spitfire-audio', 'Ólafur Arnalds Evolutions', 'olafur-arnalds-evolutions', 'sample-libraries'),

  ('vienna-symphonic-library', 'Synchron Percussion II', 'synchron-percussion-ii', 'sample-libraries'),
  ('vienna-symphonic-library', 'Synchron Solo Strings', 'synchron-solo-strings', 'sample-libraries'),
  ('vienna-symphonic-library', 'Synchron Chamber Strings', 'synchron-chamber-strings', 'sample-libraries'),

  ('uvi', 'World Suite', 'world-suite', 'sample-libraries'),
  ('uvi', 'Key Suite Acoustic', 'key-suite-acoustic', 'sample-libraries'),
  ('uvi', 'Digital Synsations', 'digital-synsations', 'synths'),

  ('projectsam', 'True Strike 2', 'true-strike-2', 'sample-libraries'),
  ('projectsam', 'Forzo', 'forzo', 'sample-libraries'),

  ('toontrack', 'EZmix 3', 'ezmix-3', 'utilities')
) as p(dev_slug, name, slug, category)
join public.developers d on d.slug = p.dev_slug
on conflict (developer_id, slug) do nothing;
