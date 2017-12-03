adc => FFT fft =^ RMS rms => blackhole; 
adc => Gain g => LiSa loopme => dac;

float kattyGain;

// if audio > loudness of X  (RMS) -> record
// set parameters - from loudness script
1024 => fft.size;
// set hann window
Windowing.hann(1024) => fft.window;


fun void layers()
{
    
    //alloc memory 
    60::second => loopme.duration;
    <<<"buffer duration = ", loopme.duration() / 44100.>>>;
    //set number of layers
    10 => loopme.maxVoices; 

    // Wait one second
    1000::ms => now;
    <<< "recording" >>>;
    loopme.record(1);
    2000::ms => now;
    loopme.record(0);

    // infinite time loop
    while( true )
    {
        rms.upchuck() @=> UAnaBlob blob;
        // print out RMS
        if( blob.fval(0) > 0.0001 ) { 
            //start recording input
            <<< "playing" >>>;
            loopme.record(1);
            2000::ms => now;
            <<< loopme.getVoice() >>>;
        }
    }
}

fun void autogain()
{
    
    1.0 => kattyGain;

    while (true) {
        
        rms.upchuck() @=> UAnaBlob blob;
        
        if (blob.fval(0) > 0.001) { 
            kattyGain - 0.01 => kattyGain ;
            kattyGain =>g.gain;
            <<< "Lowering gain to : " + kattyGain >>>; 
        }     
        
        /*
        if (blob.fval(0) < 0.0005) { 
            kattyGain + 0.01 => kattyGain ;
            kattyGain =>g.gain;
            <<< "Increasing gain to : " + kattyGain >>>; 
        }        
        */
        50::ms => now;
    }
}

spork ~ autogain();
spork ~ layers();

// infinite time loop - to keep child shreds around
while( true ) {
    loopme.play(0,1);
    2::second => now;
}