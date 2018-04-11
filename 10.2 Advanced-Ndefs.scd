//--recursion

Ndef(\rev).play
Ndef(\rev).fadeTime= 4


Ndef(\rev, {Splay.ar(SinOsc.ar(1, Ndef.ar(\rev).lag(0.01)*2pi))})

Ndef(\rev, {Splay.ar(SinOsc.ar(1, Ndef.ar(\rev).lagud(0.01, 0.1)*8pi))})

//  blocksize 64 samples feedback

Ndef(\rev, {Splay.ar(SinOsc.ar(100, DelayN.ar(Ndef.ar(\rev), 1, 1).lag3(0.0001)*pi)).tanh})

Ndef(\rev, {Splay.ar(SinOsc.ar(DelayN.ar(Ndef.ar(\rev), 1, 1).lag3(0.0001)*1000).tanh)})

Ndef(\rev, {Splay.ar(SinOsc.ar(DelayN.ar(Ndef.ar(\rev), 1, 1).round(0.1)*1000).tanh)})

Ndef(\rev, {Splay.ar(SinOsc.ar(1, DelayN.ar(Ndef.ar(\rev), 0.1, 0.1).round(0.01)*2pi).tanh)})

//  .rotate and Amplitude...
Ndef(\rev, {Splay.ar(SinOsc.ar([400, 404, 806, 60+LFPulse.ar(0.1, 0, 0.5, 10)], Amplitude.ar(Ndef.ar(\rev).rotate(1)*2pi)*(Ndef.ar(\rev)), SinOsc.ar([1, 1.1])))})

//  or Balance2...
Ndef(\rev, {Splay.ar(SinOsc.ar([400, 404, 806, 60+LFPulse.ar(0.5, 0, 0.5, 10)], Amplitude.ar(Balance2.ar(Ndef.ar(\rev)[0], Ndef.ar(\rev)[1], LFTri.ar(10))*pi)*(Ndef.ar(\rev)), SinOsc.ar([1, 1.1])))})

//  or XFade2...
Ndef(\rev, {Splay.ar(SinOsc.ar([400, 404, 806, 201, 300], XFade2.ar(Ndef.ar(\rev), DelayN.ar(Ndef.ar(\rev).rotate(1)), LFTri.ar(LFTri.ar(0.1)*1000+1000))))})

Ndef(\rev, {Splay.ar(SinOsc.ar([400, 404, 806, 201, 300]/2, XFade2.ar(Ndef.ar(\rev), DelayN.ar(Ndef.ar(\rev).rotate(1)), LFTri.ar(LFTri.ar(0.1)*1000+1000))))})

Ndef(\rev, {Splay.ar(SinOsc.ar([400, 404, 806, 201, 300]/2, XFade2.ar(Ndef.ar(\rev), DelayN.ar(Ndef.ar(\rev).rotate(1)), SinOsc.ar(Ndef.ar(\rev)*1000+1000))))})

Ndef(\rev, {Splay.ar(SinOsc.ar([400, 404, 806, 201, 300]/2, XFade2.ar(Ndef.ar(\rev), DelayN.ar(Ndef.ar(\rev).rotate(1)), LFSaw.ar(Ndef.ar(\rev))))).tanh})

Ndef(\rev).stop(10)


//--Tdef - task definition

Tdef(\robot).play
Ndef(\rev).play
Ndef(\rev, {Splay.ar(SinOsc.ar(Rand(400, 4000)))})
Tdef(\robot, {loop{1000.postln; 1.wait}})
Tdef(\robot, {loop{Ndef(\rev).rebuild; 3.wait}})

Ndef(\rev, {|freq= 500| Splay.ar(SinOsc.ar(freq))})
Tdef(\robot, {loop{1000.postln; 1.wait}})
Tdef(\robot, {loop{Ndef(\rev).set(\freq, 500.rrand(5000)); 0.1.wait}})
Tdef(\robot2).play
Tdef(\robot2, {loop{Ndef(\rev).set(\freq, 200); 0.12.wait}});

Tdef(\robot).stop
Tdef(\robot2).stop
Ndef(\rev).stop



//--Tdef with patterns / streams

Tdef(\melody).play
(
Tdef(\melody, {
	var pat= Pseq([0, 5, 2, 3, 2, 1], inf).asStream;
	loop{
		pat.next.postln;
		0.2.wait;
	};
});
)

Ndef(\sin).play
Ndef(\sin, {|freq= 500| Splay.ar(SinOsc.ar(freq, 0, 0.4))})
(
Tdef(\melody, {
	var pat= Pseq([0, 5, 2, 3, 2, 1], inf).asStream;
	loop{
		Ndef(\sin).set(\freq, (pat.next+60).midicps);
		0.2.wait;
	};
});
)

Tdef(\melody2).play
(
Tdef(\melody2, {
	var pat= Pseq([5, 5, 6, 7, 6], inf).asStream;
	loop{
		Ndef(\sin).set(\freq, (pat.next+81).midicps);
		(1/3).wait;
	};
});
)

//  Note the fighting.

Tdef(\melody).stop
Tdef(\melody2).stop
Tdef(\melody).play(quant:4)
Tdef(\melody2).play(quant:4)

TempoClock.default.tempo= 1.5
TempoClock.default.tempo= 1.8
TempoClock.default.tempo= 2

Tdef(\melody).stop
Tdef(\melody2).stop
Ndef(\sin).stop


Ndef(\sin).quant= 4
Ndef(\sin).play//start at the next bar (try many times)
Ndef(\sin).stop//stop right away

c= TempoClock(0.3)
Ndef(\sin).quant= 1
Ndef(\sin).clock= c
Ndef(\sin).play
Ndef(\sin).stop


//  Waltz...
c= TempoClock(1.8)
c.sched(1, {c.beatsPerBar= 3; nil})
Pdef(\takt).play(c, quant:3)
Pdef(\takt).quant= 3

Pdef(\takt, Pbind(\freq, Pseq([400, 700, 700], inf)))

(
c.schedAbs(c.nextBar.postln, {
	c.beats.postln;
	"now!".postln;//should happen on the 1st beat of a 3/4 bar
	nil;
};
)
)

Pdef(\takt).stop

//--select between oscillators

Ndef(\sel).play
Ndef(\sel).fadeTime= 12

Ndef(\sel, {Splay.ar(Select.ar(Duty.kr(0.1, 0, Dseq([0, 1], inf)), [SinOsc.ar(2000), Saw.ar(300)]))*0.5})

Ndef(\sel, {Splay.ar(Select.ar(Duty.kr(0.05, 0, Dseq([0, 1, 1, 1, 2, 0, 1], inf)), [SinOsc.ar(2000), Saw.ar(3000), WhiteNoise.ar(0.4)]))*0.5})

Ndef(\sel, {Splay.ar(SelectX.ar(Duty.kr(0.05, 0, Dseq([0, 1, 1, 1, 2, 0, 1], inf)).lag(0.1), [SinOsc.ar(2000), Saw.ar(3000), WhiteNoise.ar(0.4)]))*0.5})

Ndef(\sel, {Splay.ar(SelectX.ar(SinOsc.ar(MouseX.kr(0.5, 500, 1))*3, [SinOsc.ar(2000), Saw.ar(3000), WhiteNoise.ar(0.4)]))*0.5})

Ndef(\sel).stop


//  Do not forget the gui...
NdefMixer(s)


//--effect chain per ndef
Ndef(\test).play
Ndef(\test, {Splay.ar(WhiteNoise.ar(0.2))})
Ndef(\test).filter(1, {|in| in*LFSaw.ar(4).max(0)})
Ndef(\test).filter(2, {|in| in+CombN.ar(in, 0.1, [0.1, 0.08])})
Ndef(\test).filter(3, {|in| CombN.ar(in, 1/400, 1/[400, 500])})
Ndef(\test).filter(4, {|in| in+SinOsc.ar([200, 202])})
Ndef(\test).filter(5, {|in| XFade2.ar(in, in.round(0.1), LFTri.ar(222))})
Ndef(\test).filter(6, {|in| in+AllpassC.ar(in, 0.5, LFTri.ar([0.1, 0.11], 0, 0.1, 0.3))})

Ndef(\test).stop(10)



//--networking pdef and ndef
n= Server(\nnn, NetAddr("192.168.0.60", 57110))//edit ip to match an ip of a computer running sc on the same network

a= Pdef(\test, Pbind(\dur, 0.5, \freq, 900, \server, n)).play
a.stop

Ndef(\net).server= n
Ndef(\net).play
Ndef(\net, {WhiteNoise.ar(0.1)})
Ndef(\net).stop


DUGen.allSubclasses.do{|x| x.postln};
