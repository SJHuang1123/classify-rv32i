# Assignment 2: Classify
## Part A
### abs.s
Used "sub" instruction to negate number less than 0.
```!asm
abs:
    # Prologue
    ebreak
    # Load number from memory
    lw t0 0(a0)
    bge t0, zero, done
    sub     t0, zero, t0
    sw      t0, 0(a0)

done:
    # Epilogue
    jr ra
```
**test result**
```
test_abs_minus_one (__main__.TestAbs) ... ok
test_abs_one (__main__.TestAbs) ... ok
test_abs_zero (__main__.TestAbs) ... ok

----------------------------------------------------------------------
Ran 3 tests in 1.903s

OK
```
---
### argmax.s
Iterate through elements of the input array, record current maximum in ```t0``` register, store answer in ```t1``` register , used ```t2``` as loop counter and load new element from the array into ```t3```.
```!asm
argmax:
    li t6, 1
    blt a1, t6, handle_error

    lw t0, 0(a0)

    li t1, 0 # index
    li t2, 1 # counter
loop_start:
    bge     t2, a1, end_argmax
    lw      t3, 4(a0)
    ble     t3, t0, loop_handle
    mv      t0, t3
    mv      t1, t2
loop_handle:
    addi    a0, a0, 4
    addi    t2, t2, 1
    j       loop_start
end_argmax:
    mv      a0, t1
    jr      ra
handle_error:
    li a0, 36
    j exit
```

**test result**
```
test_argmax_invalid_n (__main__.TestArgmax) ... ok
test_argmax_length_1 (__main__.TestArgmax) ... ok
test_argmax_standard (__main__.TestArgmax) ... ok

----------------------------------------------------------------------
Ran 3 tests in 1.521s

OK
```
---
### dot.s
Implented a inline multiplication operation to replace the `mul` instruction, which shift multiplier right and shift multiplicand left iteratively, and store the final product in `t0`.
```!asm
    # mul     t0, t2, t3
    li t0,0
mul_loop_start:
    beq t3, zero, mul_loop_end
    andi t6, t3, 1
    beq t6, zero, mul_loop_handle
    add t0, t2, t0

mul_loop_handle:
    slli t2, t2, 1
    srli t3, t3, 1
    j mul_loop_start

mul_loop_end:
```
Bump each vector by $stride \times 4$ (word stride) every iteration.
```!asm
# multiply stride by 4
    slli    a3, a3, 2
    slli    a4, a4, 2
```
bump vector:
```!asm
mul_loop_end:
    add     t4, t0, t4
    add     a0, a0, a3
    add     a1, a1, a4
```
full implementation:
```!asm
dot:
    li t0, 1
    blt a2, t0, error_terminate
    blt a3, t0, error_terminate
    blt a4, t0, error_terminate

    li t4, 0      # ans
    li t1, 0      # counter
    slli    a3, a3, 2
    slli    a4, a4, 2
loop_start:
    bge t1, a2, loop_end
    lw      t2, 0(a0)
    lw      t3, 0(a1)
    # mul     t0, t2, t3

    li t0,0

mul_loop_start:
    beq t3, zero, mul_loop_end
    andi t6, t3, 1
    beq t6, zero, mul_loop_handle
    add t0, t2, t0

mul_loop_handle:
    slli t2, t2, 1
    srli t3, t3, 1
    j mul_loop_start
mul_loop_end:
    add     t4, t0, t4
    add     a0, a0, a3
    add     a1, a1, a4
    addi    t1, t1, 1
    j       loop_start
loop_end:
    mv a0, t4
    jr ra
```
**test result**
```
test_dot_length_1 (__main__.TestDot) ... ok
test_dot_length_error (__main__.TestDot) ... ok
test_dot_length_error2 (__main__.TestDot) ... ok
test_dot_standard (__main__.TestDot) ... ok
test_dot_stride (__main__.TestDot) ... ok
test_dot_stride_error1 (__main__.TestDot) ... ok
test_dot_stride_error2 (__main__.TestDot) ... ok

----------------------------------------------------------------------
Ran 7 tests in 3.792s

OK
```
---
### relu.s
Iterate through vector and make negative elements $0$.
```!asm
relu:
    li t0, 1
    blt a1, t0, error
    li t1, 0

loop_start:
    bge     t1, a1, end_relu
    lw      t2, 0(a0)
    bge     t2, zero, big
    li      t2, 0
    sw      t2, 0(a0)
big:
    addi    a0, a0, 4
    addi    t1, t1, 1
    j       loop_start
end_relu:
    jr      ra
error:
    li a0, 36
    j exit
```
**test result**
```
test_relu_invalid_n (__main__.TestRelu) ... ok
test_relu_length_1 (__main__.TestRelu) ... ok
test_relu_standard (__main__.TestRelu) ... ok

----------------------------------------------------------------------
Ran 3 tests in 1.844s

OK
```
---
### matmul.s
After finishing inner loop, bump `M0` by ``a2 * 4``

(move pointer $4 * column\space number$ bytes forward).
```!asm
inner_loop_end:
    # TODO: Add your own implementation
    slli    s1, a2, 2
    add     s3, s3, s1
    addi    s0, s0, 1
```
**test result**
```
test_matmul_incorrect_check (__main__.TestMatmul) ... ok
test_matmul_length_1 (__main__.TestMatmul) ... ok
test_matmul_negative_dim_m0_x (__main__.TestMatmul) ... ok
test_matmul_negative_dim_m0_y (__main__.TestMatmul) ... ok
test_matmul_negative_dim_m1_x (__main__.TestMatmul) ... ok
test_matmul_negative_dim_m1_y (__main__.TestMatmul) ... ok
test_matmul_nonsquare_1 (__main__.TestMatmul) ... ok
test_matmul_nonsquare_2 (__main__.TestMatmul) ... ok
test_matmul_nonsquare_outer_dims (__main__.TestMatmul) ... ok
test_matmul_square (__main__.TestMatmul) ... ok
test_matmul_unmatched_dims (__main__.TestMatmul) ... ok
test_matmul_zero_dim_m0 (__main__.TestMatmul) ... ok
test_matmul_zero_dim_m1 (__main__.TestMatmul) ... ok

----------------------------------------------------------------------
Ran 13 tests in 7.266s

OK
```
---
## Part B
### read_matrix.s
Wrote a extra helper function to implement `mul` operation:
```!asm
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
```
Replace ``mul`` instruction with function call:
```!asm
# mul s1, t1, t2   # s1 is number of elements
    # FIXME: Replace 'mul' with your own implementation
    addi    sp, sp, -8
    sw      a0, 4(sp)
    sw      a1, 0(sp)
    mv      a0, t1
    mv      a1, t2
    call    mul
    mv      s1, a0
    lw      a0, 4(sp)
    lw      a1, 0(sp)
    addi    sp, sp, 8
```
**test result**
```
test_read_1 (__main__.TestReadMatrix) ... ok
test_read_2 (__main__.TestReadMatrix) ... ok
test_read_3 (__main__.TestReadMatrix) ... ok
test_read_fail_fclose (__main__.TestReadMatrix) ... ok
test_read_fail_fopen (__main__.TestReadMatrix) ... ok
test_read_fail_fread (__main__.TestReadMatrix) ... ok
test_read_fail_malloc (__main__.TestReadMatrix) ... ok

----------------------------------------------------------------------
Ran 7 tests in 4.275s

OK
```
---
### write_matrix.s
Used function mentioned above to replace `mul` instruction.
```!asm
# mul s4, s2, s3   # s4 = total elements
# FIXME: Replace 'mul' with your own implementation
    addi  sp, sp, -8
    sw    a0, 4(sp)
    sw    a1, 0(sp)
    mv    a0, s2
    mv    a1, s3
    call  mul
    mv    s4, a0
    lw    a0, 4(sp)
    lw    a1, 0(sp)
    addi  sp, sp, 8
```
**test result**
```
test_write_1 (__main__.TestWriteMatrix) ... ok
test_write_fail_fclose (__main__.TestWriteMatrix) ... ok
test_write_fail_fopen (__main__.TestWriteMatrix) ... ok
test_write_fail_fwrite (__main__.TestWriteMatrix) ... ok

----------------------------------------------------------------------
Ran 4 tests in 2.321s

OK
```
---
### calssify.s
Tried function call like I did in ``read_matrix.s`` and ``write_matrix.s`` but couln't pass the task, so wrote inline operations instead. Implementation detail are same as ``dot.s``.
```!asm
    # mul a0, t0, t1 # FIXME: Replace 'mul' with your own implementation

    li a0,0

mul_loop_start1:
    beq t1, zero, mul_loop_end1
    andi t6, t1, 1
    beq t6, zero, mul_loop_handle1
    add a0, t0, a0

mul_loop_handle1:
    slli t0, t0, 1
    srli t1, t1, 1
    j mul_loop_start1

mul_loop_end1:
```
```!asm
# mul a1, t0, t1 # length of h array and set it as second argument

    li a1,0

mul_loop_start2:
    beq t1, zero, mul_loop_end2
    andi t6, t1, 1
    beq t6, zero, mul_loop_handle2
    add a1, a1, t0

mul_loop_handle2:
    slli t0, t0, 1
    srli t1, t1, 1
    j mul_loop_start2

mul_loop_end2:
    # FIXME: Replace 'mul' with your own implementation
```
```!asm
# mul a0, t0, t1 # FIXME: Replace 'mul' with your own implementation

    li a0,0

mul_loop_start3:
    beq t1, zero, mul_loop_end3
    andi t6, t1, 1
    beq t6, zero, mul_loop_handle3
    add a0, a0, t0

mul_loop_handle3:
    slli t0, t0, 1
    srli t1, t1, 1
    j mul_loop_start3

mul_loop_end3:
```
```!asm
# FIXME: Replace 'mul' with your own implementation
    li a1,0

mul_loop_start4:
    beq t1, zero, mul_loop_end4
    andi t6, t1, 1
    beq t6, zero, mul_loop_handle4
    add a1, a1, t0

mul_loop_handle4:
    slli t0, t0, 1
    srli t1, t1, 1
    j mul_loop_start4

mul_loop_end4:
```
**test result**
```
test_classify_1_silent (__main__.TestClassify) ... ok
test_classify_2_print (__main__.TestClassify) ... ok
test_classify_3_print (__main__.TestClassify) ... ok
test_classify_fail_malloc (__main__.TestClassify) ... ok
test_classify_not_enough_args (__main__.TestClassify) ... ok

----------------------------------------------------------------------
Ran 5 tests in 3.823s

OK
```
---
## test all
Result of runnung ``bash test.sh all``:
```
test_abs_minus_one (__main__.TestAbs) ... ok
test_abs_one (__main__.TestAbs) ... ok
test_abs_zero (__main__.TestAbs) ... ok
test_argmax_invalid_n (__main__.TestArgmax) ... ok
test_argmax_length_1 (__main__.TestArgmax) ... ok
test_argmax_standard (__main__.TestArgmax) ... ok
test_chain_1 (__main__.TestChain) ... ok
test_classify_1_silent (__main__.TestClassify) ... ok
test_classify_2_print (__main__.TestClassify) ... ok
test_classify_3_print (__main__.TestClassify) ... ok
test_classify_fail_malloc (__main__.TestClassify) ... ok
test_classify_not_enough_args (__main__.TestClassify) ... ok
test_dot_length_1 (__main__.TestDot) ... ok
test_dot_length_error (__main__.TestDot) ... ok
test_dot_length_error2 (__main__.TestDot) ... ok
test_dot_standard (__main__.TestDot) ... ok
test_dot_stride (__main__.TestDot) ... ok
test_dot_stride_error1 (__main__.TestDot) ... ok
test_dot_stride_error2 (__main__.TestDot) ... ok
test_matmul_incorrect_check (__main__.TestMatmul) ... ok
test_matmul_length_1 (__main__.TestMatmul) ... ok
test_matmul_negative_dim_m0_x (__main__.TestMatmul) ... ok
test_matmul_negative_dim_m0_y (__main__.TestMatmul) ... ok
test_matmul_negative_dim_m1_x (__main__.TestMatmul) ... ok
test_matmul_negative_dim_m1_y (__main__.TestMatmul) ... ok
test_matmul_nonsquare_1 (__main__.TestMatmul) ... ok
test_matmul_nonsquare_2 (__main__.TestMatmul) ... ok
test_matmul_nonsquare_outer_dims (__main__.TestMatmul) ... ok
test_matmul_square (__main__.TestMatmul) ... ok
test_matmul_unmatched_dims (__main__.TestMatmul) ... ok
test_matmul_zero_dim_m0 (__main__.TestMatmul) ... ok
test_matmul_zero_dim_m1 (__main__.TestMatmul) ... ok
test_read_1 (__main__.TestReadMatrix) ... ok
test_read_2 (__main__.TestReadMatrix) ... ok
test_read_3 (__main__.TestReadMatrix) ... ok
test_read_fail_fclose (__main__.TestReadMatrix) ... ok
test_read_fail_fopen (__main__.TestReadMatrix) ... ok
test_read_fail_fread (__main__.TestReadMatrix) ... ok
test_read_fail_malloc (__main__.TestReadMatrix) ... ok
test_relu_invalid_n (__main__.TestRelu) ... ok
test_relu_length_1 (__main__.TestRelu) ... ok
test_relu_standard (__main__.TestRelu) ... ok
test_write_1 (__main__.TestWriteMatrix) ... ok
test_write_fail_fclose (__main__.TestWriteMatrix) ... ok
test_write_fail_fopen (__main__.TestWriteMatrix) ... ok
test_write_fail_fwrite (__main__.TestWriteMatrix) ... ok

----------------------------------------------------------------------
Ran 46 tests in 89.220s

OK
```
**succefully passed all tasks.**
