val c3 = Music.PITCH(#"c", 3)
val e3 = Music.PITCH(#"e", 3)
val g3 = Music.PITCH(#"g", 3)
val c4 = Music.PITCH(#"c", 4)

val mkquarter = Music.RHYTHM o Music.QUARTER o Music.NOTE o Music.NATURAL

val cmaj_arp = Music.MEASURE(NONE, Music.METER(4,4), List.map mkquarter [c3,e3,g3,c4])

val onetwenty = Music.BPM 120

val s = Music.SONG (onetwenty, [cmaj_arp])

val _ = Music.validate_song s