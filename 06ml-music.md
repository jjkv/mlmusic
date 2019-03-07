% Recitation: ML Music
% COMP 105
% ${macro/semester}

<!--
 (jack) thoughts on this document:
   - it's not really suitable for recitation
     - it teaches one thing (constructed data) well, but does not address
       other ML things that may or may not need to be part of the ML recitation
     - not addressed: type signatures, pattern matching, ML syntax
   - excerpts of this might make a good recitation problem, but i worry
     the onboard cost is too high 
     - we could give students an intermediate abstraction and have them build
       the next layer: my picks are (given "accidental", implement note)
       OR (given "note", implement rhythm)
   - this could be a nice take home exercise, and it would free up the recitation
     to cover everything mentioned above (the list of things that this document
     does not cover)
   - i've documented each part of this in the source code (06/music.sml), particularly
     what is supposed to be learned from each step. 
   - if this has no place in the ML recitation, perhaps it is relevant for modules?
   - i would like to write a parser of type SCORE -> unit that plays the song.
     - parsing these is not hard (that's kinda the point of all of this), but
       i have NO idea how to get ML to play sounds, assuming it's possible
 -->

# Representing Complex Data with Algebraic Datatypes

A fundamental problem in computer science is how to represent *things*
from the *World of Ideas*$^{TM}$ in a form the computer can understand.
For some of these *things*, like integers or strings, we have a 1:1 mapping 
from idea to type. Other things need only a simple renaming to make sense
for a computer; for instance, a computer does not know what a "sentence" is,
but it has no problem once we tell it that a sentence is just a sequence of
strings.

However, some ideas, like music, are too complex to be represented with
basic types. Fortunately, we have a tool, called Algebraic Datatypes,
to build these complex representations, possibly from scratch. 

### Part I: Melody

In this problem, we will represent a complex idea, music, using algebraic datatypes. To
get started, let's implement an algebraic datatype for the fundamental
unit of melody, pitch.

A `pitch` is made from a note, one of `A` through `G`, and an octave. 
For instance, we can write "Middle C" (the median key on the grand staff)
as `C 4`. 

 1. Define algebraic datatype `pitch` below:

@    \vspace*{1.3in}
!````
!    **SOLUTION**
!    datatype pitch = A of int | B of int | C of int 
!                   | D of int | E of int | F of int | G of int
!````

<!--
	alternate:

	datatype letter = A | B | C | D | E | F | G
	type octave = int
	datatype pitch = PITCH of letter * octave
	-->

Unfortunately, the letters `A` through `G` don't cover all the pitches! There
are notes in between these lettered notes: the note between `C` and `D` is
called `#C` (pronounced "C Sharp"). In western musical notation, "sharp" is
known as an accidental, where a single accidental modifies the value of a pitch. 
There are five such (reasonable) accidentals: sharp, flat, double sharp, 
double flat, and a fifth called natural, which does not change the value of 
the pitch (thus, "`C` natural" is just `C`). 

 2. Define an algebraic data type that represents notes with accidentals below:

@    \vspace*{1.3in}
!````
!    **SOLUTION**
!    datatype accidental = NATURAL of pitch
!                        | SHARP of pitch
!                        | FLAT of pitch
!                        | DOUBLESHARP of pitch
!                        | DOUBLEFLAT of pitch
!````

Next, let's bring this together by defining type `note`. A note
is either a pitch (with accidental), a collection of accidentals (called a "chord"),
or a "rest", which has no pitch value (in music, a rest represents silence). 

 3. Define `note` below:

@    \vspace*{1.3in}
!````
!    **SOLUTION**
!	 datatype note = REST
!                  | NOTE of accidental
!                  | CHORD of accidental list	
!````


Our abstraction is really coming together, we now have a fairly fleshed out
representation of melody. Let's pause for a moment and write down a melody:

 4. Write a `B` flat major below. `B` flat major is a chord containing 3 notes (a "triad"): `B` flat, `D` natural, and `F` natural.
    Let's write `B` flat major in the third octave, meaning the first note of the chord is `B` flat 3.

@    \vspace*{1.3in}
!````
!    **SOLUTION**
!    val Bbmaj = CHORD [FLAT(B 3), NATURAL(D 3), NATURAL(F 3)]
!````


\newpage
### Part II: Rhythm

On some level, music is just a sequence of pitches (this definition is shared with melody).
However, that's not the whole story; melody says nothing about the duration of a pitch. This
idea is called rhythm. 

The duration of a note is represented by a fraction of a bar (more on this later). 
For instance a "whole note" is a note that extends the full length of a bar,
and is double the length of a "half note". These subdivisions can extend down
in a predictable manner, bottoming out at sixteenth notes (for our purposes).
For example, there are 2 quarter notes in a half note, 4 sixteenth notes in a half
note, 4 quarter notes in a whole note, etc.

A note can also be "dotted". A dotted extends the duration by half its value,
and dots can stack. A dotted half note is equivalent to 3 quarter notes.
A double dotted half note (which is a dotted dotted half note), is the
same length as seven eighth notes. 

 1. Let's add to our definition of music by combining rhythm with melody.
    Define an algebraic datatype `rhythm_note`, which can represent both
    the rhythm *and* melody of a note. 

@    \vspace*{1.3in}
!````
!    **SOLUTION**
!    datatype rhythm_note = WHOLE of note
!                         | HALF of note
!                         | QUARTER of note
!                         | EIGHTH of note
!                         | SIXTEENTH of note
!                         | DOTTED of rhythm_note
!````


The above definition of rhythm is a powerful one, but is still missing
a key feature. Using only dots, we have no way to create a note that
whose duration is equivalent to five eighth notes (try and convince yourself
that this is true). 

We address this problem with the notion of "ties". Two notes can be
tied together such that the duration of two tied notes is the sum
of the individual durations of each note. 

 2. Define datatype `rhythm` using `rhythm_note` to implement possibly tied notes.

@    \vspace*{1.3in}
!````
!    **SOLUTION**
!    datatype rhythm = RHYTHM of rhythm_note
!                    | TIE of rhythm_note * rhythm
!````


If the fundamental unit of melody is a note, the fundamental unit
of rhythm is a "measure" (also called a bar). Each measure has two parts, a "meter"
and a collection of notes. Meter is represented as two numbers:
the first number represents the number of "beats" per bar, and
the second number denotes the type of note that is equal to 
a single beat. For example, the meter $\frac{4}{4}$ means there
are 4 beats per measure, and a quarter note is equivalent to a single
beat (thus exactly four quarter notes, or equivalently, eight eighth notes
fit in a single $\frac{4}{4}$ measure, whereas a single half note and 
a single dotted quarter note fill one bar of $\frac{7}{8}$).

 3. Using `datatype` or `type`, define `measure` below:

@    \vspace*{1.3in}
!````
!    *SOLUTION**
!    type meter = int * int
!    datatype measure = BAR of meter * rhythm list
!````


At last, a piece of music (or song, if you like), is really just a sequence 
of measures and a tempo, which is the number of beats per minute (this must
be an integer).

````
	datatype tempo = BPM of int
	datatype music = SONG of tempo * measure list
````

Using the above, we can use `type` to implement a fully abstracted 
data definition of music, a unit of which is written as a "score". 

````
	type title = string
	type name = string
	type last = name
	type first = name
	type composer = last * first
	datatype score = SCORE of title * composer * measure list
````

 4. *Enrichment* Compose a piece of music using the definition of `score` above.

@    \newpage
!    ````
!    **SOLUTION**
!    (* a short but iconic song *)
!    val bar1 = BAR((3,4), [RHYTHM(DOTTED(HALF(NOTE(NATURAL(C 3)))))])
!    val bar2 = BAR((4,4), [RHYTHM(DOTTED(HALF(NOTE(NATURAL(G 3))))), 
!                           RHYTHM(EIGHTH(REST)), 
!                           RHYTHM(EIGHTH(NOTE(NATURAL(C 4))))])
!    val bar3 = BAR((8,4), [RHYTHM(DOTTED(DOTTED(WHOLE(NOTE(NATURAL(C 3))))), 
!                           RHYTHM(QUARTER(REST)))]) 
!    val bar4 = BAR((4,4), [RHYTHM(EIGHTH(NOTE(NATURAL(E 4)))), 
!                           RHYTHM(DOTTED(DOTTED(HALF(CHORD([FLAT(E 4), NATURAL(G 3)])))))])
!    val bar5 = BAR((4,4), [RHYTHM(WHOLE(REST))])
!
!    val AlsoSprachZarathustra = 
!        SCORE("Also Sprach Zarathustra", 
!              ("Strauss", "Richard"), 
!              SONG((BPM 100), [bar1, bar2, bar3, bar4, bar5]))
!````

!\newpage
### (Enrichment) Part III: Representation Invariants

Over this recitation we've constructed a sophisticated
abstraction by layering increasingly complex ideas 
on top of initially simple data. This is all great,
but the correctness of a given layer depends on the
correctness of the layer below it, and so on. 

When representing complex data, it is key that
all representation invariants are satisfied at any layer.
We will next build a function that verifies the 
sanctity of one level in our abstraction.

Recall our definition of `measure`:

````
    datatype measure = BAR of meter * rhythm list
````

A measure is well formed if the sum of note lengths
within the measure is equal to the length of the
measure as defined by its meter, where the length
of a measure is simply the real number equal to
the meter fraction. Thus the length of a $\frac{4}{4}$
bar is 1, because $4 \div 4 = 1$, and the length of
a single measure of $\frac{7}{8}$ is 0.875. 

 1. First, write function `len_of : fn rhythm_note -> real`,
    which computes the length of a single note. Dotted notes
    are tricky, you'll likely need a helper function. You
    may also use the following:

	`sigma_half_geo_series_to : fn int -> real` 

	`sigma_half_geo_series_to x` computes $\sum_{n=0}^{x} 0.5^n$

    Write `len_of` below:

@\newpage
!````
!    **SOLUTION**
!    
!    fun len_of (WHOLE _) = 1.0
!      | len_of (HALF _) = 0.5
!      | len_of (QUARTER _) = 0.25
!      | len_of (EIGHTH _) = 0.125
!      | len_of (SIXTEENTH _) = 0.0625
!      | len_of (DOTTED n) = 
!        let fun apply_dots (DOTTED n) dots = apply_dots n (dots + 1)
!              | apply_dots n dots = len_of n * half_sigma_geo_series_to dots
!        in apply_dots n 1
!        end
!
!    (* just for fun, an implementation of the helper function *)
!    fun power b e = if e = 0 then 1.0 else b * power b (e - 1)
!    val half_to_the = power 0.5
!
!    fun half_sigma_geo_series_to 0 = half_to_the 0
!      | half_sigma_geo_series_to n = half_to_the n + half_sigma_geo_series_to (n - 1)
!````

 2. Using your decinition of `len_of`, define the invariant function.
    `invariant : fn measure -> bool` returns true iff the representation
     invariant is respected for the input bar. Don't forget about tied notes
     (and to the music theory nerds, don't worry about notes tied between
     measures). There are many good solutions to this problem, but I used
     `List.foldl` and a recursive helper function.

@\newpage
!````
!
!    **SOLUTION**
!
!    fun invariant (BAR ((num,den), xs)) = 
!        let fun sum_lens (RHYTHM r, total) = val_of r + total
!              | sum_lens (TIE(r, tied), total) = sum_lens (tied, total + val_of r)
!        in List.foldl sum_lens 0.0 xs = real num / real den
!        end
!````