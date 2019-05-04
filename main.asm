# Descrição do projeto:
# Ordenação de vetores com o Merge Sort
# Esteprojeto consiste no desenvolvimento de um programa que implemente o método 
# de ordenação Merge Sort para ser aplicado na ordenação de vetores. 
# Neste aspecto, o programa deve:
# 	* Ler o tamanho do vetor informado pelo usuário (admitir pelo menos 15 valores)
#	* Ler valores de um vetor inteiro fornecidos pelo usuário.
#	* Ordenar os elementos do vetor em ordem crescente
#	* Escrever na saída (console) o vetor ordenado. 

.data
    
    vetor: .space 60
    vetor_size: .word 15
    vetor_ord: .space 60
    vec_L:			.space		60			#15 Ints
    vec_R:			.space		60			#15 Ints
    
    str_unorder: 	 .asciiz	 "\n  nao-ordenado: "
    str_ordered: 	 .asciiz	 "\n  ordenado:    "
    str_invalidSize: .asciiz 	 "Quantidade invalida de elementos!"
.text

#*************************************************** Leitura *********************************************************

la $s1, vetor        		# armazena o endereço do vetor de entrada em $s1			
li $t0, 0        		# i = 0, interador que sera usado para percorrer o vetor

For: sll $t1, $t0, 2     	# $t1 = i * 4
add $t2, $t1, $s1    		# $t2 = endreço de vetor[i]
jal captura_valor    		# chama função para pegar valor, que sera armazenado em $v0
sw $v0, 0($t2)       		# vetor[i] = $v0
addi $t0, $t0, 1    		# i = i + 1
bne $t0, 15, For    		# enquanto i != 15 continue
j main

captura_valor:
li $v0, 5        
syscall
jr $ra



#*************************************************** Main *********************************************************

main: la $a0,vetor		# $a0 será o ponteiro para a primeira posição do vetor não-ordenado
li $a1, 0			# $a1 será "p" : o índice inicial do vetor não-ordenado.
lw $a2,vetor_size			# $a2 será "r" : o índice final do vetor não-ordenado.
addi $a2,$a2,-1			# $a2 = (tamanho do vetor) - 1

jal MergeSort

li $t0,0
	beq $t0,$v0,exibir_tamanho_invalido	#if($v0 == NULL) exibir tamanho inválido

exibir_vetores:
	move	$t0, $v0			#$t0 = vetor_ord
	lw		$t1, vetor_size		#$t1 = vetor_size
	
	li 		$v0, 4
	la 		$a0, str_ordered
	syscall						#Exibe a mensagem "ordenado: " no video.
	
	la		$a0, vetor_ord	#$a0 = vetor_ord
	move	$a1, $t1			#$a1 = vetor_size
	jal		print_vec			#Exibe o vetor ordenado.
	
	li		$v0, 4
	la		$a0, str_unorder
	syscall						#Exibe a mensagem "nao-ordenado: " no video.
	
	la		$a0, vetor	#$a0 = vetor
	move	$a1, $t1	   	 	#$a1 = vetor_size
	jal		print_vec			#Exibe o vetor nao-ordenado.
	
	j		fim

exibir_tamanho_invalido:
	li		$v0,4
	la		$a0, str_invalidSize
	syscall					

fim:							
	li		$v0, 10
	syscall					#Execução encerrada
	
# *************************************************** MergeSort *********************************************************
#Argumentos de entrada:
#		-> $a0 : ponteiro para a primeira posição do vetor não-ordenado.
#       -> $a1 : índice inicial do vetor não-ordenado (p)
#       -> $a2 : índice final do vetor não-ordenado   (r)
#Retorno:
#       -> $v0 : ponteiro para a primeira posição do vetor ordenado

MergeSort:
	addi $sp,$sp,-4
	sw $ra,0($sp)
	
	lw $t1,vetor_size									    #carrega vetor_size
	
	li $t2, 1											#carrega 1 em t2
	blt $t1, $t2, MergeSort_TamanhoInvalido				# Se vetor_size < t2
	
	li $t2, 16											#carrega 16 em t2
	bgt $t1, $t2, MergeSort_TamanhoInvalido				# Se vetor_size > 16
	
	addi $sp,$sp,-8
	sw $a1,4($sp)										#empilhando p
	sw $a2,0($sp)										#empilhando r
	
	la $a1,vetor_ord
	move $a2,$t1										#$a2 = vetor_size
	jal cpy_word_vec
	
	la $a0, vetor_ord									#$a0 = (int*)vetor_ord
	lw $a2,0($sp)										#desempilhando r
	lw $a1,4($sp)										#desempilhando p
	addi $sp,$sp,8
	
	jal merge_sort
	
	la $v0,vetor_ord									#$v0 = (int*)vetor_ord
	j MergeSort_Fim
	
MergeSort_TamanhoInvalido:
	li $v0, 0
	
MergeSort_Fim:
	lw $ra,0($sp)
	addi $sp,$sp,4
	jr $ra
	
# *********************************************** merge_sort *****************************************************
#Argumentos de entrada:
#		-> $a0 : ponteiro para a primeira posição do vetor a ser ordenado(vetor_ord).
#       -> $a1 : índice inicial do vetor (p)
#       -> $a2 : índice final do vetor   (r)

merge_sort:
	addi $sp,$sp,-4
	sw $ra,0($sp)
	
	bge $a1,$a2,merge_sort_fim
	 
merge_sort_inicio:
	add $t0,$a1,$a2
	li $t1,2
	div $t3,$t0,$t1					#$t3 = q = (p + r)/2  ; $t3 será o meio do vetor ou subvetor (índice q) 
	
	sub $t2,$a2,$a1
	addi $t2,$t2,1					#$t2 = (r - p + 1)
	
	li $t0,4
	bgt $t2,$t0,merge_sort_interno	#Se (r - p + 1) > 4 ,executar merge_sort_interno.
	j merge_sort_procedMerge        #Se (r - p + 1) < = 4 ,executar diretamente o procedimento de merge.

merge_sort_interno:
	addi $sp,$sp,-12
	sw $a1,8($sp)					#empilha p    
	sw $a2,4($sp)					#empilha r
	sw $t3,0($sp)					#empilha q
	move $a2,$t3					#r = q
	jal merge_sort
	lw $t3,0($sp)					#desempilha q
	lw $a2,4($sp)					#desempilha r
	lw $a1,8($sp)					#desempilha p
	
	sw $a1,8($sp)					#empilha p
	sw $a2,4($sp)					#empilha r
	sw $t3,0($sp)					#empilha q
	move $a1,$t3					#p = q
	addi $a1,$a1,1					#p = p + 1
	jal merge_sort
	lw $t3,0($sp)					#desempilha q
	lw $a2,4($sp)					#desempilha r
	lw $a1,8($sp)					#desempilha p
	addi $sp,$sp,12
	
merge_sort_procedMerge:
	move $a3,$t3					#$a3 = q
	la $a0,vetor_ord
	jal merge
	
merge_sort_fim:
	lw $ra,0($sp)
	addi $sp,$sp,4
	jr $ra
	
# *********************************************** merge ************************************************************
#Argumentos de entrada:
#		-> $a0 : ponteiro para a primeira posição do vetor a ser ordenado(vetor_ord).
#       -> $a1 : índice inicial do vetor (p)
#       -> $a2 : índice final do vetor   (r)
#       -> $a3 : índice do elemento central do vetor ou subvetor (q)
merge:
	addi	$sp, $sp, -20				# Save in stack:
	sw		$ra, 0($sp)
	sw		$a0, 4($sp)
	sw		$a1, 8($sp)
	sw		$a2, 12($sp)
	sw		$a3, 16($sp)
	
	sub		$t0, $a3, $a1				# t0 = q - p + 1 (n1)
	addi    $t0,$t0,1
	 
	sub		$t1, $a2, $a3				# t1 = r - q (n2)
	
	sub		$t2, $a2, $a1				# t2 = r - p + 1
	addi	$t2, $t2, 1
	
	li		$t3, 4						# t3 = 4
	
	ble		$t2, $t3, merge_bubble		# if( r -p +1 <= 4 ) Run Bubble merge
										# else run normal merge
	
merge_normal:
	li		$t2, 0						# i = 0
	la		$t3, vec_L					# t3 = (int *)L
	
merge_normal_loop_1:					# Loop to copy left part of the vector to vec_L

										# if( i == n1) break loop
	beq		$t2, $t0, merge_normal_loop_1_end
	
	add		$t4, $a1, $t2				# t4 = p +i
	sll		$t4, $t4, 2					# t4 *= 4 (word)
	add		$t4, $t4, $a0				# t4 = (int *) &Vec[p +i]
	lw		$t4, 0($t4)					# t4 = (int) Vec[p +i]
	
	sll		$t5, $t2, 2					# t5 = i *4 (i Words)
	add		$t5, $t3, $t5				# t5 = (int *) &L[i]
	sw		$t4, 0($t5)					# L[i] = Vec[p +i]
	
	addi	$t2, $t2, 1					# i++
	
	b		merge_normal_loop_1			# continue loop

merge_normal_loop_1_end:


	li		$t2, 0						# i = 0
	la		$t3, vec_R					# t3 = (int *)R

merge_normal_loop_2:					# Loop to copy right part of the vector to vec_R

										# if( i == n2) break loop
	beq		$t2, $t1, merge_normal_loop_2_end
	
	add		$t4, $a3, $t2				# t4 = q + i
	addi    $t4,$t4,1					# t4 = q + i + 1
	sll		$t4, $t4, 2					# t4 *= 4 (word)
	add		$t4, $t4, $a0				# t4 = (int *) &Vec[q + i + 1]
	lw		$t4, 0($t4)					# t4 = (int) Vec[q + i + 1]
	
	sll		$t5, $t2, 2					# t5 = i *4 (i Words)
	add		$t5, $t3, $t5				# t5 = (int *) &R[i]
	sw		$t4, 0($t5)					# R[i] = Vec[q + i + 1]
	
	addi	$t2, $t2, 1					# i++
	
	b		merge_normal_loop_2			# continue loop
	
merge_normal_loop_2_end:


	li		$t2, 0x7fffffff				# max_int = 0x7fffffff
	
	la		$t3, vec_L					# t3 = (int *)L
	sll		$t4, $t0, 2					# t4 = n1 *4 (n1 words)
	add		$t3, $t3, $t4				# t3 = (int *) &L[n1]
	sw		$t2, 0($t3)					# L[n1] = max_int
	
	la		$t3, vec_R					# t3 = (int *)R
	sll		$t4, $t1, 2					# t4 = n2 *4 (n2 words)
	add		$t3, $t3, $t4				# t3 = (int *) &R[n2]
	sw		$t2, 0($t3)					# R[n2] = max_int
	

	li		$t0, 0						# i = 0
	li		$t1, 0						# j = 0
	move	$t2, $a1					# k = p
	la		$t3, vec_L					# t3 = (int *) L
	la		$t4, vec_R					# t4 = (int *) R

merge_normal_loop_3:
	bgt		$t2, $a2, merge_end			# if(k > r) return
	
	sll		$t5, $t0, 2					# t5 = i *4 (word)
	add		$t5, $t3, $t5				# t5 = (int *) &L[i]
	lw		$t5, 0($t5)					# t5 = (int) L[i]
	
	sll		$t6, $t1, 2					# t6 = j *4 (word)
	add		$t6, $t4, $t6				# t6 = (int *) &R[j]
	lw		$t6, 0($t6)					# t6 = (int) R[j]
	
	sll		$t7, $t2, 2					# t7 = k *4 (word)
	add		$t7, $a0, $t7				# t7 = (int *) &Vec[k]
	addi	$t2, $t2, 1					# k++
	
										# if(L[i] <= R[j]) 	execute condition 1
										# else 				execute condition 2
	ble		$t5, $t6, merge_normal_loop_3_condition_1
	b		merge_normal_loop_3_condition_2

	
merge_normal_loop_3_condition_1:
	
	sw		$t5, 0($t7)					# Vec[k] = L[i]
	addi	$t0, $t0, 1					# i++
	
	b		merge_normal_loop_3			# continue loop 3

merge_normal_loop_3_condition_2:
	
	sw		$t6, 0($t7)					# Vec[k] = R[j]
	addi	$t1, $t1, 1					# j++
	
	b		merge_normal_loop_3			# continue loop 3
	
merge_bubble:
	sll		$a1, $a1, 2					# p *= 4 (word)
	add		$a0, $a0, $a1				# (int *) vec = (int *) &vec[p]
	add		$a1, $t0, $t1				# sizeV = n1 + n2
	jal		bubble_sort					# BubbleSort(&vec[p], sizeV)
	
merge_end:
	lw		$ra, 0($sp)					# Retreeve from stack
	lw		$a0, 4($sp)
	lw		$a1, 8($sp)
	lw		$a2, 12($sp)
	lw		$a3, 16($sp)
	addi	$sp, $sp, 20
	
	jr		$ra							# Return
	
	
# *********************************************** Print Vector *****************************************************
# $a0 <- vec address
# $a1 <- size of vec
# 
print_vec:
	addi	$sp, $sp, -12				# Save in stack:
	sw		$a0, 0($sp)
	sw		$a1, 4($sp)
	sw		$v0, 8($sp)

	move	$t0, $a0					# Copy vec addres to safe temporary location
	
	
	beqz	$a1, print_vec_loop_end		#only enter loop if size > 0
	bltz	$a1, print_vec_loop_end
print_vec_loop:

	lw		$a0, 0($t0)					# Print vec[i]
	li		$v0, 1
	syscall
	
	li		$a0, ' '					# Print ' '
	li		$v0, 11
	syscall
	
	addi	$t0, $t0, 4					# i++		(vec += 4B)
	addi	$a1, $a1, -1				# size--
	bgtz	$a1, print_vec_loop			# if(size > 0) continue loop
print_vec_loop_end:
	
	lw		$a0, 0($sp)					# Retreeve from stack
	lw		$a1, 4($sp)
	lw		$v0, 8($sp)
	addi	$sp, $sp, 12
	
	jr		$ra							# Return
	
	
# *********************************************** Swap Words *****************************************************
# $a0 <- address A
# $a1 <- address B
# 
swap_word:
	lw		$t0, 0($a0)
	lw		$t1, 0($a1)
	sw		$t1, 0($a0)
	sw		$t0, 0($a1)
	
	jr		$ra							# Return
	
	
# ***************************************** Swap Words in Vector *************************************************
# $a0 <- vector address
# $a1 <- position A
# $a2 <- position B
# 
swap_word_vec:
	add		$t0, $a0, $a1
	add		$t1, $a0, $a2

	lw		$t2, 0($t0)
	lw		$t3, 0($t1)
	sw		$t3, 0($t0)
	sw		$t2, 0($t1)
	
	jr		$ra							# Return
	
	
# *********************************************** Bubble Sort *****************************************************
# $a0 <- vec address [first position from were to start ordering]
# $a1 <- vec size
# 
bubble_sort:
	addi	$sp, $sp, -32				# Save in stack:
	sw		$a0, 0($sp)
	sw		$a1, 4($sp)
	sw		$a2, 8($sp)
	sw		$s0, 12($sp)
	sw		$s1, 16($sp)
	sw		$s2, 20($sp)
	sw		$s3, 24($sp)
	sw		$ra, 28($sp)
	
	move	$s0, $a0					# Move vec and size
	move	$s1, $a1
	
	addi	$s1, $s1, -1				# size--
	sll		$s1, $s1, 2					# size *= 4 (because of the allignment)
	
bubble_sort_extern_loop:
	li		$s2, 0						# changed = false (loop interaction swapped numbers?)

	li		$s3, 0						# i = 0
bubble_sort_internal_loop:

	add		$t0, $s0, $s3				# $t0 = &vec[i]
	addi	$t1, $t0, 4					# $t1 = &vec[i +1]
	
	lw		$t2, 0($t0)					# $t2 = vec[i]
	lw		$t3, 0($t1)					# $t3 = vec[i +1]

										# if( vec[i] > vec[i+1] ) Swap
	ble		$t2, $t3, bubble_sort_dont_swap
	
	move	$a0, $t0					# Call swap(&vec[i], &vec[i+1])
	move	$a1, $t1
	jal		swap_word
	
	li		$s2, 1						# changed = true
	
bubble_sort_dont_swap:
	
	addi	$s3, $s3, 4					# i += 4 (1B)
	
										# if( i < size ) Continue Internal Loop
	blt		$s3, $s1, bubble_sort_internal_loop

bubble_sort_internal_loop_end:

	bgtz	$s2, bubble_sort_extern_loop # if( changed ) Continue External loop
bubble_sort_extern_loop_end:
	
	
	lw		$a0, 0($sp)					# Retreeve from stack
	lw		$a1, 4($sp)
	lw		$a2, 8($sp)
	lw		$s0, 12($sp)
	lw		$s1, 16($sp)
	lw		$s2, 20($sp)
	lw		$s3, 24($sp)
	lw		$ra, 28($sp)
	addi	$sp, $sp, 32
	
	jr		$ra							# Return
	
	
# ******************************************** Copy Word Vector ****************************************************
# $a0 <- vector to copy address
# $a1 <- vector other address
# $a2 <- size of vectors
# 
cpy_word_vec:
	move	$t0, $a0					# Copy arguments to other registers
	move	$t1, $a1
	move	$t2, $a2

	beqz	$t2, cpy_word_vec_loop_end	# if( size == 0 ) return
	
cpy_word_vec_loop:
	lw		$t3, 0($t0)					# $t3 = Ori[i]
	sw		$t3, 0($t1)					# Des[i] = $t3
	addi	$t2, $t2, -1				# size--
	addi	$t0, $t0, 4					# Ori++		] ( i += 4 because of the allignment)
	addi	$t1, $t1, 4					# Des++		]    ^
	
	bgez	$t2, cpy_word_vec_loop		# if( size > 0 ) Continue loop
	
cpy_word_vec_loop_end:
	
	jr	$ra							# Return


