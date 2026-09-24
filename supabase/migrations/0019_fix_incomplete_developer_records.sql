-- Step 19: fill in 3 developer records that were left blank (Neural DSP, Three-Body
-- Technology) after their products were added in step 17, and add a missing source for
-- Tokyo Dawn Records' existing "not transferable" rule. Checked 2026-09-26.

update public.developers set
  restrictions = 'Neural DSP has a dedicated support article titled "Can I sell my licenses?" but doesn''t state the policy in an easily-quoted public page. Ask their support before buying or selling.',
  source_url = 'https://support.neuraldsp.com/help/can-i-sell-my-licenses'
where slug = 'neural-dsp';

update public.developers set
  restrictions = 'Three-Body Technology doesn''t publish a clear resale/transfer policy; forum reports describe only a device-deactivation limit (at most 4 times per year), not a transfer process. Ask their support before buying or selling.',
  source_url = 'https://forums.threebodytech.com/viewtopic.php?t=55'
where slug = 'three-body-technology';

update public.developers set
  source_url = 'https://www.tokyodawn.net/tdr-everything-bundle/',
  last_verified = '2026-09-26'
where slug = 'tokyo-dawn-records';

-- Re-categorize ~109 products that landed in the default 'utilities' bucket during
-- the automatic keyword-based categorization in step 18, but are clearly something
-- else (guitar amps, synths, channel strips, etc.) once you know the actual product.

-- -> bundles
update public.plugins set category = 'bundles' where slug = 'uad-ultimate-14' and developer_id = (select id from public.developers where slug = 'universal-audio');

-- -> channel-strips
update public.plugins set category = 'channel-strips' where slug = 'api-summing' and developer_id = (select id from public.developers where slug = 'universal-audio');
update public.plugins set category = 'channel-strips' where slug = 'harrison-32c' and developer_id = (select id from public.developers where slug = 'universal-audio');
update public.plugins set category = 'channel-strips' where slug = 'manley-voxbox' and developer_id = (select id from public.developers where slug = 'universal-audio');
update public.plugins set category = 'channel-strips' where slug = 'neve-1081' and developer_id = (select id from public.developers where slug = 'universal-audio');
update public.plugins set category = 'channel-strips' where slug = 'neve-31102' and developer_id = (select id from public.developers where slug = 'universal-audio');
update public.plugins set category = 'channel-strips' where slug = 'neve-summing' and developer_id = (select id from public.developers where slug = 'universal-audio');
update public.plugins set category = 'channel-strips' where slug = 'trident-a-range' and developer_id = (select id from public.developers where slug = 'universal-audio');
update public.plugins set category = 'channel-strips' where slug = 'ua-bock-167' and developer_id = (select id from public.developers where slug = 'universal-audio');
update public.plugins set category = 'channel-strips' where slug = 'ua-bock-187' and developer_id = (select id from public.developers where slug = 'universal-audio');
update public.plugins set category = 'channel-strips' where slug = 'ua-bock-251' and developer_id = (select id from public.developers where slug = 'universal-audio');
update public.plugins set category = 'channel-strips' where slug = '254e' and developer_id = (select id from public.developers where slug = 'plugin-alliance');
update public.plugins set category = 'channel-strips' where slug = '354e' and developer_id = (select id from public.developers where slug = 'plugin-alliance');
update public.plugins set category = 'channel-strips' where slug = '50-series' and developer_id = (select id from public.developers where slug = 'plugin-alliance');
update public.plugins set category = 'channel-strips' where slug = '69-series' and developer_id = (select id from public.developers where slug = 'plugin-alliance');
update public.plugins set category = 'channel-strips' where slug = '80-series' and developer_id = (select id from public.developers where slug = 'plugin-alliance');
update public.plugins set category = 'channel-strips' where slug = 'hg-2' and developer_id = (select id from public.developers where slug = 'plugin-alliance');
update public.plugins set category = 'channel-strips' where slug = 'hg-2ms' and developer_id = (select id from public.developers where slug = 'plugin-alliance');

-- -> compression
update public.plugins set category = 'compression' where slug = 'dbx-160' and developer_id = (select id from public.developers where slug = 'universal-audio');
update public.plugins set category = 'compression' where slug = 'elysia-mpressor' and developer_id = (select id from public.developers where slug = 'universal-audio');
update public.plugins set category = 'compression' where slug = 'manley-variable-mu' and developer_id = (select id from public.developers where slug = 'universal-audio');
update public.plugins set category = 'compression' where slug = 'oxford-envolution' and developer_id = (select id from public.developers where slug = 'universal-audio');
update public.plugins set category = 'compression' where slug = 'precision-de-esser' and developer_id = (select id from public.developers where slug = 'universal-audio');
update public.plugins set category = 'compression' where slug = 'precision-multiband' and developer_id = (select id from public.developers where slug = 'universal-audio');
update public.plugins set category = 'compression' where slug = 'sonnox-oxford-supresser-ds' and developer_id = (select id from public.developers where slug = 'universal-audio');
update public.plugins set category = 'compression' where slug = 'spl-transient-designer' and developer_id = (select id from public.developers where slug = 'universal-audio');
update public.plugins set category = 'compression' where slug = 'ua-1176-fet' and developer_id = (select id from public.developers where slug = 'universal-audio');
update public.plugins set category = 'compression' where slug = 'uad-la-3a' and developer_id = (select id from public.developers where slug = 'universal-audio');
update public.plugins set category = 'compression' where slug = 'valley-people-dyna-mite' and developer_id = (select id from public.developers where slug = 'universal-audio');
update public.plugins set category = 'compression' where slug = '902-de-esser' and developer_id = (select id from public.developers where slug = 'plugin-alliance');
update public.plugins set category = 'compression' where slug = 'nvelope' and developer_id = (select id from public.developers where slug = 'plugin-alliance');
update public.plugins set category = 'compression' where slug = 'opticom-xla-3' and developer_id = (select id from public.developers where slug = 'plugin-alliance');
update public.plugins set category = 'compression' where slug = 'optomax' and developer_id = (select id from public.developers where slug = 'plugin-alliance');
update public.plugins set category = 'compression' where slug = 'transient-designer-plus' and developer_id = (select id from public.developers where slug = 'plugin-alliance');
update public.plugins set category = 'compression' where slug = 'spl-transient-designer-plus' and developer_id = (select id from public.developers where slug = 'plugin-alliance');
update public.plugins set category = 'compression' where slug = 'xtcomp' and developer_id = (select id from public.developers where slug = 'plugin-alliance');
update public.plugins set category = 'compression' where slug = 'mpressor' and developer_id = (select id from public.developers where slug = 'plugin-alliance');
update public.plugins set category = 'compression' where slug = 'mc77' and developer_id = (select id from public.developers where slug = 'plugin-alliance');
update public.plugins set category = 'compression' where slug = 'mbc' and developer_id = (select id from public.developers where slug = 'plugin-alliance');
update public.plugins set category = 'compression' where slug = 'sbc' and developer_id = (select id from public.developers where slug = 'plugin-alliance');

-- -> eq
update public.plugins set category = 'eq' where slug = 'brainworx-bx-digital3' and developer_id = (select id from public.developers where slug = 'universal-audio');
update public.plugins set category = 'eq' where slug = 'bx-refinement' and developer_id = (select id from public.developers where slug = 'universal-audio');
update public.plugins set category = 'eq' where slug = 'chandler-limited-curve-bender' and developer_id = (select id from public.developers where slug = 'universal-audio');
update public.plugins set category = 'eq' where slug = 'little-labs-ibp' and developer_id = (select id from public.developers where slug = 'universal-audio');
update public.plugins set category = 'eq' where slug = 'little-labs-voice-of-god' and developer_id = (select id from public.developers where slug = 'universal-audio');
update public.plugins set category = 'eq' where slug = 'hg-q' and developer_id = (select id from public.developers where slug = 'plugin-alliance');

-- -> guitar-amps
update public.plugins set category = 'guitar-amps' where slug = 'engl-e646-vs' and developer_id = (select id from public.developers where slug = 'universal-audio');
update public.plugins set category = 'guitar-amps' where slug = 'engl-e765-rt' and developer_id = (select id from public.developers where slug = 'universal-audio');
update public.plugins set category = 'guitar-amps' where slug = 'enigmatic-82-overdrive-special' and developer_id = (select id from public.developers where slug = 'universal-audio');
update public.plugins set category = 'guitar-amps' where slug = 'fender-55-dlx' and developer_id = (select id from public.developers where slug = 'universal-audio');
update public.plugins set category = 'guitar-amps' where slug = 'friedman-buxom-betty' and developer_id = (select id from public.developers where slug = 'universal-audio');
update public.plugins set category = 'guitar-amps' where slug = 'lion-68-super-lead' and developer_id = (select id from public.developers where slug = 'universal-audio');
update public.plugins set category = 'guitar-amps' where slug = 'marshall-bluesbreaker' and developer_id = (select id from public.developers where slug = 'universal-audio');
update public.plugins set category = 'guitar-amps' where slug = 'marshall-jmp2203' and developer_id = (select id from public.developers where slug = 'universal-audio');
update public.plugins set category = 'guitar-amps' where slug = 'marshall-plexi' and developer_id = (select id from public.developers where slug = 'universal-audio');
update public.plugins set category = 'guitar-amps' where slug = 'marshall-silver-jubilee' and developer_id = (select id from public.developers where slug = 'universal-audio');
update public.plugins set category = 'guitar-amps' where slug = 'ox-stomp-dynamic-speaker-emulator' and developer_id = (select id from public.developers where slug = 'universal-audio');
update public.plugins set category = 'guitar-amps' where slug = 'ruby-63-top-boost' and developer_id = (select id from public.developers where slug = 'universal-audio');
update public.plugins set category = 'guitar-amps' where slug = 'woodrow-55-instrument' and developer_id = (select id from public.developers where slug = 'universal-audio');
update public.plugins set category = 'guitar-amps' where slug = '800rb' and developer_id = (select id from public.developers where slug = 'plugin-alliance');
update public.plugins set category = 'guitar-amps' where slug = 'b-15n' and developer_id = (select id from public.developers where slug = 'plugin-alliance');
update public.plugins set category = 'guitar-amps' where slug = 'be-100' and developer_id = (select id from public.developers where slug = 'plugin-alliance');
update public.plugins set category = 'guitar-amps' where slug = 'bx-rockrack-v3' and developer_id = (select id from public.developers where slug = 'plugin-alliance');
update public.plugins set category = 'guitar-amps' where slug = 'e646-vs' and developer_id = (select id from public.developers where slug = 'plugin-alliance');
update public.plugins set category = 'guitar-amps' where slug = 'e765-rt' and developer_id = (select id from public.developers where slug = 'plugin-alliance');
update public.plugins set category = 'guitar-amps' where slug = 'gav19t' and developer_id = (select id from public.developers where slug = 'plugin-alliance');
update public.plugins set category = 'guitar-amps' where slug = 'lion' and developer_id = (select id from public.developers where slug = 'plugin-alliance');
update public.plugins set category = 'guitar-amps' where slug = 'pt100' and developer_id = (select id from public.developers where slug = 'plugin-alliance');
update public.plugins set category = 'guitar-amps' where slug = 'savage-120' and developer_id = (select id from public.developers where slug = 'plugin-alliance');
update public.plugins set category = 'guitar-amps' where slug = 'se100' and developer_id = (select id from public.developers where slug = 'plugin-alliance');
update public.plugins set category = 'guitar-amps' where slug = 'svt-3pro' and developer_id = (select id from public.developers where slug = 'plugin-alliance');
update public.plugins set category = 'guitar-amps' where slug = 'svt-vr' and developer_id = (select id from public.developers where slug = 'plugin-alliance');
update public.plugins set category = 'guitar-amps' where slug = 'svt-vr-classic' and developer_id = (select id from public.developers where slug = 'plugin-alliance');
update public.plugins set category = 'guitar-amps' where slug = 'te-100' and developer_id = (select id from public.developers where slug = 'plugin-alliance');
update public.plugins set category = 'guitar-amps' where slug = 'vh4' and developer_id = (select id from public.developers where slug = 'plugin-alliance');

-- -> mastering
update public.plugins set category = 'mastering' where slug = 'spl-vitalizer-mk3-t' and developer_id = (select id from public.developers where slug = 'universal-audio');
update public.plugins set category = 'mastering' where slug = 'vitalizer-mk3-t' and developer_id = (select id from public.developers where slug = 'plugin-alliance');

-- -> microphones
update public.plugins set category = 'microphones' where slug = 'mmicsim' and developer_id = (select id from public.developers where slug = 'meldaproduction');

-- -> reverb-delay
update public.plugins set category = 'reverb-delay' where slug = 'cooper-time-cube' and developer_id = (select id from public.developers where slug = 'universal-audio');
update public.plugins set category = 'reverb-delay' where slug = 'emt-140' and developer_id = (select id from public.developers where slug = 'universal-audio');
update public.plugins set category = 'reverb-delay' where slug = 'emt-250' and developer_id = (select id from public.developers where slug = 'universal-audio');
update public.plugins set category = 'reverb-delay' where slug = 'ep-34' and developer_id = (select id from public.developers where slug = 'universal-audio');
update public.plugins set category = 'reverb-delay' where slug = 'lexicon-224' and developer_id = (select id from public.developers where slug = 'universal-audio');
update public.plugins set category = 'reverb-delay' where slug = 'ocean-way-studios-deluxe' and developer_id = (select id from public.developers where slug = 'universal-audio');
update public.plugins set category = 'reverb-delay' where slug = 'ravel' and developer_id = (select id from public.developers where slug = 'universal-audio');
update public.plugins set category = 'reverb-delay' where slug = 'rmx-16-expanded' and developer_id = (select id from public.developers where slug = 'universal-audio');
update public.plugins set category = 'reverb-delay' where slug = 'uad-sound-city-studios-plug-in' and developer_id = (select id from public.developers where slug = 'universal-audio');

-- -> sample-libraries
update public.plugins set category = 'sample-libraries' where slug = 'electra-88-vintage-keyboard-studio' and developer_id = (select id from public.developers where slug = 'universal-audio');
update public.plugins set category = 'sample-libraries' where slug = 'spitfire-chamber-strings-luna-edition' and developer_id = (select id from public.developers where slug = 'universal-audio');
update public.plugins set category = 'sample-libraries' where slug = 'spitfire-symphonic-brass-luna-edition' and developer_id = (select id from public.developers where slug = 'universal-audio');
update public.plugins set category = 'sample-libraries' where slug = 'spitfire-symphonic-woodwinds-luna-edition' and developer_id = (select id from public.developers where slug = 'universal-audio');
update public.plugins set category = 'sample-libraries' where slug = 'meldwaygrand' and developer_id = (select id from public.developers where slug = 'meldaproduction');
update public.plugins set category = 'sample-libraries' where slug = 'monasterygrand' and developer_id = (select id from public.developers where slug = 'meldaproduction');

-- -> saturation
update public.plugins set category = 'saturation' where slug = 'black-box-hg-2' and developer_id = (select id from public.developers where slug = 'universal-audio');
update public.plugins set category = 'saturation' where slug = 'elysia-karacter' and developer_id = (select id from public.developers where slug = 'universal-audio');
update public.plugins set category = 'saturation' where slug = 'fatso' and developer_id = (select id from public.developers where slug = 'universal-audio');
update public.plugins set category = 'saturation' where slug = 'oxford-inflator' and developer_id = (select id from public.developers where slug = 'universal-audio');
update public.plugins set category = 'saturation' where slug = 'karacter' and developer_id = (select id from public.developers where slug = 'plugin-alliance');
update public.plugins set category = 'saturation' where slug = 'iron' and developer_id = (select id from public.developers where slug = 'plugin-alliance');

-- -> synths
update public.plugins set category = 'synths' where slug = 'waterfall-b3' and developer_id = (select id from public.developers where slug = 'universal-audio');
update public.plugins set category = 'synths' where slug = 'bx-oberhausen' and developer_id = (select id from public.developers where slug = 'plugin-alliance');
update public.plugins set category = 'synths' where slug = 'gforce-software-oberheim-dmx' and developer_id = (select id from public.developers where slug = 'plugin-alliance');
update public.plugins set category = 'synths' where slug = 'imposcar3' and developer_id = (select id from public.developers where slug = 'plugin-alliance');
update public.plugins set category = 'synths' where slug = 'knifonium' and developer_id = (select id from public.developers where slug = 'plugin-alliance');
update public.plugins set category = 'synths' where slug = 'minimonsta2' and developer_id = (select id from public.developers where slug = 'plugin-alliance');
update public.plugins set category = 'synths' where slug = 'novation-bass-station' and developer_id = (select id from public.developers where slug = 'plugin-alliance');
update public.plugins set category = 'synths' where slug = 'oberheim-ob-x' and developer_id = (select id from public.developers where slug = 'plugin-alliance');
update public.plugins set category = 'synths' where slug = 'oberheim-tvs-pro' and developer_id = (select id from public.developers where slug = 'plugin-alliance');
update public.plugins set category = 'synths' where slug = 'oddity3' and developer_id = (select id from public.developers where slug = 'plugin-alliance');

-- Duplicate: "Modern & Massive" (GetGood Drums) was inserted twice under two different slugs.
delete from public.plugins where slug = 'modern-and-massive' and developer_id = (select id from public.developers where slug = 'getgood-drums');
