// This class produces sounds with STK Instruments

public class ColorInst {
    BandedWG bw;
    Shakers sh;
    ModalBar mb;
    Gain g => Pan2 pan;

    public void set( float ga, int sig, int pos, float halfwidth ) {
        ga * 0.9 => g.gain;
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

    public void trig_bw( dur dr, float b_press, float b_mot, float b_rate, float st_pos, int preset, float freq ) {
        bw => g;
        ( b_press + 1.0 ) / 2.0 => bw.bowPressure;
        ( b_mot + 1.0 ) / 2.0 => bw.bowMotion;
        ( b_rate + 1.0 ) / 2.0 => bw.bowRate;
        st_pos => bw.strikePosition;
        preset => bw.preset;
        freq => bw.freq;
        bw.startBowing( b_press );
        dr => now;
        bw.stopBowing( b_mot );
        dr / 10 => now;
        bw =< g;
    }

    public void trig_sh( dur dr, int preset, float energy, float decay, float objects, float freq ) {
        sh => g;
        preset => sh.preset;
        ( energy + 1.0 ) / 2.0 => sh.energy;
        decay => sh.decay;
        objects => sh.objects;
        freq => sh.freq;
        sh.noteOn(1);
        dr => now;
        sh.noteOff(1);
        dr / 10 => now;
        sh =< g;
    }

    public void trig_mb( dur dr, float st_hard, float st_pos, float vib_freq, float vib_gain, int preset, int mode, float freq ) {
        mb => g;
        g.gain() => mb.volume;
        ( st_hard + 1.0 ) / 2.0 => mb.stickHardness;
        st_pos => mb.strikePosition;
        vib_freq => mb.vibratoFreq;
        vib_gain => mb.vibratoGain;
        preset => mb.preset;
        1.0 => mb.volume;
        mb.strike(1);
        dr => now;
        dr / 10 => now;
        mb =< g;
    }
}
