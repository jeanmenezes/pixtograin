fun Pixel[] generatePixelValues() {
    OscIn recv;
    6172 => recv.port;
    OscMsg oe2;

    Pixel pix[0];

    recv.addAddress( "/hsl, i i f f f i" );

    0 => int count;
    -1 => int prevcount;
    recv => now;

    while ( count != prevcount ) {
        while ( recv.recv( oe2 ) ) {
            oe2.getInt(0) => int x;
            oe2.getInt(1) => int y;
            oe2.getFloat(2) => float h;
            oe2.getFloat(3) => float s;
            oe2.getFloat(4) => float v;
            oe2.getInt(5) => int sig;
            count => prevcount;
            if ( x >= 0 ) {
                pix << new Pixel;
                pix[count].set( x, y, h, s, v, sig );
                count++;
            }
        }
    }
    return pix;
}

fun void playPixels( Pixel pixels[], int totalpixels, int maxx, float zoom, float pitch_window ) {
    me.sourceDir() + "/rec-auto-stereo.ck:pixels:" + zoom => string recfile;
    Machine.add( recfile ) => int rec;
    string osctype;
    0 => int i;
    while ( i < totalpixels ) {
        pixels[i].print();
        pixels[i].playForPixels( totalpixels, pixels[i].osctype, maxx, zoom, pitch_window );
        i++;
    }
    .5::second => now;
    Machine.remove( rec );
}

fun void playTimbre( Pixel pixels[], int totalpixels, int maxx, float zoom, float pitch_window ) {
    me.sourceDir() + "/rec-auto-stereo.ck:timbre:" + zoom => string recfile;
    Machine.add( recfile ) => int rec;
    string osctype;
    0 => int i;
    ( second / samp ) / 2 => float nyq;
    while ( i < totalpixels ) {
        spork ~ pixels[i].playForTimbre( totalpixels, pixels[i].osctype, maxx, zoom, nyq );
        i++;
    }
    zoom::second => now;
    Machine.remove( rec );
}

fun void playControl( Pixel pixels[], int totalpixels, int maxx, float zoom, float pitch_window ) {
    me.sourceDir() + "/rec-auto-stereo.ck:control:" + zoom => string recfile;
    Machine.add( recfile ) => int rec;
    0 => int i;
    while ( i < totalpixels ) {
        pixels[i].playForControl( totalpixels, maxx, zoom, pitch_window );
        i++;
    }
        .5::second => now;
   Machine.remove( rec );
}

me.arg(0) => string intent;
me.arg(1).toFloat() => float z;
me.arg(2).toFloat() => float pw;

fun void main( string intent, float zoom, float pitch_window ) {
    generatePixelValues() @=> Pixel pixels[];
    pixels.cap() => int totalpixels;
    pixels[totalpixels-1].x => int maxx;
    if ( intent == "additive" ) {
        playPixels( pixels, totalpixels, maxx, zoom, pitch_window );
        2::second => now;
        playTimbre( pixels, totalpixels, maxx, zoom, pitch_window );
    }
    else {
        if ( intent == "control" ) { playControl( pixels, totalpixels, maxx, zoom, pitch_window ); }
        else { <<<"wrong parameter", intent>>>; me.exit(); }
    }
}

main( intent, z, pw );
