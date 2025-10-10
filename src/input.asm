INCLUDE "constants.inc"

SECTION "Input", ROM0

; Runs the input sequence
input::
    call read_input
    call decode_input
    ret

; Checks the Joypad for inputs
read_input:
    ld [rJOYP], a   ;; Seleccionar botones
    ld a, [rJOYP]   ;; Leo el estado de los botones
    ld a, [rJOYP]   ;; Se repite para perder tiempo para dar tiempo a actualizar (motivo electronico)
    ld a, [rJOYP]   ;; Se repite para perder tiempo para dar tiempo a actualizar (motivo electronico)
    ret

; Determines if the input comes from the D-PAD or the Buttons
decode_input:
    bit 4, a
    call z, decode_dpad
    ret
    bit 5, a
    call z, decode_butt
    ret

; TODO
; Decodes Buttons inputs and converts them into actions
decode_butt:
    .right:
        bit 0, a
        jr nz, .left
        ; jp move_right
        ret
    .left:
        bit 1, a
        jr nz, .up
        ; jp move_left
        ret
    .up:
        bit 2, a
        jr nz, .down
        ; jp move_up
        ret
    .down:
        bit 3, a
        jr nz, .exit
        ; jp move_down
        ret
    .exit:
    ret

; Decodes D-PAD inputs and converts them into actions
decode_dpad:
    .right:
        bit 0, a
        jr nz, .left
        jp move_right
        jp gravity
    .left:
        bit 1, a
        jr nz, .up
        jp move_left
        jp gravity
    .up:
        bit 2, a
        jr nz, .down
        jp move_up
    .down:
        bit 3, a
        jr nz, .exit
        jp move_down
        jp gravity
    .exit:
        jp gravity
    ret
