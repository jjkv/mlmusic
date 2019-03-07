open Music

val g3 = NATURAL(PITCH(#"g", 3))
val d4 = NATURAL(PITCH(#"d", 4))
val c4 = NATURAL(PITCH(#"c", 4))
val b3 = NATURAL(PITCH(#"b", 3))
val a3 = NATURAL(PITCH(#"a", 3))

val mkrn = fn v => RHYTHM o v o NOTE

val mkhalf = mkrn HALF
val mkeighth = mkrn EIGHTH
val mksixteenth = mkrn SIXTEENTH

val rl1 = [mkhalf g3, mkhalf d4, mkeighth c4, mksixteenth b3, mksixteenth a3]

val m1 = MEASURE(NONE, METER(5,4), rl1)
val onetwenty = BPM 120

val s = SONG(onetwenty, [m1])

val _ = validate_song s