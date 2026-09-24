-- Step 17: bring 70 more developers to a fuller catalogue, on top of the 30 from step 16.
-- Together with step 16, this targets ~100 developers with a complete or near-complete
-- range. Depth varies with how big each developer's real catalogue is: some (Celemony,
-- Waldorf, Reason Studios add-ons) are now essentially complete; others (Universal Audio,
-- Plugin Alliance, Eventide, Toontrack) get a solid, representative top slice rather than
-- literally every SKU, since their real catalogues run into the hundreds.
-- Checked against each developer's official pages on 2026-09-26.

insert into public.plugins (developer_id, name, slug, category)
select d.id, p.name, p.slug, p.category
from (values
  -- Celemony
  ('celemony', 'Melodyne 5 Studio', 'melodyne-5-studio', 'utilities'),
  ('celemony', 'Melodyne 5 Assistant', 'melodyne-5-assistant', 'utilities'),
  ('celemony', 'Melodyne 5 Essential', 'melodyne-5-essential', 'utilities'),
  ('celemony', 'Melodyne Capture', 'melodyne-capture', 'utilities'),

  -- Antares
  ('antares', 'Auto-Tune Pro 11', 'auto-tune-pro-11', 'utilities'),
  ('antares', 'Auto-Tune 2026', 'auto-tune-2026', 'utilities'),
  ('antares', 'Auto-Tune EFX+', 'auto-tune-efx-plus', 'utilities'),
  ('antares', 'Harmony Engine', 'harmony-engine', 'utilities'),
  ('antares', 'Mic Mod EFX', 'mic-mod-efx', 'microphones'),
  ('antares', 'Throat', 'throat', 'utilities'),

  -- Waldorf
  ('waldorf', 'PPG Wave 3.V', 'ppg-wave-3-v', 'synths'),
  ('waldorf', 'Waldorf Edition 2', 'waldorf-edition-2', 'bundles'),
  ('waldorf', 'Nave', 'nave', 'synths'),

  -- AIR Music Technology
  ('air-music-technology', 'Hybrid 3', 'hybrid-3', 'synths'),
  ('air-music-technology', 'Vacuum Pro', 'vacuum-pro', 'synths'),
  ('air-music-technology', 'Velvet', 'velvet', 'synths'),
  ('air-music-technology', 'Xpand!2', 'xpand-2', 'synths'),
  ('air-music-technology', 'DB-33', 'db-33', 'synths'),
  ('air-music-technology', 'Loom', 'loom', 'synths'),
  ('air-music-technology', 'Structure', 'structure', 'synths'),
  ('air-music-technology', 'Strike', 'strike', 'sample-libraries'),

  -- Audio Ease
  ('audio-ease', 'Altiverb 7', 'altiverb-7', 'reverb-delay'),
  ('audio-ease', 'Speakerphone 2', 'speakerphone-2', 'utilities'),
  ('audio-ease', 'Cabinet Suite', 'cabinet-suite', 'guitar-amps'),

  -- Blue Cat Audio
  ('blue-cat-audio', 'PatchWork', 'patchwork', 'utilities'),
  ('blue-cat-audio', 'Late Replies', 'late-replies', 'reverb-delay'),
  ('blue-cat-audio', 'MB-7 Mixer', 'mb-7-mixer', 'utilities'),
  ('blue-cat-audio', 'Triple EQ', 'triple-eq', 'eq'),
  ('blue-cat-audio', 'Axiom', 'axiom', 'utilities'),
  ('blue-cat-audio', 'Gain Suite', 'gain-suite', 'utilities'),
  ('blue-cat-audio', 'FreqAnalyst Pro', 'freqanalyst-pro', 'utilities'),
  ('blue-cat-audio', 'Dynamics', 'dynamics', 'compression'),

  -- Eventide
  ('eventide', 'Blackhole', 'blackhole', 'reverb-delay'),
  ('eventide', 'UltraChannel', 'ultrachannel', 'channel-strips'),
  ('eventide', 'Physion Mk II', 'physion-mk-ii', 'utilities'),
  ('eventide', 'MicroPitch', 'micropitch', 'utilities'),
  ('eventide', 'CrushStation', 'crushstation', 'saturation'),
  ('eventide', 'TriceraChorus', 'tricerachorus', 'utilities'),
  ('eventide', 'SplitEQ', 'spliteq', 'eq'),
  ('eventide', 'Anthology XII', 'anthology-xii', 'bundles'),

  -- UVI
  ('uvi', 'Falcon', 'falcon', 'synths'),
  ('uvi', 'Meteor', 'meteor', 'synths'),
  ('uvi', 'Darklight IV', 'darklight-iv', 'synths'),
  ('uvi', 'UVI Workstation', 'uvi-workstation', 'utilities'),

  -- Korg
  ('korg', 'KORG Collection 6', 'korg-collection-6', 'bundles'),
  ('korg', 'M1', 'm1', 'synths'),
  ('korg', 'Wavestate Native', 'wavestate-native', 'synths'),
  ('korg', 'TRITON', 'triton', 'synths'),
  ('korg', 'MS-20', 'ms-20', 'synths'),
  ('korg', 'ARP 2600 (Korg Collection)', 'arp-2600-korg-collection', 'synths'),
  ('korg', 'Mono/Poly', 'mono-poly', 'synths'),
  ('korg', 'PolySix', 'polysix', 'synths'),

  -- Rob Papen
  ('rob-papen', 'Predator 2', 'predator-2', 'synths'),
  ('rob-papen', 'Blade 2', 'blade-2', 'synths'),
  ('rob-papen', 'SubBoomBass 2', 'subboombass-2', 'synths'),
  ('rob-papen', 'RAW', 'raw', 'synths'),
  ('rob-papen', 'Quadrant', 'quadrant', 'synths'),

  -- Neural DSP
  ('neural-dsp', 'Archetype: Petrucci X', 'archetype-petrucci-x', 'guitar-amps'),
  ('neural-dsp', 'Archetype: Gojira X', 'archetype-gojira-x', 'guitar-amps'),
  ('neural-dsp', 'Archetype: Plini X', 'archetype-plini-x', 'guitar-amps'),
  ('neural-dsp', 'Archetype: Nolly X', 'archetype-nolly-x', 'guitar-amps'),
  ('neural-dsp', 'Archetype: Cory Wong X', 'archetype-cory-wong-x', 'guitar-amps'),
  ('neural-dsp', 'Archetype: Abasi X', 'archetype-abasi-x', 'guitar-amps'),
  ('neural-dsp', 'Fortin NTS Suite', 'fortin-nts-suite', 'guitar-amps'),
  ('neural-dsp', 'Parallax', 'parallax', 'guitar-amps'),

  -- IK Multimedia
  ('ik-multimedia', 'AmpliTube 5 MAX', 'amplitube-5-max', 'guitar-amps'),
  ('ik-multimedia', 'T-RackS 5 MAX', 't-racks-5-max', 'mastering'),
  ('ik-multimedia', 'SampleTank 4 MAX', 'sampletank-4-max', 'synths'),
  ('ik-multimedia', 'Syntronik 2 MAX', 'syntronik-2-max', 'synths'),
  ('ik-multimedia', 'Miroslav Philharmonik 2', 'miroslav-philharmonik-2', 'sample-libraries'),
  ('ik-multimedia', 'MODO Bass 2', 'modo-bass-2', 'synths'),
  ('ik-multimedia', 'MODO Drum 2', 'modo-drum-2', 'sample-libraries'),

  -- Plugin Alliance
  ('plugin-alliance', 'bx_console N', 'bx-console-n', 'channel-strips'),
  ('plugin-alliance', 'Maag EQ4', 'maag-eq4', 'eq'),
  ('plugin-alliance', 'SPL Vitalizer MK2-T', 'spl-vitalizer-mk2-t', 'mastering'),
  ('plugin-alliance', 'elysia mpressor', 'elysia-mpressor', 'compression'),
  ('plugin-alliance', 'elysia museq', 'elysia-museq', 'eq'),
  ('plugin-alliance', 'Unfiltered Audio Sandman Pro', 'unfiltered-audio-sandman-pro', 'compression'),

  -- Universal Audio
  ('universal-audio', 'Neve 1073 Preamp & EQ Collection', 'neve-1073-preamp-eq-collection', 'channel-strips'),
  ('universal-audio', '1176 Classic Limiter Collection', '1176-classic-limiter-collection', 'compression'),
  ('universal-audio', 'Fairchild Tube Limiter Collection', 'fairchild-tube-limiter-collection', 'compression'),
  ('universal-audio', 'Teletronix LA-2A Leveler Collection', 'teletronix-la-2a-leveler-collection', 'compression'),
  ('universal-audio', 'Ampex ATR-102', 'ampex-atr-102', 'saturation'),
  ('universal-audio', 'Manley Massive Passive', 'manley-massive-passive', 'eq'),

  -- Sound Radix
  ('sound-radix', 'Auto-Align 2', 'auto-align-2', 'utilities'),
  ('sound-radix', 'Surfer EQ 2', 'surfer-eq-2', 'eq'),
  ('sound-radix', 'POWAIR', 'powair', 'compression'),
  ('sound-radix', 'Dirty Tricks', 'dirty-tricks', 'utilities'),

  -- Soundiron
  ('soundiron', 'Hyperion Strings', 'hyperion-strings', 'sample-libraries'),
  ('soundiron', 'Apocalypse Percussion', 'apocalypse-percussion', 'sample-libraries'),
  ('soundiron', 'Olympus Elements', 'olympus-elements', 'sample-libraries'),
  ('soundiron', 'Voices of Rapture', 'voices-of-rapture', 'sample-libraries'),

  -- XLN Audio
  ('xln-audio', 'Addictive Drums 2', 'addictive-drums-2', 'sample-libraries'),
  ('xln-audio', 'Addictive Keys', 'addictive-keys', 'sample-libraries'),
  ('xln-audio', 'RC-20 Retro Color', 'rc-20-retro-color', 'saturation'),
  ('xln-audio', 'XO', 'xo', 'sample-libraries'),

  -- Overloud
  ('overloud', 'TH-U', 'th-u', 'guitar-amps'),
  ('overloud', 'Gem', 'gem', 'guitar-amps'),
  ('overloud', 'Breverb 2', 'breverb-2', 'reverb-delay'),
  ('overloud', 'Bass Collection', 'bass-collection', 'guitar-amps'),

  -- Polyverse Music
  ('polyverse-music', 'Manipulator', 'manipulator', 'utilities'),
  ('polyverse-music', 'Wider', 'wider', 'utilities'),
  ('polyverse-music', 'Comet', 'comet', 'reverb-delay'),

  -- Cinesamples
  ('cinesamples', 'CineWinds Core', 'cinewinds-core', 'sample-libraries'),
  ('cinesamples', 'CineBrass Core', 'cinebrass-core', 'sample-libraries'),
  ('cinesamples', 'CineStrings Core', 'cinestrings-core', 'sample-libraries'),

  -- Cinematic Studio Series
  ('cinematic-studio-series', 'CS Strings', 'cs-strings', 'sample-libraries'),
  ('cinematic-studio-series', 'CS Brass', 'cs-brass', 'sample-libraries'),
  ('cinematic-studio-series', 'CS Piano', 'cs-piano', 'sample-libraries'),
  ('cinematic-studio-series', 'CS Woodwinds', 'cs-woodwinds', 'sample-libraries'),

  -- Orchestral Tools
  ('orchestral-tools', 'Berlin Strings', 'berlin-strings', 'sample-libraries'),
  ('orchestral-tools', 'Berlin Brass', 'berlin-brass', 'sample-libraries'),
  ('orchestral-tools', 'Berlin Woodwinds', 'berlin-woodwinds', 'sample-libraries'),
  ('orchestral-tools', 'Metropolis Ark 1', 'metropolis-ark-1', 'sample-libraries'),

  -- Tokyo Dawn Records
  ('tokyo-dawn-records', 'TDR Nova', 'tdr-nova', 'eq'),
  ('tokyo-dawn-records', 'TDR Kotelnikov', 'tdr-kotelnikov', 'compression'),
  ('tokyo-dawn-records', 'TDR VOS SlickEQ', 'tdr-vos-slickeq', 'eq'),
  ('tokyo-dawn-records', 'TDR Limiter 6', 'tdr-limiter-6', 'mastering'),

  -- UJAM
  ('ujam', 'Virtual Guitarist', 'virtual-guitarist', 'guitar-amps'),
  ('ujam', 'Virtual Bassist', 'virtual-bassist', 'synths'),
  ('ujam', 'Virtual Drummer', 'virtual-drummer', 'sample-libraries'),
  ('ujam', 'Usynth Rise', 'usynth-rise', 'synths'),

  -- sonible
  ('sonible', 'smart:comp 2', 'smart-comp-2', 'compression'),
  ('sonible', 'smart:EQ 3', 'smart-eq-3', 'eq'),
  ('sonible', 'smart:limit', 'smart-limit', 'mastering'),
  ('sonible', 'smart:reverb', 'smart-reverb', 'reverb-delay'),

  -- Heavyocity
  ('heavyocity', 'Gravity', 'gravity', 'sample-libraries'),
  ('heavyocity', 'NOVO', 'novo', 'sample-libraries'),
  ('heavyocity', 'Damage 2', 'damage-2', 'sample-libraries'),
  ('heavyocity', 'AEON', 'aeon', 'sample-libraries'),

  -- EastWest
  ('eastwest', 'Hollywood Orchestra Opus Edition', 'hollywood-orchestra-opus-edition', 'sample-libraries'),
  ('eastwest', 'Hollywood Strings', 'hollywood-strings', 'sample-libraries'),
  ('eastwest', 'Fab Four', 'fab-four', 'sample-libraries'),
  ('eastwest', 'Spaces II', 'spaces-ii', 'reverb-delay'),

  -- Acon Digital
  ('acon-digital', 'Acoustica 7', 'acoustica-7', 'utilities'),
  ('acon-digital', 'Restoration Suite 3', 'restoration-suite-3', 'utilities'),
  ('acon-digital', 'DeVerberate 3', 'deverberate-3', 'utilities'),
  ('acon-digital', 'Equalize 2', 'equalize-2', 'eq'),

  -- LiquidSonics
  ('liquidsonics', 'Reverberate 3', 'reverberate-3', 'reverb-delay'),
  ('liquidsonics', 'Cinematic Rooms Pro', 'cinematic-rooms-pro', 'reverb-delay'),
  ('liquidsonics', 'Seventh Heaven', 'seventh-heaven', 'reverb-delay'),

  -- Mastering The Mix
  ('mastering-the-mix', 'REFERENCE 2', 'reference-2', 'mastering'),
  ('mastering-the-mix', 'LEVELS', 'levels', 'mastering'),
  ('mastering-the-mix', 'BASSROOM', 'bassroom', 'eq'),
  ('mastering-the-mix', 'EXPOSE', 'expose', 'utilities'),

  -- NUGEN Audio
  ('nugen-audio', 'ISL 2', 'isl-2', 'mastering'),
  ('nugen-audio', 'MasterCheck', 'mastercheck', 'utilities'),
  ('nugen-audio', 'Monofilter', 'monofilter', 'utilities'),
  ('nugen-audio', 'Paragon', 'paragon', 'reverb-delay'),

  -- Zynaptiq
  ('zynaptiq', 'Unfilter', 'unfilter', 'utilities'),
  ('zynaptiq', 'Unmix::Drums', 'unmix-drums', 'utilities'),
  ('zynaptiq', 'Unchirp', 'unchirp', 'utilities'),
  ('zynaptiq', 'Wormhole', 'wormhole', 'utilities'),

  -- Baby Audio
  ('baby-audio', 'Comeback Kid', 'comeback-kid', 'compression'),
  ('baby-audio', 'Spaced Out', 'spaced-out', 'reverb-delay'),
  ('baby-audio', 'TAIP', 'taip', 'saturation'),
  ('baby-audio', 'Crystalline', 'crystalline', 'reverb-delay'),

  -- Cableguys
  ('cableguys', 'ShaperBox 3', 'shaperbox-3', 'utilities'),
  ('cableguys', 'VolumeShaper 7', 'volumeshaper-7', 'utilities'),
  ('cableguys', 'PanShaper 3', 'panshaper-3', 'utilities'),
  ('cableguys', 'FilterShaper 3', 'filtershaper-3', 'eq'),

  -- Kazrog
  ('kazrog', 'True Iron', 'true-iron', 'saturation'),
  ('kazrog', 'Recabinet 5', 'recabinet-5', 'guitar-amps'),

  -- Orange Tree Samples
  ('orange-tree-samples', 'Evolution Steel String', 'evolution-steel-string', 'sample-libraries'),
  ('orange-tree-samples', 'Evolution Nylon String', 'evolution-nylon-string', 'sample-libraries'),
  ('orange-tree-samples', 'World Guitarist', 'world-guitarist', 'sample-libraries'),

  -- Sonuscore
  ('sonuscore', 'The Orchestra Complete 3', 'the-orchestra-complete-3', 'sample-libraries'),
  ('sonuscore', 'Mallet Flux', 'mallet-flux', 'sample-libraries'),

  -- Three-Body Technology
  ('three-body-technology', 'Kirchhoff-EQ', 'kirchhoff-eq', 'eq'),
  ('three-body-technology', 'Cenozoix Compressor', 'cenozoix-compressor', 'compression'),
  ('three-body-technology', 'Heavier7Strings', 'heavier7strings', 'synths'),

  -- Musical Sampling
  ('musical-sampling', 'Atelier Series: Amy', 'atelier-series-amy', 'sample-libraries'),
  ('musical-sampling', 'Boutique Drums: Ruby', 'boutique-drums-ruby', 'sample-libraries'),

  -- Ample Sound
  ('ample-sound', 'AGT (Guitar Taylor)', 'agt-guitar-taylor', 'sample-libraries'),
  ('ample-sound', 'AGF (Guitar Fingerstyle)', 'agf-guitar-fingerstyle', 'sample-libraries'),
  ('ample-sound', 'ABP (Bass Precision)', 'abp-bass-precision', 'sample-libraries'),

  -- Audio Modeling
  ('audio-modeling', 'SWAM Solo Strings', 'swam-solo-strings', 'synths'),
  ('audio-modeling', 'SWAM Solo Woodwinds', 'swam-solo-woodwinds', 'synths'),
  ('audio-modeling', 'SWAM Solo Brass', 'swam-solo-brass', 'synths'),

  -- BFD Drums
  ('bfd-drums', 'BFD3', 'bfd3', 'sample-libraries'),
  ('bfd-drums', 'BFD Player', 'bfd-player', 'sample-libraries'),

  -- Garritan
  ('garritan', 'Garritan Personal Orchestra 5', 'garritan-personal-orchestra-5', 'sample-libraries'),
  ('garritan', 'CFX Concert Grand', 'cfx-concert-grand', 'sample-libraries'),
  ('garritan', 'Jazz and Big Band 4', 'jazz-and-big-band-4', 'sample-libraries'),

  -- GetGood Drums
  ('getgood-drums', 'Modern & Massive', 'modern-and-massive', 'sample-libraries'),
  ('getgood-drums', 'Elevate Drums', 'elevate-drums', 'sample-libraries'),

  -- Kuassa
  ('kuassa', 'Amplifikation Vermilion', 'amplifikation-vermilion', 'guitar-amps'),
  ('kuassa', 'Amplifikation Cerberus', 'amplifikation-cerberus', 'guitar-amps'),
  ('kuassa', 'Creme', 'creme', 'compression'),

  -- Sample Modeling
  ('sample-modeling', 'The Trumpet', 'the-trumpet', 'sample-libraries'),
  ('sample-modeling', 'The Saxes', 'the-saxes', 'sample-libraries'),
  ('sample-modeling', 'The Horn', 'the-horn', 'sample-libraries'),

  -- STL Tones
  ('stl-tones', 'Tonality', 'tonality', 'guitar-amps'),
  ('stl-tones', 'Emissary', 'emissary', 'guitar-amps'),

  -- Strezov Sampling
  ('strezov-sampling', 'Storm Choir Ultimate', 'storm-choir-ultimate', 'sample-libraries'),
  ('strezov-sampling', 'Afflatus Chapter I Strings', 'afflatus-chapter-i-strings', 'sample-libraries'),

  -- United Plugins
  ('united-plugins', 'TrapTune', 'traptune', 'utilities'),
  ('united-plugins', 'Voxessor', 'voxessor', 'utilities'),
  ('united-plugins', 'FirePresser', 'firepresser', 'compression'),

  -- VI Labs
  ('vi-labs', 'Ravenscroft 275', 'ravenscroft-275', 'sample-libraries'),
  ('vi-labs', 'True Keys Italian Grand', 'true-keys-italian-grand', 'sample-libraries'),
  ('vi-labs', 'True Keys German Grand', 'true-keys-german-grand', 'sample-libraries'),

  -- Impact Soundworks
  ('impact-soundworks', 'Bravura Scoring Brass', 'bravura-scoring-brass', 'sample-libraries'),
  ('impact-soundworks', 'Shreddage 3', 'shreddage-3', 'sample-libraries'),
  ('impact-soundworks', 'Pearl Concert Grand', 'pearl-concert-grand', 'sample-libraries'),

  -- Reason Studios (more Rack Extensions)
  ('reason-studios', 'Thor', 'thor', 'synths'),
  ('reason-studios', 'Malstrom', 'malstrom', 'synths'),

  -- 8dio
  ('8dio', 'Adagio Violins 2.0', 'adagio-violins-2', 'sample-libraries'),
  ('8dio', 'Century Strings', 'century-strings', 'sample-libraries'),
  ('8dio', 'Century Ostinato Brass', 'century-ostinato-brass', 'sample-libraries'),

  -- Sonokinetic
  ('sonokinetic', 'Tutti', 'tutti', 'sample-libraries'),
  ('sonokinetic', 'Grosso', 'grosso', 'sample-libraries'),
  ('sonokinetic', 'Sotto', 'sotto', 'sample-libraries'),

  -- Minimal Audio
  ('minimal-audio', 'Current', 'current', 'synths'),
  ('minimal-audio', 'Rift', 'rift', 'saturation'),

  -- Spitfire Audio (further)
  ('spitfire-audio', 'Albion Tundra', 'albion-tundra', 'sample-libraries'),
  ('spitfire-audio', 'Albion Uist', 'albion-uist', 'sample-libraries'),
  ('spitfire-audio', 'Symphonic Motions', 'symphonic-motions', 'sample-libraries'),

  -- ProjectSAM (further)
  ('projectsam', 'Symphobia 3', 'symphobia-3', 'sample-libraries'),

  -- Positive Grid
  ('positive-grid', 'BIAS FX 2', 'bias-fx-2', 'guitar-amps'),
  ('positive-grid', 'BIAS Amp 2', 'bias-amp-2', 'guitar-amps'),
  ('positive-grid', 'Spark', 'spark', 'guitar-amps'),

  -- Sonarworks
  ('sonarworks', 'SoundID Reference for Speakers', 'soundid-reference-for-speakers', 'utilities'),
  ('sonarworks', 'SoundID Reference for Headphones', 'soundid-reference-for-headphones', 'utilities'),

  -- Plogue
  ('plogue', 'chipsounds', 'chipsounds', 'synths'),
  ('plogue', 'Bidule', 'bidule', 'utilities'),

  -- Realitone
  ('realitone', 'RealiStrings', 'realistrings', 'sample-libraries'),
  ('realitone', 'RealiVox Ladies', 'realivox-ladies', 'sample-libraries'),

  -- Red Room Audio
  ('red-room-audio', 'Palette Orchestra Complete', 'palette-orchestra-complete', 'sample-libraries'),
  ('red-room-audio', 'Cue Builders Cinematic Rhythms', 'cue-builders-cinematic-rhythms', 'sample-libraries'),

  -- Karanyi Sounds
  ('karanyi-sounds', 'Continuo', 'continuo', 'sample-libraries'),
  ('karanyi-sounds', 'Polyscape', 'polyscape', 'sample-libraries'),
  ('karanyi-sounds', 'Vapor Keys 2', 'vapor-keys-2', 'sample-libraries'),

  -- Fluffy Audio
  ('fluffy-audio', 'Silk and Lotus', 'silk-and-lotus', 'sample-libraries'),
  ('fluffy-audio', 'Venice Modern Strings', 'venice-modern-strings', 'sample-libraries'),
  ('fluffy-audio', 'Echoes of the Earth', 'echoes-of-the-earth', 'sample-libraries'),

  -- Dreamtonics
  ('dreamtonics', 'Synthesizer V Studio Basic', 'synthesizer-v-studio-basic', 'synths'),

  -- Embertone
  ('embertone', 'Blakus Cello', 'blakus-cello', 'sample-libraries'),
  ('embertone', 'Friedlander Violin', 'friedlander-violin', 'sample-libraries')
) as p(dev_slug, name, slug, category)
join public.developers d on d.slug = p.dev_slug
on conflict (developer_id, slug) do nothing;
