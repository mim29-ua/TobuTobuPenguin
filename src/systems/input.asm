include "constants.inc"

section "Input Variables", WRAM0

last_input: ds 1

;; Movement being performed during the current game loop
;;
;; Possible values:
;;      0 -> Down
;;      1 -> Up
;;      2 -> Left
;;      3 -> Right
actual_movement: ds 1

section "Input", ROM0

;; Hardware dpad OR buttons reading
;;
;; INPUT:
;;      a -> dpad/buttons selection for reading
;; OUTPUT:
;;      a -> dpad/buttons inputs
read_pad:
    ldh [rP1], a
    ldh a, [rP1]
    ldh a, [rP1]
    ldh a, [rP1]
ret

;; Gets ALL/BOTH dpad and Buttons inputs and
;;
;; OUTPUT:
;;      last_input -> All pad inputs together. Ex. (D-PAD) -> 1011, (BTN) -> 1110
;;      b -> All pad inputs together. Ex. (D-PAD) -> 1011, (BTN) -> 1110
get_pad_input::
    ; Read the D-PAD
    ld a, P1F_GET_DPAD
    call read_pad

    ; Put the D-PAD input into (b)'s high nibble
    swap a      ; Ex. 1111 1011 -> 1011 1111
    and a, $F0  ; Ex. 1011 1111 and 1111 0000 -> 1011 0000
    ld b, a     ; Ex. 1011 0000

    ; Read the buttons
    ld a, P1F_GET_BTN
    call read_pad

    ; Merge the buttons' input into (b)'s low nibble
    and a, $0F  ; Ex. 1111 1110 and 0000 1111 -> 0000 1110
    or a, b     ; Ex. 1011 0000 or 0000 1110 -> 1011 1110
    ld b, a     ; Ex. (D-PAD) -> 1011, (BTN) -> 1110
    ld [last_input], a
ret

;; Loops until a pad input is detected
press_to_start::
    call get_pad_input
    cp $FF
    call nz, main
    jr press_to_start
ret

;; Loops until the start button is pressed
press_start_to_start::
    call get_pad_input
    bit PADB_START, a
    call z, main
    jr press_start_to_start
ret
