// IN ORDER TO HAVE SuperCollider LOAD THESE AT STARTUP, ADD THIS FILE TO
// `SuperCollider/downloaded-quarks/SuperDirt/synths/try-load-extra-synths.scd`

(


/*
James Harkins
http://doc.sccode.org/Tutorials/A-Practical-Guide/PG_04_Words_to_Phrases.html
Modified by Bruno Ruviaro and Josh Mitchell 8/19.
*/

SynthDef("warsawbass", {
arg
//Standard Values:
out = 0, freq = 440, gate = 1, amp = 0.5, pan = 0, att = 0.01, dec = 0.3, sus = 0.4, rel = 0.1,
//Other Controls:
slideTime = 0.17, cutoff = 1100, width = 0.15, detune = 1.005, preamp = 4;

var snd, env;

env = Env.adsr(att, dec, sus, rel).kr(gate: gate, doneAction: 2);
freq = Lag.kr(freq, slideTime);
snd = VarSaw.ar(freq: [freq, freq * detune], width: width, mul: preamp);
snd = Mix(snd).distort;
snd = snd * env;
snd = LPF.ar(snd, cutoff, amp);

Out.ar(out, Pan2.ar(snd, pan));
},
metadata: (
credit: "James Harkins",
category: \bass,
tags: [\bass, \synth, \pitched]
)
).add;




/*
Mitchell Sigman (2011) Steal this Sound. Milwaukee, WI: Hal Leonard Books
pp. 18-19
Adapted for SuperCollider and elaborated by Nick Collins
http://www.sussex.ac.uk/Users/nc81/index.html
under GNU GPL 3 as per SuperCollider license
Minor SynthDef modifications by Bruno Ruviaro, June 2015.
*/

SynthDef("moogbass", {
arg out = 0, pan = 0, freq = 440, amp = 0.1, gate = 1, cutoff = 1000, gain = 2.0, lagamount = 0.01, att = 0.001, dec = 0.3, sus = 0.9, rel = 0.2, chorus = 0.7;

var osc, filter, env, filterenv, snd, chorusfx;

osc = Mix(VarSaw.ar(
freq: freq.lag(lagamount) * [1.0, 1.001, 2.0],
iphase: Rand(0.0,1.0) ! 3,
width: Rand(0.5,0.75) ! 3,
mul: 0.5));

filterenv = EnvGen.ar(
envelope: Env.asr(0.2, 1, 0.2),
gate: gate);

filter =  MoogFF.ar(
in: osc,
freq: cutoff * (1.0 + (0.5 * filterenv)),
gain: gain);

env = EnvGen.ar(
envelope: Env.adsr(0.001, 0.3, 0.9, 0.2, amp),
gate: gate,
doneAction: 2);

snd = (0.7 * filter + (0.3 * filter.distort)) * env;

chorusfx = Mix.fill(7, {

var maxdelaytime = rrand(0.005, 0.02);
DelayC.ar(
in: snd,
maxdelaytime: maxdelaytime,
delaytime: LFNoise1.kr(
freq: Rand(4.5, 10.5),
mul: 0.25 * maxdelaytime,
add: 0.75 * maxdelaytime)
)
});

snd = snd + (chorusfx * chorus);

Out.ar(out, Pan2.ar(snd, pan));

},
metadata: (
credit: "Nick Collins",
category: \bass,
tags: [\pitched, \bass]
)
).add;




SynthDef(\midsaw, {
arg
// Standard Values
out = 0, amp = 1, gate = 1, freq = 100, pan = 0, att = 0.25, rel = 3, crv = 0,
// Filter and Distortion Controls
filterLo = 100, filterHi = 2000, rq = 0.3, sidePreamp = 2, midPreamp = 1,
// Chorus and Mid/Side Controls (balance is 0 to 1 and monoSwitch is 0 or 1)
lfoFreq = 0.1, lfoDepth = 0.015, balance = 0.5, monoSwitch = 0;

var env, lfo, leftIn, rightIn, mid, side, leftOut, rightOut, snd;

// Envelope and LFO
env = Env.perc(
attackTime: att,
releaseTime: rel,
curve: crv).ar(doneAction: 2);

lfo = SinOsc.ar(
freq: lfoFreq,
phase: [0, pi]);
lfo = lfo.range(1 - lfoDepth, 1 + lfoDepth);

//Stereo signal with beatings
leftIn = LFSaw.ar(freq: freq * lfo[0]);
rightIn = LFSaw.ar(freq: freq * lfo[1]);

// L/R to M/S conversion
mid = (leftIn + rightIn)/2;
side = (leftIn - rightIn)/2;

// FX on the M/S signal
mid = RLPF.ar(
in: mid,
freq: LinExp.ar(
in: env,
srclo: 0, srchi: 1,
dstlo: filterLo, dsthi: filterHi),
rq: rq,
mul: midPreamp);
mid = mid.softclip/midPreamp.softclip;
mid = mid * (1 - balance).clip(0, 1) * env;

side = RLPF.ar(
in: side,
freq: LinExp.ar(
in: env,
srclo: 0, srchi: 1,
dstlo: filterHi, dsthi: filterLo),
rq: rq,
mul: sidePreamp);
side = side.softclip/sidePreamp.softclip;
side = side * balance.clip(0, 1) * env;

// Output Stuff and Converting Back to L/R
leftOut = mid + side;
rightOut = mid - side;
snd = Select.ar(
which: monoSwitch,
array: [
[leftOut, rightOut],
Pan2.ar(leftOut, pan)]);
snd = snd * amp;
snd = Limiter.ar(snd);

Out.ar(out, snd);
},
metadata: (
credit: "Josh Mitchell",
category: \pads,
tags: [\pitched]
)
).add;



/*
Retrieved from acid_oto309.scd
Envelopes from original changed to ADSR, filterRange calculated in octaves
Modified by Bruno Ruviaro and Josh Mitchell 8/19.
*/
SynthDef("acid91", {
	arg
	// Standard Arguments
	out = 0, gate = 1, freq = 440, amp = 0.1, pan = 0, att = 0.001, dec = 0.5, sus = 0.1, rel = 0.5, curve = -4,
	// Other Controls
	// width is 0 - 1
	// filterRange is in octaves
	lagTime = 0.12, filterRange = 6, width = 0.51, rq = 0.3;

	var ampEnv, filterEnv, snd;

	freq = Lag.kr(freq, lagTime);

	ampEnv = Env.adsr(
		attackTime: att,
		decayTime: dec,
		sustainLevel: sus,
		releaseTime: rel,
		peakLevel: amp,
		curve: [0, curve, curve, curve]
	).kr(gate: gate);

	filterEnv = Env.adsr(
		attackTime: att,
		decayTime: dec * 2,
		sustainLevel: sus / 2,
		releaseTime: rel * 2,
		peakLevel: 2.pow(filterRange), // octaves multiplier
		curve: [-1 * curve, curve, curve, curve],
		bias: 1 // env sweeps from 1 to 2.pow(filterRange) and back
	).kr(gate: gate, doneAction: 2);

	snd = LFPulse.ar(freq: freq, width: width).range(-1, 1);

	snd = RLPF.ar(snd, freq * filterEnv, rq);

	snd = snd * ampEnv;

	Out.ar(out, Pan2.ar(snd, pan));
},
metadata: (
	credit: "08091500Acid309 by otophilia",
	category: \bass,
	tags: [\pitched, \acid, \phat, \subtractive]
	)
).add;



/*
Based on acid_oto309.scd
This version uses percussive envelopes for both amp and filter sweep.
Filter sweep is calculated in octaves
Modified by Bruno Ruviaro and Josh Mitchell, August 2019.
*/

SynthDef("acid92", {
	arg
	// Standard Arguments
	out = 0, freq = 440, amp = 0.1, pan = 0, att = 0.001, rel = 0.5,
	// Other Controls
	// width is 0 to 1
	// filterRange is in octaves
	lagTime = 0.12, filterRange = 6, width = 0.51, rq = 0.3;

	var ampEnv, filterEnv, snd, pitch;

	pitch = freq.cpsmidi; // Lag only useful if synth is played with Pmono

	ampEnv = Env.perc(
		attackTime: att,
		releaseTime: rel,
		level: amp
	).kr(doneAction: 2);

	filterEnv = Env.perc(
		attackTime: att,
		releaseTime: rel,
		level: filterRange * 12, // octaves to semitones
	).kr;

	snd = LFPulse.ar(freq: pitch.midicps, width: width).range(-1, 1);

	// filter sweeps from current pitch all the way up to <filterRange> octaves above and back down.
	snd = RLPF.ar(snd, (pitch + filterEnv).midicps, rq).distort;

	snd = snd * ampEnv;

	Out.ar(out, Pan2.ar(snd, pan));
},
metadata: (
	credit: "based on 08091500Acid309 by otophilia",
	category: \bass,
	tags: [\pitched, \acid, \phat, \subtractive]
	)
).add;



/*
This Double Bass SynthDef, (originally called "~bass") was made by Matias Monteagudo on
his Generative Jazz Project "MM – Coltrane’s Giant Steps," which can be found here:
https://patchstorage.com/mm-giant-steps-with-visuals/

By Matias Monteagudo, Prof. Composer, Salzburg Austria
Description by Suhel Keswani
SynthDef and Pattern modified by Suhel Keswani and Josh Mitchell, September 2020
*/

SynthDef("doublebass", {
	arg
	// Standard Values
	out = 0, pan = 0, amp = 1.0, freq = 440, att = 0.01, rel = 1.0 , crv = -30, vel = 1.0,
	// Other Controls
	freqDev = 2, op1mul = 0.1, op2mul = 0.1, op3mul = 0.1, sprd = 0.5, subAmp = 0.1;

	var env, op1, op2, op3, op4, snd, sub;

	// Percussive Envelope
	env = Env.perc(
		attackTime: att,
		releaseTime: rel,
		curve: crv
	).ar(doneAction: 2);

	// Overtones
	op1 = SinOsc.ar(
		freq: freq * 4,
		mul: vel / 2 + op1mul);

	op2 = SinOsc.ar(
		freq: freq * 3,
		phase: op1,
		mul: vel / 2 + op2mul);

	op3 = SinOsc.ar(
		freq: freq * 2,
		phase: op2,
		mul: vel / 2 + op3mul);

	// Fundamental Frequency
	op4 = SinOsc.ar(
		freq: freq + NRand(-1 * freqDev, freqDev, 3),
		phase: op3,
		mul: vel);

	// Delay Line with Multi-Channel Expansion
	snd = {
		DelayN.ar(
			in: op4,
			maxdelaytime: 0.06,
			delaytime: Rand(0.03, 0.06)
		)} !8;

	// High Pass Filter
	snd = LeakDC.ar(snd);

	// Stereo Spread
	snd = Splay.ar(
		inArray: snd,
		spread: sprd,
		level: 0.6,
		center: pan);

	// Add a sub
	sub = SinOsc.ar(
		freq: freq/2,
		mul: env * subAmp);
	sub = Pan2.ar(sub, pan);
	snd = snd + sub;

	//Ouput Stuff
	snd = snd * env;
	snd = snd * amp;
	snd = Limiter.ar(snd);
	Out.ar(out, snd);
},
metadata: (
	credit: "Matias Monteagudo",
	category: \bass,
	tags: [\pitched, \bass]
)
).add;



/* Retrieved from
//from http://sccode.org/1-5aW
Useable as a sub bass or bass drum.
Modified by Bruno Ruviaro and Josh Mitchell 8/19.
*/

SynthDef("ikedabass", {

	arg out = 0, freq = 0, att = 0, dec = 0.1, sus = 0.8, rel = 0.01, curve = -5, gate = 1, pan = 0, amp = 1, harmonic = 14.015, iphase = pi/3;

	var env, snd;

	env = Env.adsr(
	    	attackTime: att,
	    	decayTime: dec,
	    	sustainLevel: sus,
	    	releaseTime: rel,
	    	curve: curve,
	    ).kr(gate: gate, doneAction: 2);

	env = env * amp.curvelin(inMin: 0, inMax: 1, outMin: 0, outMax: 1, curve: log(10));

	snd = SinOsc.ar(
		    //Any value for freq here gets added to the freq of the note (n + 0 = n)
		    freq: 0,
		    //Phase sweeps around a circle at (rate / 2pi) to make a sine wave.
		    phase: (Sweep.ar(trig: gate, rate: 2pi * [freq, freq * harmonic]) + iphase).wrap(-pi, pi),
	        mul: [1, 0.01]
	    );

	snd = Mix.ar(snd).tanh;

	snd = LeakDC.ar(snd);

	snd = snd * env;

    Out.ar(out, Pan2.ar(snd, pan));

},
metadata: (
	credit: "meunier.fabien, possibly by Batuhan Bozkurt",
	category: \bass,
	tags: [\pitched]
	)
).add;


/*
A sub Bass based on octave-down guitar/bass effects from the 80s or so.
This version changes where on the input wave switching happens,
meaning the sub octave is more distorted and gritty than subBass1.
Josh Mitchell, 8/19.
*/

SynthDef(\subbass, {
    arg
	//Blend goes from 0 to 1
	out = 0, amp = 0.5, pan = 0, freq = 440, att = 0.001, rel = 1, curve = 8, blend = 0.5;

    var env, in, ina, synca, octa, inb, syncb, octb, octave, snd;

	//A slightly rounded percussive envelope
	env = Env.perc(att, rel, amp, [curve, -1 * curve]).kr(doneAction: 2);

	/*  Input wave +/- 90 degrees - To use SinOsc.ar, replace:
	        -"iphase:  0" with "phase: pi/2"
	        -"iphase:  1" with "phase: 0"
	        -"iphase: -1" with "phase: pi"   */
	in = LFPar.ar(freq: freq * 2, iphase: 0);
	ina = LFPar.ar(freq: freq * 2, iphase: 1);
	inb = LFPar.ar(freq: freq * 2, iphase: -1);

	//Two square waves exactly out of phase and an octave below the input wave
	synca = LFPulse.ar(freq: freq, iphase: 0);
	syncb = LFPulse.ar(freq: freq, iphase: 0.5);

	//This smoothly swaps between outputting the +90 degree wave and -90 degree wave
	octa = ina * synca;
	octb = inb * syncb;
	octave = Mix.ar([octa, octb]);

	//Mixer stage, volume adjustments, envelope, and output
	snd = Mix.ar([octave * blend, in * (blend - 1)]);
    snd = LeakDC.ar(snd);
	snd = Limiter.ar(in: snd, level: 1);
	snd = snd * env;


	Out.ar(out, Pan2.ar(snd, pan));
},
metadata: (
	credit: "Josh Mitchell, 2019",
	category: \bass,
	tags: [\pitched, \sub]
	)
).add;



/* Recieved from
https://github.com/supercollider-quarks/SynthDefPool/blob/master/pool/cs80lead_mh.scd
Vangelis/Blade Runner lead sound, based on tutorial by meastempo @ http://www.youtube.com/watch?v=Fne0oIEv-WI
Original by Mike Hairston
Pbindef notes copied from https://alijamieson.co.uk/2016/01/08/replicating-blade-runner-soundtrack
Modified by Bruno Ruviaro and Josh Mitchell 8/19.
*/

SynthDef("bladerunnersaw", {
	arg
	//Standard Values
	freq = 440, amp = 0.5, gate = 1.0, pan = 0, out = 0,
	//Amplitude Controls
	att = 0.75, dec = 0.5, sus = 0.8, rel = 1.0,
	//Filter Controls
	fatt = 0.75, fdec = 0.5, fsus = 0.8, frel = 1.0, cutoff = 200,
	//Pitch Controls
	dtune = 0.002, vibspeed = 4, vibdepth = 0.015, ratio = 0.8, glide = 0.15;

	var env, fenv, vib, ffreq, snd;


	//Envelopes for amplitude and frequency:
	env = Env.adsr(att, dec, sus, rel).kr(gate: gate, doneAction: 2);
	fenv = Env.adsr(fatt, fdec, fsus, frel, curve:2).kr(gate: gate);

	//Giving the input freq vibrato:
	vib = SinOsc.kr(vibspeed).range(1 / (1 + vibdepth), (1 + vibdepth));
	freq = Line.kr(start: freq * ratio, end: freq, dur: glide);
	freq = freq * vib;

	//See beatings.scd for help with dtune
	snd = Saw.ar([freq, freq * (1 + dtune)], mul: env * amp);
	snd = Mix.ar(snd);

	//Sending it through an LPF: (Keep ffreq below nyquist!!)
	ffreq = max(fenv * freq * 12, cutoff) + 100;
	snd = LPF.ar(snd, ffreq);

	Out.ar(out, Pan2.ar(snd, pan));
},
metadata: (
	credit: "Mike Hairston",
	category: \keyboards,
	tags: [\lead, \modulation, \analog, \cs80, \vangelis, \bladerunner]
	)
).add;


/*
Mitchell Sigman (2011) Steal this Sound. Milwaukee, WI: Hal Leonard Books
Adapted for SuperCollider and elaborated by Nick Collins
http://www.sussex.ac.uk/Users/nc81/index.html
under GNU GPL 3 as per SuperCollider license
Minor modifications by Bruno Ruviaro, June 2015.
*/

SynthDef("laserbeam", {
	arg out = 0, pan = 0.0, freq = 440, amp = 0.1, att = 0.01;
	var snd, freqenv, ampenv;
	// frequency envelope
	freqenv = EnvGen.ar(Env([4, 0.5, 1, 1], [att, 0.01, 1.0]));
	// amplitude envelope
	// no gate: fixed-time envelope, self-terminating.
	ampenv = EnvGen.ar(
		envelope: Env([0, 1, 0.5, 0.0], [0.02, 0.2, 0.1]),
		levelScale: amp,
		doneAction: 2);
	snd = LFTri.ar(freq: freq * freqenv, mul: ampenv);
	Out.ar(out, Pan2.ar(snd, pan));
}).add;



/*
I believe the original is by Bruno Ruviaro?
Modified by Josh Mitchell 8/19.
*/

SynthDef("sillyvoice", { arg
	out = 0, pan = 0, freq = 220, amp = 0.5, vibSpeed = 6, vibDepth = 0.04, vowel = 0, att = 0.05, rel = 0.1, lag = 1, gate = 1, curve = -4, kAmp = 0.05, kRel = 1;

	var vibrato, env, kEnv, in, va, ve, vi, vo, vu, snd;

	vibrato = SinOsc.kr(freq: vibSpeed).range(1 / (1 + vibDepth), (1 + vibDepth));

	env = Env.asr(
		attackTime: att,
		sustainLevel: amp,
		releaseTime: rel,
		curve: curve).kr(gate: gate, doneAction: 2);

	kEnv = Env.perc(attackTime: att, releaseTime: kRel, level: kAmp, curve: curve).kr;

	in = Saw.ar(freq: Lag.kr(in: freq, lagTime: lag) * vibrato, mul: env);

	in = in + WhiteNoise.ar(kEnv);

	va = BBandPass.ar(
		in: in,
		freq: [ 600,  1040,   2250,   2450,   2750  ],
		bw:   [ 0.1,  0.067,  0.049,  0.049,  0.047 ],
		mul:  [ 1,    0.447,  0.355,  0.355,  0.1   ]);

	ve = BBandPass.ar(
		in: in,
		freq: [ 400,  1620,   2400,   2800,   3100  ],
		bw:   [ 0.1,  0.049,  0.042,  0.043,  0.039 ],
		mul:  [ 1,    0.251,  0.355,  0.251,  0.126 ]);

	vi = BBandPass.ar(
		in: in,
		freq: [ 250,   1750,   2600,   3050,   3340  ],
		bw:   [ 0.24,  0.051,  0.038,  0.039,  0.036 ],
		mul:  [ 1,     0.032,  0.158,  0.079,  0.04  ] );

	vo = BBandPass.ar(
		in: in,
		freq: [ 400,  750,    2400,   2600,   2900  ],
		bw:   [ 0.1,  0.107,  0.042,  0.046,  0.041 ],
		mul:  [ 1,    0.282,  0.089,  0.1,    0.01  ]);

	vu = BBandPass.ar(
		in: in,
		freq: [ 350,    600,    2400,   2675,   2950  ],
		bw:   [ 0.114,  0.133,  0.042,  0.045,  0.041 ],
		mul:  [ 1,      0.1,    0.025,  0.04,   0.016 ]);

	snd = SelectX.ar(which: Lag.kr(in: vowel, lagTime: lag), array: [va, ve, vi, vo, vu]);

	snd = Mix.ar(snd);

    Out.ar(out, Pan2.ar(snd, pan));

},
metadata: (
	credit: "Bruno Ruviaro?",
	category: \misc,
	tags: [\pitched, \vocal]
	)
).add;


/*
A SynthDef by Bruno Ruviaro built around beats, an acoustic phenomenon created when
two oscillators at slightly different frequencies are combined. We hear the beating
frequency as the difference between these two frequencies.
For example, 455hz - 440hz = 15 beats per second.
Slightly modified by Josh Mitchell 8/19.
*/

SynthDef("beating", {
	arg freq = 440, amp = 0.1, out = 0, pan = 0, att = 0.01, dec = 1, curve = -4, beatFreq = 15;

	var env, snd, oscillator1, oscillator2;

	env = Env.perc(att, dec, amp, curve).kr(doneAction: 2);

	oscillator1 = SinOsc.ar(freq); //Try other waveforms for the oscillators! Mix and match, collect them all!
	oscillator2 = SinOsc.ar(Line.kr(freq + beatFreq, freq, dec));

	snd = Mix([oscillator1, oscillator2]);
	snd = snd * env;

	Out.ar(out, Pan2.ar(snd, pan));

},
metadata: (
	credit: "Bruno Ruviaro",
	category: \misc,
	tags: [\pitched]
	)
).add;



/*
Phasers are cool, here's a supercollider one:
By Josh Mitchell 11/19.
*/

SynthDef("phazer", {
    arg
	//Standard Values
	out = 0, pan = 0, freq = 440, amp = 0.5, gate = 1,
	att = 1, dec = 3, sus = 0, rel = 1.5, crv = -4,
    //Other controls
    rq = 0.5, rate = 1, minfreq = 100, maxfreq = 16000,
	drylevel = 1.5, fmdepth = 1.5, fmfreq = 432;

	var env, lfo, input, snd;

	env = Env.adsr(
		    attackTime: att,
	    	decayTime: dec,
    		sustainLevel: sus,
		    releaseTime: rel,
	    	curve: crv
	    ).ar(doneAction: 2);

	//Controls the all pass freq; try an envelope here as well!
	lfo = LinExp.ar(LFTri.ar(rate), -1, 1, minfreq, maxfreq/8);
	//lfo = LinExp.ar(env, 0, 1, minfreq, maxfreq/8);

	//The input sound (Dense frequency content is better)
	input = LFSaw.ar(freq: SinOsc.ar(fmfreq).range(1, fmdepth) * freq, mul: env * amp);

	//All pass filter + dry sound = P H A Z E R
	snd = BAllPass.ar(input, [1, 2, 4, 8] * lfo, rq);
	snd = Mix.ar(snd);
	snd = snd + (input * -1 * drylevel);
	snd = Mix.ar(snd);

    Out.ar(out, Pan2.ar(snd, pan));

},
metadata: (
	credit: "Josh Mitchell",
	category: \misc,
	tags: [\pitched, \effects]
	)
).add;



/*
The core of this is an octave arppegiator based around
modulo (.mod) and Select.ar, both of which are pretty fun.
The rest of the stuff is to make a nice ambient pad-type sound.
Notes:
    Try LFNoise2 with 2 rates for the chorus
    Try other waveforms for the arp and dry sections
    Try new foods
    Try controlling the filter cutoff with envarp
    Try all the things
Made by Josh Mitchell 2/20.
*/

SynthDef("arpoctave", {
	arg
	//Standard Controls:
	out = 0, amp = 0.1, freq = 220, pan = 0, gate = 1, att = 0.3, rel = 1, crv = 0,
	//Arp Controls: (mix goes from 0 to 1)
	arprate = 10, arpatt = 0.7, arprel = 0.6, arpmix = 0.35,
	//Chorus and Pitch Bend Controls:
	chorusrate = 0.5, chorusdepth = 0.015, div = 0.25, glide = 0.15,
	//Filter and Delay Controls:
	rq = 0.75, cutoff = 8000, delayt = 0.25, decay = 2, delamp = 0.5;

	var freqk, freqarp, chorus, bend, env, dry, envarp, arp, snd;

//LFOs and Envelopes for Amps, Freqs, and the Filter Cutoff:

	//Envelopes for the arp and dry signals (dry also controls the filter freq):
	env = Env.asr(
		        attackTime: att,
		        releaseTime: rel,
		        curve: crv).ar(gate: gate);
	envarp = Env.asr(
		        attackTime: arpatt,
		        releaseTime: arprel,
		        curve: crv).ar(gate: gate);

	//A chorus-ish sound made by two freq LFOs perfectly out of phase:
	chorus = SinOsc.ar(
		        freq: chorusrate,
		        phase: [0, pi]).range((1 - chorusdepth), (1 + chorusdepth));

	//A bit of portamento at the start of the dry signal:
	bend = Line.ar(start: div, end: 1, dur: glide);

//The Arp and Dry Signals:

	//This makes an aray of all octaves above and below the note being played:
	freqk = ((freq * 2.pow(2/3)).cpsmidi.mod(12) + 16).midicps;
	freqk = freqk * Array.fill(6, {arg i; 2.pow(i)}); // try 2 to 9 instead of 6

	//This randomly jumps between those octaves:
	freqarp = Select.kr(LFNoise0.ar(arprate).range(0, freqk.size), freqk);

	//Arp: Experiment with waveforms!
	arp = LFPulse.ar(freq: freqarp * chorus, mul: envarp);
	arp = Mix.ar(arp);

	//Dry: Experiment with waveforms!
	dry = LFTri.ar(freq: freq * chorus * bend, mul: env);
	dry = Mix.ar(dry);

//Output Stuff:

	//Mixer:
	snd = XFade2.ar(dry, arp, ((arpmix * 2) - 1), amp);

	//Low Pass Filter for mellowness:
	snd = RLPF.ar(
		        in: snd,
		        freq: LinExp.ar(
			                in: env,
			                dstlo: freq,
			                dsthi: cutoff),
                rq: rq);

	//Delay for Space:
	snd = snd + CombN.ar(
		            in: snd,
		            maxdelaytime: delayt,
		            delaytime: delayt,
		            decaytime: decay,
		            mul: delamp);

	//Don't hurt your ears and equipment!
	snd = Limiter.ar(LeakDC.ar(snd));

	DetectSilence.ar(in: snd, doneAction: 2);
	Out.ar(out, Pan2.ar(snd));
},
metadata: (
	credit: "Josh Mitchell",
	category: \pads,
	tags: [\pitched]
	)
).add;


/* Retrieved from
http://sccode.org/1-5aD
by nicolaariutti
http://sccode.org/1-5as
Modifications from the original include:
-Added Vibrato.ar, to better simulate left hand movement alongside the pre-existing pwm.
-Changed ASR envelope to ADSR and "scratch" envelopes, to simulate the attack of a bow.
-Added filters, to simulate tone brightening from the bridge and back of the instrument.
Modified by Bruno Ruviaro and Josh Mitchell 8/19.
*/

SynthDef(\violin, {
	arg
	//Standard Definitions
	freq = 440, gate = 1, amp = 1, pan = 0, out = 0, att = 0.1, dec = 0.1, sus = 0.5, rel = 0.1,
	//Vibrato Controls
	vRate = 4.6, vDepth = 0.02, vAtt = 0.15, vRateVar = 0.25, vDepthVar = 0.05,
	//PWM Controls (pwmMax and pwmMin are 0 - 1)
	pwmVarRate = 2, pwmMin = 0.7, pwmMax = 0.8, pwmRate = 5,
	//Other Controls
	bridgeFreq = 2500, scratchDepth = 0.15;

	var scratch, env, pwm, snd;

	scratch = 1.015 + Env.perc(att, dec * 1.25, scratchDepth).kr;

	env = Env.adsr(att, dec, sus, rel).kr(gate: gate, doneAction: 2);

	freq = Vibrato.kr(
		            freq: freq,
		            rate: vRate,
		            depth: vDepth,
	            	delay: (att + dec),
		            onset: vAtt,
		            rateVariation: vRateVar,
		            depthVariation: vDepthVar
            	);

	pwm = SinOsc.kr(freq: pwmRate, phase: Rand(0.0, 1.0)).range(pwmMin, pwmMax);
	pwm = pwm * LFNoise2.kr(pwmVarRate).range(0.2, 0.8);

	snd = VarSaw.ar(
		freq: Lag.kr(freq) * LFPulse.ar(freq * 1.5).range(1/scratch, scratch),
		width: pwm,
		mul: amp
	);

	snd = (snd * 0.7) + BPF.ar(snd, bridgeFreq, 2, 2);
	snd = snd + HPF.ar(snd, bridgeFreq * 2);
	snd = snd * env;
	Out.ar(out, Pan2.ar(snd, pan));
},
metadata: (
	credit: "Original by nicolaariutti, modified by Josh Mitchell",
	category: \strings,
	tags: [\bowed, \pitched, \violin]
	)
).add;


// https://github.com/everythingwillbetakenaway/Synthdefs
SynthDef(\basslow,{|out= 0 freq = 440 amp = 0.1 gate=1 cutoff= 1000 rq=0.5 pan=0.0|

	var osc, filter, env, filterenv;

	osc = Saw.ar(freq);

	filterenv = EnvGen.ar(Env.adsr(0.0,0.5,0.2,0.2),gate,doneAction:2);
	filter =  RLPF.ar(osc,cutoff*filterenv+100,rq);

	env = EnvGen.ar(Env.adsr(0.01,0.0,0.9,0.05),gate,doneAction:2);

	Out.ar(out,Pan2.ar(filter*env*amp*2,pan));

}).add;


// https://github.com/everythingwillbetakenaway/Synthdefs
SynthDef(\basshigh,{|out= 0 freq = 440 amp = 0.1 gate=1 cutoff= 3000 rq=0.1 drive = 10.0 pan=0.0|

	var osc, filter, env, filterenv;
	var ab;

	//osc = Mix(VarSaw.ar(freq*[0.25,1,1.5],Rand(0.0,1.0)!3,0.9,[0.5,0.4,0.1]));
	osc = Mix(Saw.ar(freq*[0.25,1,1.5],[0.5,0.4,0.1]));
	//osc = Mix(DPW4Saw.ar(freq*[0.25,1,1.5],[0.5,0.4,0.1]));
	filterenv = EnvGen.ar(Env.adsr(0.0,0.5,0.2,0.2),gate,doneAction:2);
	filter =  RLPF.ar(osc,cutoff*filterenv+100,rq);

 	//distortion
 	//filter = filter.distort.softclip;

	ab = abs(filter);
 	filter = (filter*(ab + drive)/(filter ** 2 + (drive - 1) * ab + 1));

	//remove low end
	filter = BLowShelf.ar(filter,300,1.0,-12);
	//dip at 1600Hz
	filter = BPeakEQ.ar(filter,1600,1.0,-6);

	env = EnvGen.ar(Env.adsr(0.01,0.0,0.9,0.05),gate,doneAction:2);

	Out.ar(out,Pan2.ar(filter*env*amp*2,pan));

}).add;



SynthDef("cs80lead_mh", {
	arg freq=880, amp=0.5, att=0.75, decay=0.5, sus=0.8, rel=1.0, fatt=0.75, fdecay=0.5, fsus=0.8, frel=1.0,
		cutoff=200, pan=0, dtune=0.002, vibrate=4, vibdepth=0.015, gate=1.0, ratio=1,out=0,cbus=1;
	var env,fenv,vib,ffreq,sig;
	cutoff=In.kr(cbus);
	env=EnvGen.kr(Env.adsr(att,decay,sus,rel),gate,levelScale:1,doneAction:2);
	fenv=EnvGen.kr(Env.adsr(fatt,fdecay,fsus,frel,curve:2),gate,levelScale:1,doneAction:2);
	vib=SinOsc.kr(vibrate).range(-1*vibdepth,vibdepth)+1;
	freq=Line.kr(freq,freq*ratio,5);
	freq=freq*vib;
	sig=Mix.ar(Saw.ar([freq,freq*(1+dtune)],mul:env*amp));
	// keep this below nyquist!!
	ffreq=max(fenv*freq*12,cutoff)+100;
	sig=LPF.ar(sig,ffreq);
	Out.ar(out, Pan2.ar(sig,pan) );
},
metadata: (
	credit: "Vangelis/Blade Runner lead sound, based on tutorial by meastempo @ http://www.youtube.com/watch?v=Fne0oIEv-WI",
	tags: [\lead, \modulation, \analog, \cs80, \vangelis, \bladerunner]
	)
).add;


)
