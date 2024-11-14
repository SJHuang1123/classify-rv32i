.globl mul
.text

mul:
    # prolouge
    addi    sp, sp, -16
    sw      s0, 12(sp)
    sw      s1, 8(sp)
    sw      s2, 4(sp)
    sw      s3, 0(sp)

    li      s0, 0 # store shifted a0
    li      s1, 0 # ans
    li      s2, 0 # counter
mul_loop:
    beq     a1, zero, epi
    andi    s3, a1, 1
    beq     s3, zero, next_iter_mul
    sll     s0, a0, s2
    add     s1, s1, s0
next_iter_mul:
    srli    a1, a1, 1
    addi    s2, s2, 1
    j       mul_loop
epi:
    # epilouge
    mv      a0, s1
    lw      s0, 12(sp)
    lw      s1, 8(sp)
    lw      s2, 4(sp)
    lw      s3, 0(sp)
    addi    sp, sp, 16
    jr      ra
