include "constants.inc"

section "Collisions System", ROM0

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
are_intervals_overlapping::
    ; p1 - p2
    ld   a, [bc]
    ld   h, a     ; p1 ->  b
    ld   a, METASPRITE_DIMENSIONS  ; w1 ->  a
    add  h
    ld   h, a     ; p1 + w1 ->  b
    ld   a, [de]  ; p2 ->  a
    cp h

    ret c

    ; p2 - p1
    ld   a, [de]
    ld   h, a       ; p2 ->  b
    ld   a, METASPRITE_DIMENSIONS  ; w2 ->  a
    add  h
    ld   h, a       ; p2 + w2 ->  b
    ld   a, [bc]    ; p1 ->  a
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
;; Address |BC| +1|     |DE| +1|
;; Values  [y1][x1] ....[y2][x2]
;;
;; Returns Carry Flag (C=0, NC) when NOT colliding,
;; and (C=1, C) when colliding.
;;
;; 📥 INPUT:
;; BC: Address of AABB 1
;; DE: Pointer of AABB 2
;; 🔙 OUTPUT:
;; Carry: { NC: Not colliding } { C: colliding }
are_boxes_colliding::
    ; Check for y
    call are_intervals_overlapping
    ret nc
    ; Check for x
    inc bc
    inc bc
    inc de
    inc de
    call are_intervals_overlapping
ret
