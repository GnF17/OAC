.data
var1: .word 5
var2: .word 10
res1: .word 0
res2: .word 0

.text
.globl main

main:
    li t0, 10           # addi
    li t1, 20
    add t2, t0, t1      # t2 = 30
    sub t3, t2, t1      # t3 = 10
    and t4, t0, t1      # t4 = 0
    or  t5, t0, t1      # t5 = 30
    slt t6, t0, t1      # t6 = 1 (10 < 20)

    # Teste de memória
    la t4, var1
    lw t5, 0(t4)        # t5 = var1 = 5
    la t6, res1
    sw t5, 0(t6)        # res1 = 5

    # Teste beq (vai pular para label se t0 == t3 ? 10 == 10)
    beq t0, t3, label1
    li t0, 0            # NÃO deve executar

label1:
    # Teste jal (pula e salva no ra)
    jal ra, jump_here
    li t1, 0            # NÃO deve executar

jump_here:
    li t2, 42

    # Teste jalr (indireto, volta para label2)
    la t0, label2
    jalr ra, 0(t0)
    li t3, 0            # NÃO deve executar

label2:
    li t4, 99

    # Encerrar
    li a7, 10
    ecall
