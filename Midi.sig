signature Midi = sig
    
    type acd
    type midi_data
    type note_dur
    type note 

    (* type 0 midi file *)
    val std_onetrk_hdr : midi_data

    (* takes a beats per minute tempo as int *)    
    val mk_tempo_event : int -> midi_data

    val mk_timesig_event : int -> int -> midi_data

    (* returns 2 events, on and off *) 
    val mk_play_note_event : note_dur -> note -> midi_data

end