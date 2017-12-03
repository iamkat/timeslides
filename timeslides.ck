adc => FFT fft =^ RMS rms => blackhole; 
adc => LiSa loopme => dac;

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
<<< "Start!" >>>;

while (true) {
    
    rms.upchuck() @=> UAnaBlob blob;
    // print out RMS
    if( blob.fval(0) > 0.0001 ) { 
        //start recording input
        <<< "recording" >>>;
        loopme.record(1);
        loopme.play(0,1);
        <<< loopme.getVoice() >>>;
        2000::ms => now;
//        loopme.record(0);
    }
    100::ms => now;
}