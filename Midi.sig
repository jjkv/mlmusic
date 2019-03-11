signature Midi = sig
    
    type acd = int option
    type note = acd * char * int 
    type midi_data = word8 list

    (* type 0 midi file *)
    val std_onetrk_hdr : midi_data

    val std_trk_cnk_with : int -> midi_data

    (* takes a beats per minute tempo as int *)    
    val mk_tempo_event : int -> midi_data

    val mk_timesig_event : int -> int -> midi_data

    (* returns 2 events, on and off *) 
    val mk_play_note_event : real -> note -> midi_data

    val end_of_trk :  midi_data

    val write_midi_data : string -> midi_data -> unit

end