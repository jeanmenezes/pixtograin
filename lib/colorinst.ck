// This class produces sounds with STK Instruments

public class ColorInst {
    Moog mo;
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

    public void trig_mo( dur dr, float fq, float fsr, float vib_freq, float vib_gain, float after, float freq ) {
        mo => g;
        ( fq + 1.0 ) / 2.0 => mo.filterQ;
        ( fsr + 1.0 ) / 2.0 => mo.filterSweepRate;
        ( vib_gain + 1.0 ) / 2.0 => mo.vibratoGain;
        vib_freq => mo.vibratoFreq;;
        after => mo.afterTouch;
        freq => mo.freq;
        1 => mo.noteOn;
        dr => now;
        1 => mo.noteOff;
        dr / 10 => now;
        mo =< g;
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
        mb.damp(1);
        dr / 10 => now;
        mb =< g;
    }
}
