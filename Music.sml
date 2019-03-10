(* ML music *)

structure Music :> Music = struct 

(* a pitch is a note and an octave *)
datatype pitch = A of int | B of int | C of int | D of int | E of int | F of int | G of int

exception MalformedPitch of char * int

(* smart constructor for pitches: notes are A-G, octaves are 0-8 *)
fun mkpitch (note, octave) = 
    if octave < 0 orelse octave > 8 then raise MalformedPitch (note, octave) else
    let val conv = 
        (fn #"a" => A | #"b" => B | #"c" => C | #"d" => D
	  | #"e" => E | #"f" => F | #"g" => G
	  | x => raise MalformedPitch (x, octave))
    in conv note octave
    end

val PITCH = mkpitch

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
  | TRIPLET of rhythm_note * rhythm_note * rhythm_note

datatype rhythm 
  = RHYTHM of rhythm_note
  | TIE of rhythm_note * rhythm

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
  | val_of (TRIPLET (n1, n2, n3)) = 
    2.0 * ((val_of n1 + val_of n2 + val_of n3) / 3.0)
  | val_of (DOTTED n) = 
      let fun sum_dots (DOTTED n) x = sum_dots n (x + 1)
            | sum_dots n x = val_of n * half_sigma_geo_series_to x
      in sum_dots n 1
      end 

fun bar_invariant (BAR (_, (num,den), xs)) =
  let fun sum_durations (RHYTHM r, total) = val_of r + total
        | sum_durations (TIE(r, tied), total) = sum_durations (tied, total + val_of r)
  in List.foldl sum_durations 0.0 xs = real num / real den
  end

val validate_bars = List.all bar_invariant

exception MalformedSong

fun validate_song (SONG (_, xs)) = 
    if validate_bars xs then () 
    else raise MalformedSong

(* ---------------------------------------------- *)



end