-- Step 12: new "DAW" category, with the 5 biggest DAW publishers and their flagship products.
-- Transfer rules checked against each developer's official pages on 2026-09-24.
-- Steinberg already exists (added in 0011): only its DAWs are added here, no new developer row.

alter table public.plugins drop constraint plugins_category_check;
alter table public.plugins add constraint plugins_category_check check (category in (
  'eq', 'compression', 'channel-strips', 'reverb-delay', 'saturation', 'mastering',
  'guitar-amps', 'microphones', 'synths', 'sample-libraries', 'daw', 'bundles', 'utilities'
));

insert into public.developers
  (name, slug, website, transferable, fee, who_pays, process, typical_delay, restrictions, source_url, last_verified, no_fee)
values
('Ableton', 'ableton', 'https://www.ableton.com', true,
 'Free', null,
 'The seller starts the transfer from their Ableton account ("Transfer ownership" next to the license) and enters the buyer''s email; the buyer accepts it from their own account.',
 'Immediate (self-service)',
 'Educational licenses can only be transferred to an eligible student or teacher. NFR (not-for-resale) licenses can''t be transferred.',
 'https://help.ableton.com/hc/en-us/articles/209771385-Transferring-ownership-of-a-Live-Push-or-Move-license',
 '2026-09-24', true),
('Image-Line', 'image-line', 'https://www.image-line.com', false,
 null, null, null, null,
 'Image-Line''s EULA (section 11) forbids selling, giving away or transferring an FL Studio or plugin license to anyone else; this is tied to its lifetime free updates policy. Sharing a license or account is also forbidden and can get it revoked.',
 'https://support.image-line.com/action/knowledgebase?ans=105',
 '2026-09-24', false),
('Avid', 'avid', 'https://www.avid.com', true,
 'Transfer of Ownership fee (exact amount set by Avid, paid via avid.com/avidlicensing)', null,
 'The original licensee submits a Transfer of Ownership request via avid.com/avidlicensing (or Avid Customer Care), giving up every copy of the software; Avid then reassigns the license to the buyer.',
 null,
 'One-time permanent transfer only. Academic and NFR/evaluation licenses can''t be transferred except where the law requires it. A license already used for an upgrade can''t be transferred separately from the upgraded version. Subscriptions aren''t transferable, only perpetual licenses.',
 'https://www.avid.com/legal/end-user-license-terms-for-avid-software',
 '2026-09-24', false),
('Fender', 'fender', 'https://www.fender.com', null,
 null, null, null, null,
 'Formerly sold as PreSonus Studio One (transferable via my.presonus.com under PreSonus'' own policy). Since the January 2026 rebrand to Fender Studio Pro, Fender''s EULA describes each activation as for the license holder only, and no clear resale/transfer policy has been published yet for the new product. Check with Fender/PreSonus support before buying or selling.',
 null,
 null, false);

insert into public.plugins (developer_id, name, slug, category)
select d.id, p.name, p.slug, 'daw'
from (values
  ('ableton', 'Live 12 Suite', 'live-12-suite'),
  ('ableton', 'Live 12 Standard', 'live-12-standard'),
  ('ableton', 'Live 12 Intro', 'live-12-intro'),
  ('image-line', 'FL Studio Producer Edition', 'fl-studio-producer-edition'),
  ('image-line', 'FL Studio Signature Bundle', 'fl-studio-signature-bundle'),
  ('image-line', 'FL Studio All Plugins Edition', 'fl-studio-all-plugins-edition'),
  ('steinberg', 'Cubase Pro 15', 'cubase-pro-15'),
  ('steinberg', 'Cubase Artist 15', 'cubase-artist-15'),
  ('steinberg', 'Nuendo 15', 'nuendo-15'),
  ('steinberg', 'Dorico Pro 6', 'dorico-pro-6'),
  ('avid', 'Pro Tools Studio (Perpetual)', 'pro-tools-studio-perpetual'),
  ('avid', 'Pro Tools Ultimate (Perpetual)', 'pro-tools-ultimate-perpetual'),
  ('fender', 'Fender Studio Pro 8', 'fender-studio-pro-8')
) as p(dev_slug, name, slug)
join public.developers d on d.slug = p.dev_slug
on conflict (developer_id, slug) do nothing;
