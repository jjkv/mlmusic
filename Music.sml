(* ML music *)

structure Music :> Music = struct 

(* a pitch is a note letter and an octave *)
datatype pitch = P of char * int

exception MalformedPitch of char * int

fun mkpitch (ltr, oct) =
    let val verif_l = (fn x => x > 64 andalso x < 72) o Char.ord o Char.toUpper 
        val verif_o = (fn x => x > ~1 andalso x < 10)
    in if verif_l ltr andalso verif_o oct then P (Char.toUpper ltr, oct)
       else raise MalformedPitch (ltr, oct)
    end

val PITCH = mkpitch

datatype accidental 
  = NATURAL of pitch
  | SHARP of pitch
  | FLAT of pitch
  | DOUBLESHARP of pitch
  | DOUBLEFLAT of pitch

val ptc_of_acd = (fn NATURAL x => x | SHARP x => x | FLAT x => x | DOUBLESHARP x => x | DOUBLEFLAT x => x) 
val modif_of_acd = (fn NATURAL _ => 0 | SHARP _ => 1 | FLAT _ => ~1 | DOUBLESHARP _ => 2 | DOUBLEFLAT _ => ~2) 

datatype note 
  = REST
  | NOTE of accidental
  | CHORD of accidental list

fun acds_of_note REST = NONE
  | acds_of_note (NOTE n) = SOME [n]
  | acds_of_note (CHORD ns) = SOME ns    		

val examine_note_with = fn f => List.map f o (fn x => getOpt (x, [])) o acds_of_note
val pitches_of_note = examine_note_with ptc_of_acd
val modif_of_note = examine_note_with modif_of_acd

val pitches_with_modif = ListPair.zipEq o (fn n => (pitches_of_note n, modif_of_note n))

datatype rhythm_unit
  = WHOLE of note
  | HALF of note
  | QUARTER of note
  | EIGHTH of note
  | SIXTEENTH of note
  | DOTTED of rhythm_unit

fun note_of_ru (WHOLE x) = x 
  | note_of_ru (HALF x) = x 
  | note_of_ru (QUARTER x) = x 
  | note_of_ru (EIGHTH x) = x 
  | note_of_ru (SIXTEENTH x) = x 
  | note_of_ru (DOTTED ru) = note_of_ru ru

val pitches_of_ru = pitches_with_modif o note_of_ru

datatype rhythm 
  = RHYTHM of rhythm_unit
  | TRIPLET of rhythm_unit * rhythm_unit * rhythm_unit
  | TIE of rhythm_unit * rhythm

fun pitches_of_rhythm (RHYTHM ru) = pitches_of_ru ru
  | pitches_of_rhythm (TRIPLET (a,b,c)) =
    (List.concat o List.map pitches_of_ru) [a,b,c]
  | pitches_of_rhythm (TIE (ru, rest)) = 
    pitches_of_ru ru @ pitches_of_rhythm rest

type meter = int * int

exception IllegalMeter of int * int
val METER = fn (n, d) =>
    if n < 1 then raise IllegalMeter (n, d) else
    let val legal = [1,2,4,8,16]
    in (case List.find (fn d' => d' = d) legal
          of NONE => raise IllegalMeter (n, d)
	   | SOME _ => (n, d))
    end

type tempo = int

exception NegativeTempo of int
val BPM = fn n => if n > 0 then n else raise NegativeTempo n 

type tempochange = tempo option

datatype measure = BAR of tempochange * meter * rhythm list

val MEASURE = BAR

datatype music = SONG of tempo * measure list

(*
type title = string
type name = string
type last = name
type first = name
type composer = last * first (* looks better with mandatory comma separater *)

datatype score = SCORE of title * composer * music
*)

fun power b e = if e = 0 then 1.0 else b * power b (e - 1)
val half_to_the = power 0.5

fun half_sigma_geo_series_to 0 = half_to_the 0
  | half_sigma_geo_series_to n = half_to_the n + half_sigma_geo_series_to (n - 1)

fun val_of (WHOLE     _) = 1.0
  | val_of (HALF      _) = 0.5
  | val_of (QUARTER   _) = 0.25
  | val_of (EIGHTH    _) = 0.125
  | val_of (SIXTEENTH _) = 0.0625
  | val_of (DOTTED n) = 
      let fun sum_dots (DOTTED n) x = sum_dots n (x + 1)
            | sum_dots n x = val_of n * half_sigma_geo_series_to x
      in sum_dots n 1
      end 

exception Unimplemented
fun note_events (r : rhythm) : Midi.midi_data  = 
    let fun translate_reps (P (chr, oct), 0) = (NONE, chr, oct)
          | translate_reps (P (chr, oct), m) = (SOME m, chr, oct)
        fun conv (RHYTHM r) = 
    	    let val mk_note = Midi.mk_play_note_event (val_of r)
	        val pitches = List.map translate_reps (pitches_of_ru r)
	    in (List.concat o List.map mk_note) pitches
	    end
          | conv (TRIPLET (r1, r2, r3)) = 
	    let val av_dur = 2.0 * ((val_of r1 + val_of r2 + val_of r3) / 3.0)
	        val mk_note = Midi.mk_play_note_event av_dur
		val ps = (List.map (List.map translate_reps) o List.map pitches_of_ru) [r1, r2, r3]
	    in List.foldl (fn (ns, acc) => (List.concat o List.map mk_note) ns @ acc) [] ps
	    end
          | conv _ = raise Unimplemented
    in let val _ = print("note\n") in conv r end 
    end

fun bar_invariant (BAR (_, (num,den), xs)) =
  let fun sum_durations (RHYTHM r, total) = val_of r + total
        | sum_durations (TRIPLET (r1, r2, r3), total) = 
	    let val val' = val_of r1 + val_of r2 + val_of r3
	    in 2.0 * (val' / 3.0) + total end	  
        | sum_durations (TIE(r, tied), total) = sum_durations (tied, total + val_of r)
  in List.foldl sum_durations 0.0 xs = real num / real den
  end

val validate_bars = List.all bar_invariant

exception MalformedSong

fun validate_song (SONG (_, xs)) = 
    if validate_bars xs then () 
    else raise MalformedSong

(* parsing code --------------------------------------------------------------------- *)


(*

val std_trk_cnk_with : int -> midi_data
*)

fun save_as_midi fname (SONG (bpm, bars)) =
    let val header = Midi.std_onetrk_hdr
    	val set_tempo = Midi.mk_tempo_event
	val cur_tempo = ref ((fn (x : int) => x) bpm)
	val set_ts = Midi.mk_timesig_event 
	val (n1, d1) = (fn (BAR (_, (n1,d1), _)) => (n1, d1)) (List.hd bars)
	val cur_meter = ref (n1,d1)
	val init_ts = set_ts n1 d1
	val init_t = set_tempo bpm
	fun update_meter (n, d) = 
	    if (n, d) = (!cur_meter) then [] else
	    let val _ = cur_meter := (n, d)
	    in set_ts n d end
	fun update_tempo bpm' =
	    if bpm' = (!cur_tempo) then [] else
	    let val _ = cur_tempo := bpm'
	    in set_tempo bpm' end
	fun parse (BAR (tc, (n,d), xs), bytes) = 
	    let val _ = print("bar\n")
	    	val m' = update_meter (n, d)
	    	val t' = update_tempo (getOpt (tc, !cur_tempo))
	    	val notes = (List.concat o List.map note_events) xs
	    in bytes @ m' @ t' @ notes
	    end
	val music_data = init_t @ init_ts @ (List.foldl parse [] bars) @ Midi.end_of_trk
	val _ = print("done parsing\n")
	val chk_hdr = Midi.std_trk_cnk_with (List.length music_data)
	val song_data = header @ chk_hdr @ music_data
	val _ = Midi.write_midi_data fname song_data 
    in song_data end

end