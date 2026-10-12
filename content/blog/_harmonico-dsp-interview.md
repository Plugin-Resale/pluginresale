---
title: "Nicolas Barreau (HARMONICO dsp) on borrowing from physics, adaptive tilt EQ and building plugins as a working engineer"
description: Paris engineer Nicolas Barreau talks about going from building acoustics to the studio, why he started HARMONICO dsp, how Spectral Mass Rebalance tilts around a moving pivot, his four plugins (including the free widener Airy), and Rayleigh, the depth tool coming in November.
date: 2026-10-16
image: /blog/harmonico-dsp-interview/portrait.jpg
---

Nicolas Barreau is a sound engineer at Sodasound, a recording studio in Paris, and the founder of HARMONICO dsp, a plugin company that borrows ideas from physics and mathematics to rethink familiar audio effects. Its first four plugins are a band-by-band stereo widener (Airy, free), an adaptive tilt EQ (Spectral Mass Rebalance), a multiband saturator with memory (Earthquake Distortion Device) and a reverb modulated by a virtual flock of birds (Murmuration).

We talked about his road from building acoustics to the studio, why he went back to coding, how Spectral Mass Rebalance works and when to use it, testing with other engineers, and Rayleigh, the plugin he is releasing in November.

<figure>
  <img src="/blog/harmonico-dsp-interview/portrait.jpg" alt="Nicolas Barreau sitting in a studio control room, in front of a mixing control surface and large wall-mounted monitors" width="1377" height="768">
  <figcaption>Nicolas Barreau, founder of HARMONICO dsp.</figcaption>
</figure>

## Background

### Could you introduce yourself: your background, and your role at Sodasound?

I'm originally from Nantes, France. I studied general engineering, first in a preparatory class and then at the École des Mines. I later specialised in room and building acoustics, joining the consulting firm AÏDA Acoustique, where I worked as a project engineer for three years.

During the COVID pandemic, I decided to shift towards audio and completed a one-year sound engineering course at SAE. I did a two-month internship at Sodasound at the end of the course. Things went really well, they offered me a position, and I've been there ever since, coming up on four years now.

My role has evolved quite a bit since I joined. I started out working on music and audiovisual recording sessions, then gradually took on more projects and responsibilities. These days, I work across a range of areas, including production management, recording, mixing, mastering, sound design, and multichannel audio.

<figure>
  <img src="/blog/harmonico-dsp-interview/studio.jpg" alt="Nicolas Barreau smiling and talking at a studio desk, with a computer screen, a monitor speaker and rack-mounted outboard gear behind him" width="1382" height="768" loading="lazy">
  <figcaption>In the studio.</figcaption>
</figure>

### What made you start your own plugin brand?

I learned to code in several programming languages during my engineering studies, and I built my first audio plugin at SAE as part of my final project. It was a basic EQ with two shelves and three parametric bands. The interface looked pretty terrible, but I really enjoyed the creative process and the satisfaction of getting something to actually work.

I joined Sodasound shortly afterwards and put plugin development on the back burner for a while. But as I gained experience working in the studio, I came up with more and more ideas for tools I wished I had available when mixing, so I decided to get back into development seriously.

## HARMONICO dsp

### HARMONICO dsp is built on real physical simulations. In practice, what does that change compared with a more conventional DSP approach?

I wouldn't always describe them as physical simulations in the strict sense. Rather, I draw on physical and mathematical principles and phenomena from other fields, adapting them to audio signal processing.

This allows me to approach familiar audio effects from a different angle, sometimes moving away from more traditional DSP techniques. I also try to make these mechanisms visible in the interface, so it doesn't just serve as a way to adjust the sound, but also helps users understand what's happening under the hood.

### Could you introduce your four current plugins, in a sentence or two each?

**Airy** is a stereo widener that works band by band. It measures the stereo width already present in each frequency band and only adds what's missing, while preserving mono compatibility and keeping the low end centred. It's free, with no account or activation required.

<figure>
  <img src="/blog/harmonico-dsp-interview/airy.jpg" alt="The Airy interface in dark red and orange: a glowing point source in the centre, Width, Diffusion, Mono Below and Ride knobs, and a stereo field curve that stays mono below 77 Hz" width="1600" height="979" loading="lazy">
  <figcaption>Airy, the free band-by-band stereo widener.</figcaption>
</figure>

**Spectral Mass Rebalance** is an adaptive, dynamic tilt EQ. It pivots the spectral balance around an equilibrium point that follows the signal's content, rather than relying on a fixed pivot frequency.

<figure>
  <img src="/blog/harmonico-dsp-interview/spectral-mass-rebalance.jpg" alt="The Spectral Mass Rebalance interface: a black spectrum on a white background, with two tilt bands set between 94 and 377 Hz and between 1.5 and 5.8 kHz" width="1600" height="980" loading="lazy">
  <figcaption>Spectral Mass Rebalance, with two tilt bands.</figcaption>
</figure>

**Earthquake Distortion Device** is a multiband saturator with memory. The distortion retains a trace of the signal that came before it, allowing the harmonic content to evolve over time rather than producing a purely static response.

<figure>
  <img src="/blog/harmonico-dsp-interview/earthquake.jpg" alt="The Earthquake Distortion Device interface: a field of beige and brown cracked tiles across the spectrum, with Reactivity, Memory, Drive, Density and Tone knobs" width="1600" height="981" loading="lazy">
  <figcaption>Earthquake Distortion Device, the multiband saturator with memory.</figcaption>
</figure>

**Murmuration** is a reverb built around 64 delay lines, with modulation driven by a virtual flock of birds rather than conventional LFOs. Its decay evolves continuously without sounding mechanically modulated.

<figure>
  <img src="/blog/harmonico-dsp-interview/murmuration.jpg" alt="The Murmuration interface: a flock of birds swirling across a purple and peach sky, above Pre-delay, Size, Decay, Modulation and Width knobs" width="1600" height="980" loading="lazy">
  <figcaption>Murmuration, the reverb modulated by a virtual flock of birds.</figcaption>
</figure>

## Focus: Spectral Mass Rebalance

### How does an adaptive, dynamic tilt EQ work, and when would you use it in mixing and mastering?

When I mix, I often find myself thinking about the audio spectrum visually, looking for ways to shift energy towards the highs or lows to help elements sit in the mix or adjust the balance of a bus. Spectral Mass Rebalance grew out of that idea.

The problem I had with traditional tilt EQs was that, whenever the source changed over time, a fixed pivot point could produce quite different results from one section to another.

SMR continuously tracks the spectral centre of mass within each band and pivots the balance around that moving point. You can choose between several pivot modes, based on the mean, peak, median, or a fixed position, depending on the source and what you're trying to achieve. The rotation maintains constant energy, so rather than simply adding more, it redistributes it.

The dynamic aspect also comes from its envelope follower: the amount of tilt can follow the signal level, with adjustable attack and release. This makes it possible, for example, to brighten the attack without making the sustain sound harsh.

<figure>
  <img src="/blog/harmonico-dsp-interview/smr-low-end.jpg" alt="Spectral Mass Rebalance with a single band below 300 Hz, running the Low-End Trick preset: the tilt curve pivots around a point near 150 Hz" width="1600" height="979" loading="lazy">
  <figcaption>A single low-end band, on the Low-End Trick preset.</figcaption>
</figure>

In mixing, I mainly use it on sources whose timbre changes significantly with the performance, such as bass, guitar, and vocals, as well as on summing buses. In mastering, I tend to make much more subtle adjustments to rebalance the overall track when it sounds a little too bright or too dull.

### How do you bring feedback from engineers, like Perceval Carré, into development?

I reached out to several sound engineers in my network and asked if they'd be interested in testing the plugins and sharing their feedback. Developing a tool is a bit like mixing: you can quickly lose perspective on what you're doing. Certain design or workflow choices that seem obvious when you know a plugin inside out aren't necessarily intuitive to someone using it for the first time.

The feedback I've received has been really valuable, both for fixing small issues and for shaping the plugins as they evolve. I've already incorporated a number of suggestions into updates, and getting these outside perspectives helps me stay focused on what matters most: building tools that are genuinely useful in real-world mixing situations.

## Today

### Can you tell us a word about your next plugin?

The next plugin is expected to be released in November. It's called Rayleigh, and like Spectral Mass Rebalance, it's a multiband tool. It lets you shape the perception of depth independently across different frequency bands by combining level, EQ, early reflections, and loss of definition.

The idea was to create a tool that makes it easy to position a source in the depth of a mix, but also to handle more subtle tasks, such as gently reducing the proximity effect on a vocal. I'm already using it in many of my sessions, and the early feedback from people who've tested it has been very encouraging.

### What advice would you give to a sound engineer who wants to get into plugin development?

I'd recommend learning the basics of DSP, watching tutorials, and starting with a simple tool using an existing framework such as JUCE.

The market is also becoming increasingly competitive. AI coding assistants have made plugin development much more accessible, although building a genuinely good plugin is still a serious undertaking.

Beyond the technical side, I think the most important thing is to start with a real problem you've encountered while working with audio, then find a different or more effective way to solve it.

### Where can people follow you and try your plugins?

Everything is available on my website at harmonicodsp.com. Airy is free, with no account or activation required. The other three plugins come with fully functional 14-day trials, and each product page includes an audio player that lets you compare the processed and unprocessed signals directly in your browser.

I'm most active on Instagram, where you can find me at @harmonicodsp.

- Website: [harmonicodsp.com](https://harmonicodsp.com/)
- Instagram: [@harmonicodsp](https://www.instagram.com/harmonicodsp/)

---

If you're looking for a used plugin, search for it on [Browse](/browse) and set an alert: we'll email you as soon as someone lists it. And if you have licenses sleeping on your hard drive, you can list them for free on the [Sell form](/sell).

*Photos and screenshots courtesy of Nicolas Barreau / HARMONICO dsp.*
