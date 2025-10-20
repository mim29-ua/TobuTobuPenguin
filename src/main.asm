include "constants.inc"

section "Entry point", ROM0[$150]

main::
    call man_entity_init
    call space_scene_init
    call space_scene_run
        
    di     ;; Disable Interrupts
    halt   ;; Halt the CPU (stop procesing here)
