INCLUDE "constants.inc"

SECTION "Input", ROM0

read_pad:
    ldh [rP1], a
    ldh a, [rP1]
    ldh a, [rP1]
    ldh a, [rP1]
    ret

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
    ld b, a; Ex. (D-PAD) -> 1011, (BTN) -> 1110

    ret

