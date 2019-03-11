open Music

val g3 = NATURAL(PITCH(#"g", 3))
val d4 = NATURAL(PITCH(#"d", 4))
val c4 = NATURAL(PITCH(#"c", 4))
val b3 = NATURAL(PITCH(#"b", 3))
val a3 = NATURAL(PITCH(#"a", 3))
val g4 = NATURAL(PITCH(#"g", 4))

val mkrn = fn v => RHYTHM o v o NOTE
val mkrst = fn v => (RHYTHM o v) REST

val mkhalf = mkrn HALF
val mkquarter = mkrn QUARTER
val mkeighth = mkrn EIGHTH
val mksixteenth = mkrn SIXTEENTH
val mkwhole = mkrn WHOLE

val mktr = fn v => fn (p1, p2, p3) => TRIPLET (v p1, v p2, v p3)
val mk8trip = mktr (EIGHTH o NOTE)

val dananuh = mk8trip (c4, b3, a3)
val danana = mk8trip (c4, b3, c4)
val daaaaaa = mkhalf g4
val daaa = mkquarter d4
 
val rl1 = [mkhalf g3, mkhalf d4, dananuh]
val rl2 = [daaaaaa, daaa, dananuh]
val rl3 = [daaaaaa, daaa, danana]
val rl4 = [mkwhole a3]

val m1 = MEASURE(NONE, METER(5,4), rl1)
val mk44bar = fn rl => MEASURE(NONE, METER(4,4), rl)
val two_three_four = List.map mk44bar [rl2, rl3, rl4]

val onetwenty = BPM 120

val head = [m1] @ two_three_four

val s = SONG(onetwenty, head)

val _ = validate_song s

val xs = save_as_midi "starwars.midi" s