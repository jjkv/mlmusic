exception Unimplemented
fun vlq_of_int n = 
    let val cut = Word.fromInt 128
    	val mask = Word.fromInt 127
	val chop = fn w => Word.>> (w, Word.fromInt 7)
        fun conv v bytes =
	    if v < cut then Word.andb (v, mask) :: bytes
	    else conv (chop v) (Word.orb (Word.andb (v, mask), cut) :: bytes)
    in (case (conv (Word.fromInt n) [])
       	  of x::y::[] => [x + y, Word.fromInt 0]
	   | x => x)
    end

fun vlq n = 
    let val w = Word.fromInt
    	val a = Word.>> (w n, w 7)
	val b = Word.andb (w n, w 127)
	fun aux n acc = 
	    let val x = Word.orb (Word.andb (n, w 127), w 128)
	    	val xs = Word.>> (n, w 7)
	    in if xs > (w 0) then aux xs (x::acc)
	       else x::acc
	    end
    in if n < 128 then [w n, w 0] 
       else aux a [b] 
    end

fun conv n = if n < 128 then [n mod 128] else (n mod 128) :: conv (n div 256) 
