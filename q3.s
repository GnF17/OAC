#https://www.eecs.yorku.ca/course_archive/2022-23/F/2021A/RVS/RVS-IOsyscalls008.pdf
#https://jupitersim.gitbook.io/jupiter/assembler/ecalls
.data 
quatro: .float 4.0
dois: .float 2.0
zeroo: .float 0.0
msg: .ascii "Erro! N?o ? equa??o do segundo grau!"
msg_raiz1:    .asciz "R(1) = "
msg_raiz2:    .asciz "R(2) = "
msg_plus:     .asciz " + "
msg_minus:    .asciz " - "
msg_i:        .asciz " i" 

.globl __start

.text

__start:

	addi sp, sp, -12
	jal loop
 
 loop: 
	 # lendo o primeiro valor (a)
	 li a7, 6 # ecall code
	 ecall # Armazena o valor em fa0
	 fmv.s ft0, fa0  # Copia o valor float de fa0 para ft0
	
	 # lendo o segundo valor (b)
	 li a7, 6 # ecall code
	 ecall # Armazena o valor em fa0
	 fmv.s ft1, fa0  # Copia o valor float de fa0 para ft0
	 
	 # lendo o terceiro valor (c)
	 li a7, 6 # ecall code
	 ecall # Armazena o valor em fa0
	 fmv.s ft2, fa0  # Copia o valor float de fa0 para ft0
	
	# verificando se ? uma equa??o de segundo grau
	#flt.s t0, ft0, zeroo
	# bnez ft0, baskara

	la t1, zeroo        # Carrega o endere?o de 'zeroo' em t1
	flw ft3, 0(t1)      # Carrega o valor float de 'zeroo' em ft3
	feq.s t0, ft0, ft3  # Compara ft0 (a) com 0.0 (ft3)
	beqz t0, baskara    # Se a != 0, vai para baskara

	addi a0, t0, 0
	addi a1, t0, 0
	addi a2, t0, 0
	
	sw a0, 8(sp)
	sw a1, 4(sp)
	sw a2, 0(sp)
	
	# chama a fun??o show
	jal show
	
	# Imprime a mensagem de erro
	li a7, 4
	la t1, msg
	ecall
	
	# Encerra o programa
	li a7, 10
	ecall
	
baskara:
	# -b
	fneg.s ft3, ft1 
	
	# b?
	fmul.s ft1, ft1, ft1
	
	# a*c -> d
	fmul.s ft2, ft0, ft2
	
	# 4*d -> e
	la t1, quatro       # Carrega o endere?o de 'quatro' em t1
	flw ft5, 0(t1)      # Carrega o valor 4.0 em ft5
	fmul.s ft4, ft5, ft2
	
	# b?-e
	fsub.s ft1, ft1, ft4 # ft1 = ?
	
	# verificando se a raiz ser? conjugada
	#blt ft1, zeroo, complexo
	# indicar que ? conjudada
	# Verifica se Δ < 0 (raízes complexas)
	la t1, zeroo
	flw ft9, 0(t1)      # Carrega 0.0 para comparação
	flt.s t0, ft1, ft9  # Se Δ < 0, t0 = 1; senão, t0 = 0
	bnez t0, complexo   # Pula para 'complexo' se Δ < 0
    
	
	# raiz quadrada de delta
	fsqrt.s ft1, ft1
	
	# 2*a
	la t1, dois          # Carrega o endere?o de 'dois' em t1
	flw ft9, 0(t1)       # Carrega o valor 2.0 em ft9
	fmul.s ft6, ft9, ft0 # ft6 = 2.0 * a 
	
	# -b+raiz de delta
	fadd.s ft7, ft3, ft1
	fdiv.s ft7, ft7, ft6
	fmv.s fs0, ft7 # fs0 = x1
	
	#-b-raiz de delta
	fsub.s ft8, ft3, ft1
	fdiv.s ft8, ft8, ft6
	fmv.s fs1, ft8 # fs1 = x2

	# add 1 para ra?z real
	li a0, 1
	
	jal pilha
	
	jal show
	
	ret

complexo:
	# m?dulo de ? (|?|)
    	fabs.s ft1, ft1       # ft1 = |?|

	# ?|?|
    	fsqrt.s ft1, ft1      # ft1 = ?|?|

	# 2*a 
    	la t1, dois       # Carrega o endere�o de 'dois' em t1
	flw ft6, 0(t1)    # Carrega o valor 2.0 em ft6
    	fmul.s ft6, ft6, ft0  # ft6 = 2a

	# Parte real: -b/(2a) 
    	fdiv.s ft7, ft3, ft6  # ft7 = parte real (-b/2a)

	# Parte imagin?ria: ?|?|/(2a)
    	fdiv.s ft8, ft1, ft6  # ft8 = parte imagin?ria (?|?|/2a)

	# Armazena as ra?zes complexas:
    	# fs0 = parte real + parte imagin?ria (x1)
    	# fs1 = parte real - parte imagin?ria (x2)
	fmv.s fs0, ft7 # parte real
	fmv.s fs1, ft8 # parte imagin?ria

	# add 2 para ra?z complexa
	li a0, 2
	jal pilha


show:
	# Recupera valores da pilha
	lw a0, 8(sp)
	flw ft0, 4(sp) # x1 ou parte real
	flw ft1, 0(sp) # x2 ou parte imagin?ria

	# Verifica tipo de raiz
	li t0, 1
	beq a0, t0, show_real
	j show_complex

show_real:
	# Imprime R(1) = x1
	li a7, 4
	la a0, msg_raiz1
	ecall

	li a7, 2
        fmv.s fa0, ft0
        ecall

	# Imprime \n
        li a7, 11
        li a0, '\n'
        ecall

        # Imprime R(2) = x2
        li a7, 4
        la a0, msg_raiz2
        ecall

        li a7, 2
        fmv.s fa0, ft1
        ecall

        j end_show

show_complex:
	# Imprime R(1) = real + imagin?ria i
    	li a7, 4
    	la a0, msg_raiz1
    	ecall

    	li a7, 2
    	fmv.s fa0, ft0     # Parte real
    	ecall

    	li a7, 4
    	la a0, msg_plus
    	ecall

    	li a7, 2
    	fmv.s fa0, ft1     # Parte imagin?ria
    	ecall

    	li a7, 4
    	la a0, msg_i
    	ecall

	# Imprime \n
    	li a7, 11
    	li a0, '\n'
    	ecall

    	# Imprime R(2) = real - imagin?ria i
    	li a7, 4
    	la a0, msg_raiz2
    	ecall

    	li a7, 2
    	fmv.s fa0, ft0     # Parte real
    	ecall

    	li a7, 4
    	la a0, msg_minus
    	ecall

    	li a7, 2
    	fmv.s fa0, ft1     # Parte imagin?ria
    	ecall

    	li a7, 4
    	la a0, msg_i
    	ecall
    	
    	li a7, 10
    	ecall

end_show:
    	ret
    	
pilha:

	sw a0, 8(sp) # armazena o 1 se for real e 2 se for complexo
	fsw fs0, 4(sp) # armazena x1 ou parte real
	fsw fs1, 0(sp) # armazena x2 ou parte imagin?ria
	ret

