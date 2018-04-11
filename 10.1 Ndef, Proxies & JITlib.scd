
/*
[JITLib]
Navigate:  Browse-Libraries-JITLib Overview of the Just In Time Library

Just in time programming (or: live coding, on-the fly-programming, interactive programming) is a paradigm that includes the programming activity itself in the program's operation. This means a program is not seen as a tool that is made first, then to be productive, but a dynamic construction process of description and conversation - writing code becomes a closer part of musical practice.

ProxySpace is an environment of references on a server.  Generally a proxy is a placeholder for something, which in this caseis something playing on a server that writes to a limited number of busses. This can be a synth or an event stream, for example.
*/

(
~x = 1;  // set an  variable in the default 'currentEnvironment'
currentEnvironment.postln; 	// an Environment is a mapping of symbols to values

p = ProxySpace.new(s); // create a special type of environment, that represents processes that play audio on a server , storing it in variable p.
p.push;	// push replaces the currentEnvironment with the ProxySpace

currentEnvironment.postln;

~x;		 // accessing creates a NodeProxy (uninitialized) automatically.  A NodeProxy is a placeholder for an audio synthesis function.
~x + ~y; 	// this works immediately, because the lookup does not return nil,
	    // but a placeholder (proxy) instead
p.postln; // now there are two placeholders in the environment.
)

// execute the following steps one line at a time

// play some output to the hardware busses, this could be any audio rate key.
~out.play;

// assign an audio rate function to ~out
~out = { SinOsc.ar([400, 407] * 0.9, 0, 0.2) };

// change ~out to a different function, and it replaces the old one smoothly
~out = { SinOsc.ar([400, 437] * 0.9, 0, 0.2) * LFPulse.kr([1, 1.3]) };

// ~x has not yet been defined -- ordinarily, this would cause an error, but within ProxySpace it creates a NodeProxy, which holds a place
~out = { SinOsc.ar([400, 437] * 0.9, 0, 0.2) * ~x.postln.value };

// when ~x is assigned a signal, ~out produces sound again
~x = { LFPulse.kr([1, 1.3] * MouseX.kr(1, 30, 1)) };

// now the audio rate signal is redefined, still using the control rate signal assigned to ~x
~out = { SinOsc.ar([400, 437] * Lag.kr(0.1 + ~x, 0.3), 0, 0.2) * ~x };

// a ProxySpace contains an instance variable setting fade time for new assignments
p.fadeTime = 5;

~out = { SinOsc.ar([400, 437] * 1.1, 0, 0.2) * ~x.kr(2) };

p.end(8); // end all in 8 sec.

p.clear.pop; // remove all, move out -- the original server environment is restored

//	start over again

p = ProxySpace.push(s);		// 'push' also executes 'new', if not previously created
// as soon as a sound function (or any compatible input) is assigned to a proxy
// this sound plays on its own private bus (so it is not audible yet.)
~x = { RLPF.ar(Impulse.ar(4) * 20, [850, 950], 0.2)};

// the proxy has been initialized by its first assignment.
// it plays at audio rate (because we have assigned an audio rate ugen function)
// and it has two channels (because the function has stereo output)

~x.index; // what bus index is it? this posts the index to the postwindow
		// before it was .ir(nil), now it is initialized to .ar(2)
~x.bus // what bus is it?


~x.play; // now listen to it. a monitor is created (see JITLib/Nodeproxy/Monitor) that plays
		// the signal onto a public bus. This is independent of the proxy itself.
// for further info see: JITLib/tutorials/jitlib_basic_concepts_03 (part c)


// the sound function can be changed at any time:
(
~x = {
		RLPF.ar(Impulse.ar([5, 7]) * 5, [1450, 1234], 0.2)
}
)

// You can tune a sound function to your liking very easily
// by replacing it with little (or big) variations:

		// filter freqs higher:
~x = {	RLPF.ar(Impulse.ar([5, 8]) * 5, [1800, 2000], 0.2) }

		// same pulse ratio (5/8), different pulse tempo:
~x = {	RLPF.ar(Impulse.ar([5, 8] * 3.2) * 5, [1800, 2000], 0.2) }

		// different filter:
~x = {	Ringz.ar(Impulse.ar([5, 8] * 3.2), [1800, 2000], 0.05) }

// and if you set the proxy's fadeTime, you can create little
// textures by hand:

~x.fadeTime = 3;

// execute the line below several times, creates different filter freqs every time:
~x = {	Ringz.ar(Impulse.ar([5, 8] * rrand(0.5, 1.5)) * 0.5, ({ exprand(200, 4000) } ! 2), 0.05) }


// here is another proxy:
~y = { Pan2.ar(Dust.ar(20), 0) };

~y.bus; // it has two channels, just as the ~x., but it plays on another (private) bus.

// note that ~y is not audible directly,
// but it can be used in any other proxy:
(
~x = {

	RLPF.ar(~y.ar * 2,  [1450, 1234], 0.2)
}
)

// when the proxy changes, the result changes dynamically:

~y = { Impulse.ar(MouseX.kr(2, 18, 1)) * [1, 1] };

~y = { PinkNoise.ar(MouseX.kr(0, 0.2) * [1, 1]) };

~y = { Impulse.ar([MouseX.kr(2, 18, 1), MouseY.kr(2, 18, 1)]) };


// stop listening. the proxies run in the background.

~x.stop;

~y.bus; // ~y is playing on another bus.
~x.bus; // than ~x

// we can also listen to ~y directly:
~y.play;

// to remove an input, nil can be used:

~y = nil;

// stop listening
~y.stop;

//  Ndef is a reference to a proxy, forms an alternative to ProxySpace. All methods are inherited from NodeProxy.
//--Ndef  is best for livecoding but also for prototyping as well as stable programs.

// Folllowing code is from Fredrik Olofsson's LivekodeLyd2-4.scd tutorials

// play a simple sound function
Ndef(\key, {SinOsc.ar(700)}).play;
// replace that sound function (crossfades)
Ndef(\key, {SinOsc.ar(800)});
// end it
Ndef(\key).stop;
Ndef.clear;     // clear ALL proxies

Ndef(\first, {SinOsc.ar(600)})  // just define it
Ndef(\first).play  // now play it
Ndef(\first, {|freq= 400| SinOsc.ar(freq)}) // redefine with /freq arg
Ndef(\first).set(\freq, 300)  // 'set' the arg
Ndef(\first, {SinOsc.ar(800)})
Ndef(\first).set(\freq, 500)  // doesn't work because latest source function has no \freq argument
Ndef(\first).stop

//* ndef pros:
//  Swap code while running -- easy to change everything and no need to stop in between
//  Control and access later by referring to ndef by name.
//  Can embed or nest into each other - seamless patching.
//  Perfect for improvisation with sounding code.
//* ndef cons:
//  Adds some overhead.
//  Easy to lose track and repeat - see History below.
//  Swap with a crossfade (fadeTime) -
//  Note there are two different fadeTime for Ndef...
//  The fadeTime for play and stop are not the same as the
//  crossfade time set with fadeTime= ...

History.start
History.makeWin
//History.end

Ndef(\first).play(fadeTime: 5) //start playing 5sec fadein
Ndef(\first).fadeTime= 3 //set crossfade time
Ndef(\first, {Saw.ar(400, 0.2)})
Ndef(\first, {WhiteNoise.ar(0.15)})
Ndef(\first).stop(fadeTime: 5) //stop playing 5sec fadeout

// nesting Ndefs
Ndef(\second, {Pulse.ar(600, 0.5, 0.5)})
Ndef(\second).play
Ndef(\second).stop
Ndef(\third, {LPF.ar(Ndef.ar(\second))})
Ndef(\third).play
Ndef(\third, {BPF.ar(Ndef.ar(\second), 500, 0.1)})
Ndef(\third).stop

//  nesting noise Ndef
Ndef(\brus, {WhiteNoise.ar(0.5)})
Ndef(\filter, {LPF.ar(Ndef.ar(\brus), 600)}).play
Ndef(\filter).fadeTime= 5
Ndef(\filter, {LPF.ar(Ndef.ar(\brus), 300)})
Ndef(\filter).stop

// fm with nested control
Ndef(\fm, {SinOsc.ar(Ndef.ar(\ctrl)*400, 0, 0.1)})
Ndef(\fm).play // Ndef(\ctrl) has no sounding source, so there is no sound
Ndef(\ctrl, {SinOsc.ar(2)})
Ndef(\fm).stop

//  AM with replaceable \ctrl and fadeTime set to 10.
Ndef(\am, {SinOsc.ar(500, 0, Ndef.ar(\ctrl))}).play
Ndef(\ctrl).fadeTime = 3
Ndef(\ctrl, {SinOsc.ar(5)})
Ndef(\ctrl).fadeTime= 10
Ndef(\ctrl, {SinOsc.ar(2)})
Ndef(\ctrl, 0)
Ndef(\ctrl, {SoundIn.ar}) //uses mic input as amp control
Ndef(\kaos, {LFNoise0.ar(4)})
Ndef(\ctrl, {Ndef.ar(\kaos)})
Ndef(\am).stop

//------------------------------------------------------------------
//--    multichannel
//------------------------------------------------------------------

s.meter // or cmd+m,  show VU meters
s.scope  // show waveforms

Ndef(\k).play(0, 3)  // starting at Bus=0, 3 chans
Ndef(\k, {SinOsc.ar([400, 500, 600],mul:0.25)})
Ndef(\k).play(1, 3)
Ndef(\k).numChannels

Ndef(\h).play.numChannels // default creates a stereo ndef
Ndef(\h, {Splay.ar(SinOsc.ar(400,mul: 0.25))}) // Splay distributes multiple chans to stereo
Ndef(\h, {SinOsc.ar(800,mul:0.25)}) // now mono
Ndef(\h).stop

//------------------------------------------------------------------
//--     developing a noise instrument with ndef
//------------------------------------------------------------------

Ndef(\one).play //create and start playing a stereo ndef
Ndef(\one, {BrownNoise.ar(SinOsc.ar(1))}) //define what this ndef should do
Ndef(\one, {WhiteNoise.ar(0.1)}) //redefine that this ndef should do
Ndef(\one).release(2) // 'release' means fade out, then stop

//--a pad
Ndef(\pad).play
Ndef(\pad, {Splay.ar( Saw.ar([400, 500, 404, 660], [0.2, 0.2, 0.2, 0.1] ))})
Ndef(\pad).fadeTime= 3
Ndef(\pad, {Splay.ar( Saw.ar([1430.40, 520, 404, 640.4], [0.2, 0.2, 0.2, 0.1] ))})
Ndef(\pad, {Splay.ar( BLowPass4.ar( Saw.ar([404, 505, 606, 707], [0.4, 0.3, 0.2, 0.5]), 2000, 0.8))})
//  All detuned by same noise oscillator.
Ndef(\pad, {Splay.ar( BLowPass4.ar( Saw.ar([404, 505, 606, 707]+LFNoise2.ar(0.1, 10), [0.4, 0.3, 0.2, 0.5]), 2000, 0.8))})
//  Individually detuned (by 4 noise oscillators).
Ndef(\pad, {Splay.ar( BLowPass4.ar( Saw.ar([404+LFNoise2.ar(0.1, 10), 505+LFNoise2.ar(0.1, 10), 606+LFNoise2.ar(0.1, 10), 707+LFNoise2.ar(0.1, 10)], [0.4, 0.3, 0.2, 0.5]), 2000, 0.8))})
//  Same thing but written with shortcut code (!4).
Ndef(\pad, {Splay.ar( BLowPass4.ar( Saw.ar([404, 505, 606, 707]+LFNoise2.ar(0.1!4, 30), [0.4, 0.3, 0.2, 0.5]), 2000, 0.8))})
//  Adding 4 noise oscillators for amplitude modulation.
Ndef(\pad, {Splay.ar( BLowPass4.ar( Saw.ar([404, 505, 606, 707]+LFNoise2.ar(0.1!4, 30), [0.4, 0.3, 0.2, 0.5]+LFNoise2.ar(0.1!4, 0.1)), 2000, 0.8))})
//--refactoring the pad - indentation
(
Ndef(\pad, {
	Splay.ar(
		BLowPass4.ar(
			Saw.ar(
				[404, 505, 606, 707]+LFNoise2.ar(0.1!4, 30),
				[0.4, 0.3, 0.2, 0.5]+LFNoise2.ar(0.1!4, 0.1)
			),
			2000,//cutoff freq for filter
			0.8//q for filter
		)
	)
})
)
//--refactoring the pad - modularization
(
Ndef(\padFreqs, {[404, 505, 606, 707]+LFNoise2.ar(0.1!4, 30)});
Ndef(\padAmps, {[0.4, 0.3, 0.2, 0.5]+LFNoise2.ar(0.1!4, 0.1)});
Ndef(\pad, {
	Splay.ar(
		BLowPass4.ar(
			Saw.ar(
				Ndef.ar(\padFreqs),
				Ndef.ar(\padAmps)
			),
			2000,//cutoff freq for filter
			0.8//q for filter
		)
	)
});
)
//--improving the pad... Adding two more ndefs for the filter parameters.
(
Ndef(\padFreqs, {[404, 505, 606, 707]+LFNoise2.ar(0.1!4, 30)});
Ndef(\padAmps, {[0.4, 0.3, 0.2, 0.5]+LFNoise2.ar(0.1!4, 0.1)});
Ndef(\padCut, 2000);
Ndef(\padQ, 0.8);
Ndef(\pad, {
	Splay.ar(
		BLowPass4.ar(
			Saw.ar(
				Ndef.ar(\padFreqs),
				Ndef.ar(\padAmps)
			),
			Ndef.ar(\padCut),//cutoff freq for filter
			Ndef.ar(\padQ)//q for filter
		)
	)
});
)
Ndef(\padFreqs).fadeTime= 10
Ndef(\padFreqs, 500);
Ndef(\padFreqs, {SinOsc.ar(1)*10+500})
Ndef(\padFreqs, {SinOsc.ar([1, 1.1])*10+500})
Ndef(\padFreqs, {SinOsc.ar([1, 1.1, 1.2])*[10, 20, 30]+500})
Ndef(\padAmps).fadeTime= 2
Ndef(\padAmps, {0.5+LFNoise0.ar(1!4, 0.1)});
Ndef(\padFreqs, {LFSaw.ar([1, 1.1, 1.2])*[10, 20, 30, 44]+500})
Ndef(\padFreqs, {[404, 505, 606, 707, 808, 909, 1100, 3000]+LFNoise2.ar(30!14, 40)});
Ndef(\pad).stop(4)

//--new example

{Decay.ar(Dust.ar(1), 0.2)}.plot(1); //rougly one trigger per second
{Decay.ar(Dust.ar(10), 0.2)}.plot(1) //roughly ten triggers per second

Ndef(\abc).play
Ndef(\abc, {Splay.ar(PinkNoise.ar*Decay.ar(Dust.ar(1), 0.2))})
Ndef(\abc, {Splay.ar(PinkNoise.ar*Decay.ar(Dust.ar([1, 1]), 0.2))})
Ndef(\abc, {Splay.ar(PinkNoise.ar*Decay.ar(Dust.ar([1, 1, 1]), 0.2))})
Ndef(\abc, {Splay.ar(PinkNoise.ar*Decay.ar(Dust.ar([1, 1, 1, 1, 1, 1, 1, 1]), 0.2))})

//  With a filter,
Ndef(\abc, {Splay.ar(BLowPass4.ar(PinkNoise.ar*Decay.ar(Dust.ar([1, 1, 1, 1, 1, 1, 1, 1]), 0.2), [100, 200, 300, 400, 500, 600, 700, 800], 0.2))})
//  Same but written more compact,
Ndef(\abc, {Splay.ar(BLowPass4.ar(PinkNoise.ar*Decay.ar(Dust.ar(1!8), 0.2), (1..8)*100, 0.2))})
//  Now with 15 instead of 8 channels.
Ndef(\abc, {Splay.ar(BLowPass4.ar(PinkNoise.ar*Decay.ar(Dust.ar(1!15), 0.2), (1..15)*500, 0.2))})

// Note how multichannel expansion can trick you.
Dust.ar(1)!15 //15 copies of the same dust object
Dust.ar(1!15) //15 unique dust objects

//  Change over 10 seconds.
Ndef(\abc, {Splay.ar(BLowPass4.ar(PinkNoise.ar*Decay.ar(Dust.ar(1!15), 0.2), XLine.ar((1..15)*100, (1..15)*1000, 10), 0.2))})
// change Decay to Decay2
Ndef(\abc, {Splay.ar(BLowPass4.ar(WhiteNoise.ar*Decay2.ar(Dust.ar(1!15), 0.5, 1), XLine.ar((1..15)*100, (1..15)*1000, 10), 0.08))})
// change BLowPass4 filter (above) to Ringz (below)
Ndef(\abc, {Splay.ar(Ringz.ar(WhiteNoise.ar*Decay2.ar(Dust.ar(1!15), 0.5, 1), XLine.ar((1..15)*100, (1..15)*1000, 10), 0.08))})
// change Dust to Impulse
Ndef(\abc, {Splay.ar(Ringz.ar(WhiteNoise.ar*Decay2.ar(Impulse.ar((1..15)*0.05), 0.5, 1), XLine.ar((1..15)*100, (1..15)*1000, 10), 0.08))})
//  Play with Line as a controller for Dust density.
Ndef(\abc, {Splay.ar(BLowPass4.ar(PinkNoise.ar*Decay.ar(Dust.ar(Line.ar(0.01, 10, 20)!8), 0.2), (1..8)*100, 0.2))})
//  Or a sine that controls all dust densities.
Ndef(\abc, {Splay.ar(BLowPass4.ar(PinkNoise.ar*Decay.ar(Dust.ar(SinOsc.ar(0.1).range(0.01, 20)!8), 0.2), (1..8)*100, 0.2))})
//  Exponential instead of linear
Ndef(\abc, {Splay.ar(BLowPass4.ar(PinkNoise.ar*Decay.ar(Dust.ar(SinOsc.ar(0.1).exprange(0.01, 20)!8), 0.2), (1..8)*100, 0.2))})

Ndef(\abc).stop

//--new example

Ndef(\xyz).play
Ndef(\xyz, {Splay.ar(PinkNoise.ar*Decay.ar(Dust.ar(1!8), 0.2))})
Ndef(\xyz, {Splay.ar(PinkNoise.ar*Decay.ar(Impulse.ar(1!8), 0.2))})
Ndef(\xyz, {Splay.ar(PinkNoise.ar*Decay.ar(Impulse.ar(1!8, [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8]), 0.2))})
Ndef(\xyz, {Splay.ar(PinkNoise.ar*Decay.ar(Impulse.ar(1!8, {1.0.rand}!8), 0.2))})

Ndef(\xyz).fadeTime= 5
//--same but different
Ndef(\xyz, {Splay.ar(PinkNoise.ar*Decay.ar(Ndef.ar(\triggers), 0.2))})
Ndef(\triggers, {Impulse.ar([1, 1.1])})
Ndef(\triggers).fadeTime= 8
Ndef(\triggers, {Dust.ar([1, 1])})
Ndef(\triggers, {Dust.ar([1, 2, 3, 4, 5])})

//  Adding a resonating filter.
Ndef(\xyz, {Splay.ar(Ringz.ar(PinkNoise.ar*Decay.ar(Dust.ar((1..8)*1.01), 0.2), (1..8)*100+300, 0.3))})
Ndef(\freqs).clear
Ndef(\freqs, (1..8)*100+300) //note without {} here
Ndef(\freqs).numChannels //should say eight
Ndef(\xyz, {Splay.ar(Ringz.ar(PinkNoise.ar*Decay.ar(Dust.ar((1..8)*1.01), 0.2), Ndef.ar(\freqs), 0.3))})
Ndef(\freqs).fadeTime= 5
Ndef(\freqs, (1..8)*100+400) //raise everything 100Hz

//  Back to simplicity.
Ndef(\xyz, {Splay.ar(Ringz.ar(Impulse.ar([1, 1.1, 1.2]), [500, 505, 550], [0.1, 0.05, 0.01]))})
Ndef(\xyz).stop(4)

//--throw away gui

Ndef(\ttest).play
Ndef(\ttest, {SinOsc.ar([400, 404])})
Ndef(\ttest).gui

//  Note that there are no sliders in the main area - only the default volume at the top.
//  View the meter window (cmd+m) and try the number box - it sets the output bus.
//  Try the paus/resume button.
//  The send button reevaluates the Ndef.
//  This button is useful if your Ndef contains randomness. To try it first run this...
Ndef(\ttest, {SinOsc.ar([400, 404]+Rand(40))})
//and then press 'send'. the Ndef generates a random value each time

//  Now run this line - it only adds two arguments to the ndef.
Ndef(\ttest, {|freq= 400, detune= 4, amp= 1| SinOsc.ar([freq, freq+detune], 0, amp)})
//note how two sliders popped up in the main area of the gui.

//  And after this line you should have four sliders...
Ndef(\ttest, {|freq= 400, detune= 4, amp= 1, pmod= 0| SinOsc.ar([freq, freq+detune], SinOsc.ar(pmod), amp)});

//  And now five...
Ndef(\ttest, {|freq= 400, detune= 4, amp= 0.3, pmod= 0, pamp= 3 | SinOsc.ar([freq, freq+detune], SinOsc.ar(pmod, 0, pamp), amp)});
Ndef(\ttest).gui
//  But the gui window is too small to see all five at the same time,
//  So let us create a new one with lots of slots...
Ndef(\ttest).gui(15)//15 possible argument slots

//Another gui is the NdefMixer. See it as a master mixer or overview for all your Ndefs.
NdefMixer(s)
//click the edit button to access the argument controller sliders for each Ndef.
//Spec is used to set range and curvature for sliders.
//Here we set pamp to go between -40 and 40 with a linear curve.
Spec.add(\pamp, [-40, 40, \lin]);
//Now open a new mixer and click edit to see the result.
NdefMixer(s)

//--fm synthdef constructor

Ndef(\ggg).play
Ndef(\ggg, {Splay.ar(SinOsc.ar(0, SinOsc.ar(400, 0, 2pi)))})
Ndef(\ggg).gui

Ndef(\ggg, {|freq= 400, freq2= 0, aamp= 2pi| Splay.ar(SinOsc.ar(freq2, SinOsc.ar(freq, 0, aamp)))})
Ndef(\ggg).gui
(
Ndef(\ggg, {|freq= 400, freq2= 0, aamp= 2pi|
	var detune= [0.99, 1, 1.01];
	Splay.ar(SinOsc.ar(freq2*detune, SinOsc.ar(freq*detune, 0, aamp)));
});
)
Ndef(\ggg).gui
(
Ndef(\ggg, {|freq= 400, freq2= 0, aamp= 2pi, spd=0.2|
	var detune= [0.99, 1, 1.01]+LFNoise0.ar(spd).range(0.5, 2);
	Splay.ar(SinOsc.ar(freq2*detune, SinOsc.ar(freq*detune, 0, aamp)));
});
)
Ndef(\ggg).gui(4)
Ndef(\ggg).stop

//--one more level

Ndef(\hhh).play
(
Ndef(\hhh, {|freq= 400, amp= 0.5, aamp= 2pi, bamp= 3pi, freqa= 0, freqb= 0|
	Splay.ar(
		SinOsc.ar(
			freqb,
			SinOsc.ar(freqa,
				SinOsc.ar(freq, 0, aamp),
				bamp),
			amp
		)
	)
});
)
Ndef(\hhh).gui(10)
(
Ndef(\hhh, {|freq= 400, amp= 0.5, aamp= 2pi, bamp= 3pi, freqa= 0, freqb= 0|
	var detune= [0.99, 1, 1.01];
	Splay.ar(
		SinOsc.ar(
			freqb*detune,
			SinOsc.ar(freqa*detune,
				SinOsc.ar(freq*detune, 0, aamp),
				bamp),
			amp
		)
	)
});
)
Ndef(\hhh).set(\freq, 700)
Ndef(\hhh).set(\freq, 500)
(
Ndef(\hhh, {|freq= 400, amp= 0.5, aamp= 2pi, bamp= 3pi, freqa= 0, freqb= 0|
	var detune= [0.99, 1, 1.01]+SinOsc.ar(100, 0, 0.1);
	Splay.ar(
		SinOsc.ar(
			freqb*detune,
			SinOsc.ar(freqa*detune,
				SinOsc.ar(freq*detune, 0, aamp),
				bamp),
			amp
		)
	)
});
)
Ndef(\hhh).set(\freq, 400, \amp, 0.5, \aamp, 0.4, \bamp, 0.3, \freqa, 0.01, \freqb, 0.22)
Ndef(\fff, {SinOsc.ar(1).range(400, 500)})
Ndef(\hhh).map(\freq, Ndef(\fff))
Ndef(\hhh).gui(10)
Ndef(\hhh).stop

//--last examples

Ndef(\iii).play
(
Ndef(\iii, {|freq= 400, amp= 0.5, freq2= 0, freq3= 0|
	Splay.ar(SinOsc.ar(0, SinOsc.ar(freq, LFSaw.ar(freq2).lag(0.01), LFSaw.ar(freq3*10)), amp));
});
)
Ndef(\iii).set(\freq2, 100, \freq3, 0.2)
Ndef(\iii).set(\freq, 300)
Ndef(\iii).fadeTime= 4
Ndef(\iii).xset(\freq, 400)  // crossfade to new setting
Ndef(\iii).xset(\freq, 1200)
Ndef(\iii).xset(\freq, 800)
Ndef(\iii).stop

// NodeProxy roles, see:  Libraries->JITLib>NodeProxy
//roles allow to specify how a source for a NodeProxy is being used -- A role is an association of a Symbol and the new proxy source object

Ndef(\jjj).play
(
Ndef(\jjj, {|freq= 400, amp= 0.5, freq2= 500, freq3= 0.25|
	Splay.ar(SinOsc.ar(0, SinOsc.ar(freq, LFSaw.ar(freq2).lag(0.01), LFSaw.ar(freq3*10)), amp));
});
)

// \set -> event pattern
// Set the proxy controls with an event pattern of type \set
Ndef(\jjj)[1]= \set -> Pbind(\degree, Pseq([0, 5, 4, 3, 1, 2, 1], inf), \amp, 0.5, \scale, Scale.minor, \dur, 1)

Ndef(\jjj)[1]= \set -> Pbind(\degree, Pseq([0, 5, 4, 3, 1, 2, 1], inf)+12, \amp, Pseq([0.5, 0.01], inf), \scale, Scale.minor, \dur, Pseq([0.5, 0.25, 0.125], inf)*1.01)

Ndef(\jjj)[2]= \set -> Pbind(\degree, Pseq([0, 5, 4, 3, 1, 2, 1], inf)-12, \amp, Pseq([0.5, 0.01], inf), \scale, Scale.minor, \dur, Pseq([0.5, 0.25, 0.125], inf)*1.01)

Ndef(\jjj)[3]= \set -> Pbind(\degree, Pseq([0, 5, 4, 3, 1, 2, 1], inf), \freq2, Pseq([10, 20, 30, 40, 50], inf), \amp, Pseq([0.5, 0.01], inf), \scale, Scale.minor, \dur, Pseq([0.5, 0.25, 0.125], inf)*1.01)

Ndef(\jjj).stop(3)

Ndef(\blend).play

(
Ndef(\blend, {
	Splay.ar(SinOsc.ar(
	// Mix one output from many sources,
		SelectXFocus.ar(MouseX.kr(0, 2), ([
			Scale.chromatic.degrees,
			Scale.major.degrees,
			Scale.minor.degrees
		]+60).midicps
		),
		0,0.2
	))
})
)
Ndef(\blend).stop(3)

/***********/

Ndef(\ett).play
(
Ndef(\ett, {Splay.ar(
	SinOsc.ar(
		0,
		SinOsc.ar([123, 234, 345, 456, 567], 0, 2pi),
		LFSaw.ar([0.1, 0.2, 0.3, 0.4, 0.5]).clip(0, 1)
	)
)});
)
Ndef(\ett).fadeTime= 4

(
Ndef(\ett, {Splay.ar(
	SinOsc.ar(
		LFSaw.ar([1, 2, 3, 4, 5]),
		SinOsc.ar([123, 234, 345, 456, 567], 0, 2pi),
		LFSaw.ar([0.1, 0.2, 0.3, 0.4, 0.5]).clip(0, 1)
	)
)});
)


//  Using mousex and mousey to explore.
//  Note the use of poll and labels
(
Ndef(\ett, {Splay.ar(
	SinOsc.ar(
		LFSaw.ar([1, 2, 3, 4, 5])*MouseX.kr(0, 100).poll(label:\mx),
		SinOsc.ar([123, 234, 345, 456, 567], 0, MouseY.kr(0, 2pi).poll(label:\my)),
		LFSaw.ar([0.1, 0.2, 0.3, 0.4, 0.5]).clip(0, 1)
	)
)});
)

Ndef(\ett).stop

Ndef(\too).play
Ndef(\too).fadeTime= 4
Ndef(\too, {GVerb.ar(Ndef.ar(\ett), 90, 0.5)}) //reverb
Ndef(\too, {CombN.ar(Ndef.ar(\ett), 0.4, 0.4, 4)}) //echo
Ndef(\too, {Ndef.ar(\ett)*SinOsc.ar(400)}) //ringmodulation
Ndef(\too, {(Ndef.ar(\ett)*5).tanh*0.5}) //distortion
Ndef(\too, {BLowPass4.ar(Ndef.ar(\ett), 400, 0.1, 2)}) //filter

Ndef(\too).stop

Ndef(\tre).play
Ndef(\tre).fadeTime= 3
Ndef(\tre, {XFade2.ar(Ndef.ar(\ett), Ndef.ar(\too), MouseX.kr(-1, 1))}) //crossfade with mousex
Ndef(\tre, {XFade2.ar(Ndef.ar(\ett), Ndef.ar(\too), MouseX.kr(-1, 1), MouseY.kr(1, 0))}) //crossfade with mousex and volume control with mousey

Ndef(\tre, {|pan= 0, amp= 0| XFade2.ar(Ndef.ar(\ett), Ndef.ar(\too), pan, amp)})
NdefMixer(s) //and click 'ed' on \tre

//  Now feeding back the output (\tre) into the source (\ett).

(
Ndef(\ett, {Splay.ar(
	SinOsc.ar(
		LFSaw.ar([1, 2, 3, 4, 5]),
		SinOsc.ar([123, 234, 345, 456, 567], 0, 2pi),
		LFSaw.ar([0.1, 0.2, 0.3, 0.4, 0.5]).clip(0, 1)+DelayN.ar(Ndef.ar(\tre), 0.1, 0.1)
	)
)});
)
Ndef(\tre, {|pan= 0, amp= 0| Limiter.ar(XFade2.ar(Ndef.ar(\ett), Ndef.ar(\too), pan, amp))})

//  Use the gui sliders to control the feedback

Ndef(\tre).gui

Ndef(\tre).stop

//--

Ndef(\monster).play
(
Ndef(\monster, {
	var n= 10;
	Splay.ar(
		SinOsc.ar(
			SinOsc.ar(
				SinOsc.ar(0, SinOsc.ar({100.0.rand}!n))*({10.0}!n),
				0,
				LFSaw.ar({10.0.rand}!n).clip(0, 1)
			),
			SinOsc.ar(0, SinOsc.ar({100.0.rand}!n))*({10.0}!n),
			LFSaw.ar({1.0.rand}!n).clip(0, 1)
		)
	)
}
)
)
Ndef(\monster).stop(5)

