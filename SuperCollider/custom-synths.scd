

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
)