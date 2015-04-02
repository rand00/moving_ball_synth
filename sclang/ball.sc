// Set environment
SynthDef.synthDefDir = "/home/pi/code/moving_ball_synth/synths";
// Visualizations - setup
FreqScope.new;
Stethoscope(s); //< only works on internal server

//-----------------------------------------------------------------------

{ 
	var lfo_freq = MouseX.kr(0.01, 300)+(SinOsc.kr(0.01) * 300);
	var freq = SinOsc.kr(lfo_freq)*MouseY.kr(100,1100);
	var timbre = SinOsc.ar([freq,freq], [0,0]);
	Decay2.ar( 
		Impulse.ar([3,5]), 0.5, 0.01, 
		timbre
	)
}.play;
//< ball ? 


{ 
	var lfo_freq = MouseX.kr(0.01, 300)+(SinOsc.kr(2) * 300);
	var freq = SinOsc.kr(lfo_freq)*MouseY.kr(30,1100);
	var timbre = SinOsc.ar([freq,freq], [0,0]);
	Decay2.ar( 
		Impulse.ar([3,5]), 0.5, 0.01, 
		timbre
	)
}.play;
//< ball ? 

{ 
	var lfo_freq = MouseX.kr(0.01, 300);
	var freq = SinOsc.kr(lfo_freq)*MouseY.kr(30,1100);
	var timbre = SinOsc.ar([freq,freq], [0,0]);
	Decay2.ar( 
		Impulse.ar([2,60]), 0.5, 0.01, 
		timbre
	)
}.play;
//< ball - use this ?
//goo



SynthDef( \raw_grinder, 
	{| lfo_freq = 120, freq = 200, imp_freq = 60 |
		var timbre, sig;
		//lfo_freq//MouseX.kr(0.01, 300);
		//freq//MouseY.kr(30,1100);
		freq = SinOsc.kr(lfo_freq) * freq; 
		timbre = SinOsc.ar( [freq, freq+20], [0,0] );
		sig = (
			Decay2.ar( 
				Impulse.ar( [imp_freq-10, imp_freq] ), 
				0.5, 0.01, 
				timbre
			)
		);
		Out.ar( [0,1], sig);
	}
).writeDefFile;//add;//add;

x = Synth(\raw_grinder);

{ 
	var lfo_freq = (MouseX.kr(0.01, 900000)).log2;
	var freq = SinOsc.kr(lfo_freq)*MouseY.kr(30,1100);
	var timbre = SinOsc.ar([freq,freq], [0,0]);
	Decay2.ar( 
		Impulse.ar([2,60]), 0.5, 0.01, 
		timbre
	)
}.play;
//< ball - log of lfo