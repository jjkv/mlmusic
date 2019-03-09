structure Midi :> Midi = struct

type acd = int option
type midi_data = word8 list
type note_dur = real
type note = acd * char * int

val MThd = "4d 54 68 64"
val MTrk = "4d 54 72 6b"

val MThdc = String.explode "MThd"
val MTrkc = String.explode "MTrk"

val ppqn = ref 128
val get_ppqn = fn () => !ppqn

val oth_hexstr = MThd ^ " 00 00 00 06 00 00 00 01 00 80"

val byte_of_ascii = Byte.charToByte o Char.chr

exception NotHex of string
fun ascii_of_hexstr s =
    let	val hexchar_to_int =
            (fn #"A" => 10 | #"B" => 11 | #"C" => 12 | #"D" => 13 | #"E" => 14 | #"F" => 15
              | c => if Char.isDigit c then Char.ord c - 48 else raise NotHex s)
    in (case String.explode s 
          of (c1::c2::[]) => 
	     let val conv = hexchar_to_int o Char.toUpper
	     in 16 * conv c1 + conv c2 end              
           | _ => raise NotHex s)
    end

val byte_of_hexstr = byte_of_ascii o ascii_of_hexstr

val hexstrs_of_str = String.tokens (not o Char.isHexDigit)

val bytes_of_str = List.map byte_of_hexstr o hexstrs_of_str

fun mkputChar fd = fn c => BinIO.output1 (fd, c) handle e => (BinIO.closeOut fd; raise e)

fun writeBytes fname bs = 
    let val fd = BinIO.openOut fname
    	val pc = mkputChar fd
	val _ = List.map pc bs
    in BinIO.closeOut fd end

fun write_chars fname = writeBytes fname o (List.map Byte.charToByte)

val twinkle = "4d         54 68 64 00 00 00 06 00 00 00 01 00 80 4d 54 72 6b 00 00 00 8c 00 ff 58 04 04 02 30 08 00 ff 59 02 00 00 00 90 3c 28 81 00 90 3c 00 00 90 3c 1e 81 00 90 3c 00 00 90 43 2d 81 00 90 43 00 00 90 43 32 81 00 90 43 00 00 90 45 2d 81 00 90 45 00 00 90 45 32 81 00 90 45 00 00 90 43 23 82 00 90 43 00 00 90 41 32 81 00 90 41 00 00 90 41 2d 81 00 90 41 00 00 90 40 32 40 90 40 00 40 90 40 28 40 90 40 00 40 90 3e 2d 40 90 3e 00 40 90 3e 32 40 90 3e 00 40 90 3c 1e 82 00 90 3c 00 00 ff 2f 00"

(* public members *)

val std_onetrk_hdr = bytes_of_str oth_hexstr

fun write_midistr fname = writeBytes fname o List.map byte_of_hexstr o hexstrs_of_str

(* - - - - - - - -  -- - - - - -  - - --  -- -   - - --- -- -- - - - - - - *)

(* MIDI consts *)

val MThdc = String.explode "MThd"
val MTrkc = String.explode "MTrk"

val meta_sig = byte_of_hexstr "ff"

fun pow b e = if e = 0 then 1 else b * pow b (e - 1)
fun log b n = if n < b then 0 else 1 + log b (n div b)

fun mk_timesig_event num den = 
    let val ident = bytes_of_str "ff 58 04"
        val nn = byte_of_ascii num
        val dd = byte_of_ascii (log 2 den)
    	val cc = byte_of_ascii (24 * (4 div den))
	val bb = byte_of_ascii 8
    in ident @ [nn, dd, cc, bb]
    end

fun bytes_of_int n =    
    if n < 16 then [byte_of_ascii n]
    else byte_of_ascii (n mod 256) :: bytes_of_int (n div 256) 

val byte_to_str = Char.toString o Byte.byteToChar
    
fun mk_tempo_event bpm = 
    let val ident = bytes_of_str "ff 51 03"
    	val usec_per_beat = Real.floor (60000000.0 / (Real.fromInt bpm))
    	val z = byte_of_ascii 0
	fun pad [] = [z,z,z]
	  | pad (b::[]) = [z,z,b]
	  | pad (b1::b2::[]) = [z,b1,b2]
	  | pad (b1::b2::b3::_) = [b1,b2,b3]
    	val tttttt = (pad o List.rev o bytes_of_int) usec_per_beat
    in ident @ tttttt end

fun curry f x y = f (x, y)
fun flip f x y = f y x
    
exception NotNote of char * int * int
val base_note_val = 
    (fn #"A" => 21 | #"B" => 23 
      | #"C" => 12 | #"D" => 14 
      | #"E" => 16 | #"F" => 17
      | #"G" => 19 | x => raise NotNote (x, ~1, ~1))

fun note_val a (n, oct) =
    let	val range_check = fn (l, u) => fn x => x >= l andalso x <= u 
        val note_check = range_check (65, 71) o Char.ord o Char.toUpper
        val oct_check = range_check (0, 8)
	val acd_val = fn a => getOpt (a, 0)
	val acd_check = range_check (~3, 3) o acd_val
    in if acd_check a andalso note_check n andalso oct_check oct
       then ((base_note_val o Char.toUpper) n + acd_val a) + (12 * oct)
       else raise NotNote (n, oct, acd_val a)
    end

fun note_event modif chan veloc note = List.map byte_of_ascii [modif + chan, note, veloc]

val std_noteon = note_event 144 0 64
val std_noteoff = note_event 128 0 64

val noteon_data = fn a => std_noteon o note_val a
val noteoff_data = fn a => std_noteoff o note_val a

val dt_of_dec = byte_of_ascii o Real.floor o (fn x => Real.fromInt (!ppqn) * 4.0 * x) 

fun mk_note_event b dur (a, c, oct) = 
    let val time = [dt_of_dec dur]
    	val onoroff = if b then noteon_data else noteoff_data
    in time @ onoroff a (c, oct) end

fun mk_play_note_event dur (a, c, oct) =
    let val on = mk_note_event true 0.0 (a, c, oct)
    	val off = mk_note_event false dur (a, c, oct)
    in on @ off end

end