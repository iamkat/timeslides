adc => FFT fft =^ RMS rms => blackhole; 
adc => Gain g => LiSa loopme => dac;

float kattyGain;
1.0 => kattyGain;

// if audio > loudness of X  (RMS) -> record
// set parameters - from loudness script
1024 => fft.size;
// set hann window
Windowing.hann(1024) => fft.window;

//alloc memory 
60::second => loopme.duration;
<<<"buffer duration = ", loopme.duration() / 44100.>>>;
//set number of layers
10 => loopme.maxVoices; 
// print get voice

// Wait one second
1000::ms => now;
<<< "recording" >>>;
loopme.record(1);
2000::ms => now;
loopme.record(0);

while (true) {
    
    rms.upchuck() @=> UAnaBlob blob;
    // print out RMS
    if( blob.fval(0) > 0.0001 ) { 
        //start recording input
        <<< "playing" >>>;
        loopme.play(0,1);
        loopme.record(1);
        2000::ms => now;
        <<< loopme.getVoice() >>>;
    }
    if (blob.fval(0) > 0.001) { 
        kattyGain - 0.1 => kattyGain ;
        kattyGain =>g.gain;
        <<< "Lowering gain to : " + kattyGain >>>; 
    }

    100::ms => now;
}