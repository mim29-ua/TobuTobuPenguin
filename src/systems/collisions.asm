include "constants.inc"

section "Collisions System Variables", WRAM0

pixels_offset_1: ds 1
pixels_offset_2: ds 1

section "Collisions System", ROM0

;; Sets the appropiate Y pixels offset (w) for each movement
;;
;; READS:
;;      actual_movement
;; OUTPUT:
;;      a -> pixels offset
load_pixels_offset_for_Y_into_a:
    ld a, [actual_movement]

    .down:
        cp DOWN
    jr nz, .up
        ld a, DIRECTIONAL_PIXELS_OFFSET
        ld [pixels_offset_1], a
        ld a, NON_DIRECTIONAL_PIXELS_OFFSET
        ld [pixels_offset_2], a
    ret

    .up:
        cp UP
    jr nz, .left
        ld a, NON_DIRECTIONAL_PIXELS_OFFSET
        ld [pixels_offset_1], a
        ld a, DIRECTIONAL_PIXELS_OFFSET
        ld [pixels_offset_2], a
    ret

    .left:
        cp LEFT
    jr nz, .right
        ld a, NON_DIRECTIONAL_PIXELS_OFFSET
        ld [pixels_offset_1], a
        ld [pixels_offset_2], a
    ret

    .right:
        cp RIGHT
    ret nz
        ld a, NON_DIRECTIONAL_PIXELS_OFFSET
        ld [pixels_offset_1], a
        ld [pixels_offset_2], a
ret

;; Sets the appropiate X pixels offset (w) for each movement
;;
;; READS:
;;      actual_movement
;; OUTPUT:
;;      a -> pixels offset
load_pixels_offset_for_X_into_a:
    ld a, [actual_movement]

    .down:
        cp DOWN
    jr nz, .up
        ld a, NON_DIRECTIONAL_PIXELS_OFFSET
        ld [pixels_offset_1], a
        ld [pixels_offset_2], a
    ret

    .up:
        cp UP
    jr nz, .left
        ld a, NON_DIRECTIONAL_PIXELS_OFFSET
        ld [pixels_offset_1], a
        ld [pixels_offset_2], a
    ret

    .left:
        cp LEFT
    jr nz, .right
        ld a, NON_DIRECTIONAL_PIXELS_OFFSET
        ld [pixels_offset_1], a
        ld a, DIRECTIONAL_PIXELS_OFFSET
        ld [pixels_offset_2], a
    ret

    .right:
        cp RIGHT
    ret nz
        ld a, DIRECTIONAL_PIXELS_OFFSET
        ld [pixels_offset_1], a
        ld a, NON_DIRECTIONAL_PIXELS_OFFSET
        ld [pixels_offset_2], a
ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Checks if two integral intervals overlap in one dimension
;; It receives the addresses of 2 intervals in memory
;; in BC and DE:
;;
;; Address |BC|       |DE|
;; Values  [p1] ......[p2]
;;
;; Returns Carry Flag (C=0, NC) when NOT-Colliding,
;; and (C=1, C) when overlapping.
;;
;; 📥 INPUT:
;; BC: Address of Interval 1 (p1, w1)
;; DE: Address of Interval 2 (p2, w2)
;; 🔙 OUTPUT:
;; Carry: { NC: No overlap }, { C: Overlap }
are_intervals_overlapping:
    ; call load_pixels_offset_into_a

    ; p1+w1 >= p2
    ld   a, [bc]
    ld   h, a                     ; p1 ->  h
    ld   a, [pixels_offset_1]       ; w1 ->  a
    add  h
    ld   h, a                     ; p1 + w1 ->  h
    ld   a, [de]                  ; p2 ->  a
    cp h

    ret nc

    ; p1 <= p2+w2
    ld   a, [de]
    ld   h, a                     ; p2 ->  h
    ld   a, [pixels_offset_2]       ; w2 ->  a
    add  h
    ld   h, a                     ; p2 + w2 ->  h
    ld   a, [bc]                  ; p1 ->  a
    cp h
ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Checks if two Axis Aligned Bounding Boxes (AABB) are
;; colliding.
;; 1. First, checks if they collide on the Y axis
;; 2. Then checks the X axis, only if Y intervals overlap
;;
;; Receives in DE and BC the addresses of two AABBs:
;; --AABB 1-- --AABB 2--
;; Address |BC|+1|+2|     |DE|+1|+2|
;; Values  [y1][][x1] ....[y2][][x2]
;;
;; Returns Carry Flag (C=0, NC) when NOT colliding,
;; and (C=1, C) when colliding.
;;
;; 📥 INPUT:
;; BC: Address of AABB 1
;; DE: Pointer of AABB 2s
;; 🔙 OUTPUT:
;; Carry: { NC: Not colliding } { C: colliding }
are_boxes_colliding::
    ; We're getting the info cmp address,
    ; but we want the sprite cmp address
    ld b, CMP_SPRITE_H
    ld c, 0
    ld d, CMP_SPRITE_H

    ; Check for y
    call load_pixels_offset_for_Y_into_a
    call are_intervals_overlapping
    ret nc

    ; Check for x
    inc bc
    inc de
    call load_pixels_offset_for_X_into_a
    call are_intervals_overlapping
ret
