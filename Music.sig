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

    datatype rhythm_unit
     = WHOLE of note
     | HALF of note
     | QUARTER of note
     | EIGHTH of note
     | SIXTEENTH of note
     | DOTTED of rhythm_unit

    datatype rhythm 
     = RHYTHM of rhythm_unit
     | TRIPLET of rhythm_unit * rhythm_unit * rhythm_unit
     | TIE of rhythm_unit * rhythm

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

    val save_as_midi : string -> music -> word8 list

end
