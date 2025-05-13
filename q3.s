#https://www.eecs.yorku.ca/course_archive/2022-23/F/2021A/RVS/RVS-IOsyscalls008.pdf
#https://jupitersim.gitbook.io/jupiter/assembler/ecalls
.data 
quatro: .float 4.0
dois: .float 2.0
zeroo: .float 0.0
msg: .ascii "Erro! Não é equação do segundo grau!"

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
	
	# verificando se é uma equação de segundo grau
	#flt.s t0, ft0, zeroo
	bnez ft0, baskara
	
	addi a0, t0, 0
	addi a1, t0, 0
	addi a2, t0, 0
	
	sw a0, 8(sp)
	sw a1, 4(sp)
	sw a2, 0(sp)
	
	# chama a função show
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
	
	# b²
	fmul.s ft1, ft1, ft1
	
	# a*c -> d
	fmul.s ft2, ft0, ft2
	
	# 4*d -> e
	flw ft5, quatro
	fmul.s ft4, ft5, ft2
	
	# b²-e
	fsub.s ft1, ft1, ft4
	
	# verificando se a raiz será conjugada
	#blt ft1, zeroo, complexo
	# indicar que é conjudada
	
	# raiz quadrada de delta
	fsqrt.s ft1, ft1
	
	# 2*a
	fmul.s ft6, dois, ft0
	
	# -b+raiz de delta
	fadd.s ft7, ft3, ft1
	fdiv.s ft7, ft7, ft6
	fmv.s fs0, ft7
	
	#-b-raiz de delta
	fsub.s ft8, ft3, ft1
	fdiv.s ft8, ft8, ft6
	fmv.s fs1, ft8
	
	jal pilha
	
	jal show
	
	ret

pilha:
	# add 1 se for real e 2 se for complexa
	addi a0, t0, 1
	
	sw a0, 8(sp)
	sw fs0, 4(sp)
	sw fs1, 0(sp)
	ret
	
show: 
	lw a0, 0(sp)
	lw a1, 4(sp)
	lw a2, 8(sp)
	addi sp, sp, 12
	ret
