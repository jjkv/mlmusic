signature Music = sig
 
    type pitch 
    val PITCH : char * int -> pitch

    datatype accidental 
     = NATURAL of pitch
     | SHARP of pitch
     | FLAT of pitch
     | DOUBLESHARP of pitch
     | DOUBLEFLAT of pitch

    datatype note 
     = REST
     | NOTE of accidental
     | CHORD of accidental list

    datatype rhythm_note 
     = WHOLE of note
     | HALF of note
     | QUARTER of note
     | EIGHTH of note
     | SIXTEENTH of note
     | DOTTED of rhythm_note

    datatype rhythm 
     = RHYTHM of rhythm_note
     | TRIPLET of rhythm_note * rhythm_note * rhythm_note
     | TIE of rhythm_note * rhythm

    type meter
    val METER : int * int -> meter
    
    type tempo
    val BPM : int -> tempo
    
    type tempochange = tempo option

    type measure
    val MEASURE : tempochange * meter * rhythm list -> measure

    type music
    val SONG : tempo * measure list -> music

    val bar_invariant : measure -> bool

    val validate_song : music -> unit
end