;; divides A by n
;; X = A / n
;; A = A % n
.MACRO divmod n
    LDX #$00
  :
    CMP n
    BCC :+
    INX
    SBC n
    JMP :-
  :
.ENDMACRO
