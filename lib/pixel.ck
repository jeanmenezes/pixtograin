// Main Pixel class. Stores HSV values from the image
// and triggers sounds from them (using ColorOsc/ColorInst).

public class Pixel {
    int x;
    int y;
    float h;
    float s;
    float v;
    string osctype;
    int sig;

    public void set(int xx, int yy, float hh, float ss, float vv, int sign) {
        xx => x;
        yy => y;
        hh => h;
        ss => s;
        vv => v;
        sign => sig;
        if ( h <= ( 1.0 / 3 ) ) { "sin" => osctype; }
        else {
            if ( h > ( 1.0 / 3 ) && h <= ( 2.0 / 3 ) ) { "tri" => osctype; }
            else { "saw" => osctype; }
        }
    }

    public void print() {
        <<<x,y,h,s,v,sig,osctype>>>;
    }

    public void playForPixels( int totalpixels, string osctype, int maxx, float zoom, float pitch_window ) {
        ColorOsc p;
        ( ( s + v ) * ( 40 * zoom ) )::ms => dur dura;
        maxx / 2.0 => float half;
        p.set( v, ( dura / 20 ) , sig, x, half );
        h * pitch_window => float freq;
        ( ( s * pitch_window ) % 12 )$int => int harm;
        p.connect( dac );
        p.trig( osctype, dura, freq, harm );
        p.disconnect( dac ); 
    }

    public void playForTimbre( int totalpixels, string osctype, int maxx, float zoom, float pitch_window ) {
        ColorOsc p;
        ( ( s + v ) * ( zoom * 1000 ) )::ms => dur dura;
        totalpixels => float gaindiv;
        maxx / 2.0 => float half;
        p.set( ( v / gaindiv ), ( dura / 20 ), sig, x, half );
        h * pitch_window => float freq;
        ( ( s * pitch_window ) % 12 )$int => int harm;
        p.connect( dac );
        p.trig( osctype, dura, freq, harm );
        p.disconnect( dac );
        .5::second => now;
    }

    public void playForControl( int totalpixels, int maxx, float zoom, float pitch_window ) {
        ColorInst p;
        ( ( s + v ) * ( 40 * zoom ) )::ms => dur dura;
        maxx / 2.0 => float half;
        p.set( ( s * v ), sig, x, half );
        p.connect( dac );
        if ( h < ( 1.0 / 3 ) ) {
            ( zoom + ( ( h * pitch_window ) ) % 21 )$int => int h1; ( zoom + ( ( s * pitch_window ) ) % 21 )$int => int h2;
            ( zoom + ( ( h * pitch_window ) ) % 127 )$int => int hh1; ( zoom + ( ( s * pitch_window ) ) % 127 )$int => int hh2;
            p.trig_sh( dura, h1, v, ( h * s ), hh1, ( h * pitch_window ) + 16 );
            p.trig_sh( dura, h2, v, ( h * s ), hh2, ( s * pitch_window ) + 16 );
        }
        else {
            if ( h >= ( 1.0 / 3 ) && h < ( 2.0 / 3 ) ) {
                p.trig_mo( dura, s, v, ( s * pitch_window), v, v, ( h * pitch_window ) + 16 );
                p.trig_mo( dura, s, v, ( h * pitch_window), v, v, ( s * pitch_window ) + 16 );
            }
            else {
                ( zoom + ( ( h * pitch_window ) ) % 9 )$int => int h1; ( zoom + ( ( s * pitch_window ) ) % 9 )$int => int h2;
                ( zoom + ( ( h * pitch_window ) ) % 2 )$int => int hh1; ( zoom + ( ( s * pitch_window ) ) % 2 )$int => int hh2;
                p.trig_mb( dura, s, v, ( h * s * zoom ), ( s * v / 2 ), h1, hh1, ( h * pitch_window ) + 16 );
                p.trig_mb( dura, s, v, ( h * s * zoom ), ( s * v / 2 ), h2, hh2, ( s * pitch_window ) + 16 );
            }
        }
        p.disconnect( dac );
    }
}
