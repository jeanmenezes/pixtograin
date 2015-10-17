// This class produces sounds with waveform generators.

public class ColorOsc {
    Blit bh; Blit bh2;
    BlitSquare bq; BlitSquare bq2;
    BlitSaw bs; BlitSaw bs2;
    Envelope e => Gain g => Pan2 pan;

    public void set( float ga, dur secs, int sig, int pos, float halfwidth ) {
        ga * 0.75  => g.gain;
        secs / second => e.time;
        if ( sig == 0 ) { 0.0 => pan.pan; }
        else {
            if ( sig < 0 ) { sig + ( pos * ( 1.0 / halfwidth ) ) => pan.pan; }
            else { ( pos / 2 ) * ( 1.0 / halfwidth ) => pan.pan; }
        }
    }

    public void connect( UGen ug ) {
        pan => ug;
    }

    public void disconnect ( UGen ug ) {
        pan =< ug;
    }

    public void trig( string col, dur dr, float freq, int harm ) {
        if ( col == "sin" ) {
            bh => e;
            freq => bh.freq;
            harm => bh.harmonics;
        }
        else {
            if ( col == "tri" ) {
                bq => e;
                freq => bq.freq;
                harm => bq.harmonics;
            }
            else { bs => e; freq => bs.freq; harm => bs.harmonics; }
        }
        e.keyOn();
        dr * 0.7 => now;
        e.keyOff();
        dr * 0.3 => now;
        if ( col == "sin" ) { bh =< e; }
        else{
            if ( col == "tri" ) { bq =< e; } else { bs =< e; }
        }
    }
}
