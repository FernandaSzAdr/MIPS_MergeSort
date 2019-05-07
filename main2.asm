.data
    
    vetor: .space 60
    vetor_size: .word 15
    vetor_temp: .word 0:100
    Space:	.asciiz ", "
    
.text

#*************************************************** Leitura *********************************************************

la $s1, vetor        		# armazena o endereço do vetor de entrada em $s1			
li $t0, 0        		# i = 0, interador que sera usado para percorrer o vetor

FOR_CAPTURA: sll $t1, $t0, 2    # $t1 = i * 4
add $t2, $t1, $s1    		# $t2 = endreço de vetor[i]
jal CAPTURA_VALOR    		# chama função para pegar valor, que sera armazenado em $v0
sw $v0, 0($t2)       		# vetor[i] = $v0
addi $t0, $t0, 1    		# i = i + 1
bne $t0, 15, FOR_CAPTURA    	# enquanto i != 15 continue
j MAIN

CAPTURA_VALOR:
li $v0, 5        
syscall
jr $ra

MAIN:
add $a0, $zero, $s1
add $a1, $zero, $zero
addi $a2, $zero, 14	#vetor_size - 1

jal MERGESORT
jal PRINT 
li  $v0, 10
syscall

j END

RETORNA:
jr $ra

MERGESORT:
#a0 = endereço do vetor
#a1 = posição inicial
#a2 = posição final

bge $a1, $a2, RETORNA	#se $a1 <= $a2, vai para RETORNA

addi $sp, $sp, -20	#reserva a pilha para cinco valores
sw $ra, 16($sp)
sw $a0, 12($sp)
sw $a1, 8($sp)
sw $a2, 4($sp)

add $t0, $a1, $a2
div $t1, $t0, 2		#obtém o meio(final+inicio)/2

sw $t1, 0($sp)

# mergesort(vetor, inicio, meio)
add $a2, $t1, $zero	#a2 = meio
jal MERGESORT

# mergesort(vetor, meio, fim)
lw $a3, 0($sp) 		#a3 = meio
lw $a2, 4($sp)		#a2 = fim
addi $a1, $a3, 1	#a1 = meio+1
jal MERGESORT

lw $a3, 0($sp)
lw $a2, 4($sp)
lw $a1, 8($sp)

jal MERGE

lw $ra, 16($sp)
addi $sp, $sp, 20	#restaura a pilha
jr $ra

MERGE:
add $s0, $a1, $zero	#$s0 = i; i = inicio
add $s1, $a1, $zero	#$s1 = k; k = inicio
addi $s2, $a3, 1	#$s2 = j; j = meio + 1

WHILE1: 
blt  $a3,  $s0, WHILE2	# se meio < i vai para WHILE2
blt  $a2,  $s2, WHILE2	# se final < j vai para WHILE2
j  IF_MERGE		
	
IF_MERGE:
sll  $t0, $s0, 2	# $t0 = i*4
add  $t0, $t0, $a0	
lw   $t1, 0($t0)	# carrega o valor vetor[i] em $t1
sll  $t2, $s2, 2	# $t1 = j*4
add  $t2, $t2, $a0	# 
lw   $t3, 0($t2)	# carrega o valor vetor[j] em $t3	
blt  $t3, $t1, ELSE_MERGE	# se vetor[j] < vetor[i], vai para ELSE_MERGE
la   $t4, vetor_temp		# carrega o endereço de vetor_temp em $t4
sll  $t5, $s1, 2	# k*4
add  $t4, $t4, $t5	
sw   $t1, 0($t4)	# vetor_temp[k] = vetor[i]
addi $s1, $s1, 1	# k++
addi $s0, $s0, 1	# i++
j WHILE1 

ELSE_MERGE:
sll  $t2, $s2, 2	# $t1 = j*4
add  $t2, $t2, $a0	
lw   $t3, 0($t2)	# $t3 = vetor[j]	
la   $t4, vetor_temp	
sll  $t5, $s1, 2	# k*4
add  $t4, $t4, $t5	
sw   $t3, 0($t4)	# vetor_temp[k] = vetor[j]
addi $s1, $s1, 1	# k++
addi $s2, $s2, 1	# j++
j WHILE1 

WHILE2:
blt  $a3, $s0, WHILE3 	# se meio < i
sll $t0, $s0, 2		# $t6 = i*4
add $t0, $a0, $t0	
lw $t1, 0($t0)		# carrega o valor do vetor[i] em $t1
la  $t2, vetor_temp	
sll $t3, $s1, 2         # k*4
add $t3, $t3, $t2	
sw $t1, 0($t3) 		# salva $t1 (vetor[i]) no endereço de $t3(vetor_temp[k])
addi $s1, $s1, 1   	# k++
addi $s0, $s0, 1   	# i++
j WHILE2		
	

WHILE3:
blt  $a2,  $s1, FOR_INICIALIZADOR	#se final < j, vai para FOR_INICIALIZADOR
sll $t2, $s2, 2    	# $t2 = j*4
add $t2, $t2, $a0  	# 
lw $t3, 0($t2)     	# $t3 = vetor[j]
la  $t4, vetor_temp		
sll $t5, $s1, 2	   	# k*4
add $t4, $t4, $t5  	
sw $t3, 0($t4)     	# salva $t3 (vetor[i]) no endereço de $t4(vetor_temp[k])
addi $s1, $s1, 1   	# k++
addi $s2, $s2, 1   	# j++
j WHILE3		

FOR_INICIALIZADOR:
add  $t0, $a1, $zero	# $t0 = inicio; i = inicio
addi $t1, $a2, 1 	# $t1 = final + 1
la   $t4, vetor_temp		
j FOR

FOR:
bge $t0, $t1, RETORNA	#se $t0 <= $t1, vai para RETORNA
sll $t2, $t0, 2   	# $t0 * 4 
add $t3, $t2, $a0	# vetor[$t2]
add $t5, $t2, $t4	# vetor_temp[$t2]
lw  $t6, 0($t5)		# carrega vetor_temp[i] em $t6
sw $t6, 0($t3)   	# salva o valor de vetor_temp[$t2] em vetor[$t2]; vetor[i] = vetor_temp[i]
addi $t0, $t0, 1 	# incrementa $t0; i++
j FOR 			
	
PRINT:
add $t0, $a1, $zero 	# $t0 = inicio
add $t1, $a2, $zero	# $t1 = final
la  $t4, vetor		# carrega o endereço de vetor
	
PRINT_FOR:
blt  $t1, $t0, RETORNA	# se $t1 < $t0, vai para RETORNA
sll  $t3, $t0, 2	# $t0 * 4 
add  $t3, $t3, $t4	
lw   $t2, 0($t3)	# carrega vetor[$t0] em $t2
move $a0, $t2		# move o valor para $a0
li   $v0, 1		# chama o sistema para imprimir inteiros
syscall
addi $t0, $t0, 1	# incrementa $t0 

la   $a0, Space		# imprime virgula e espaço
li   $v0, 4		# chama o sistema para imprimir string
syscall

j PRINT_FOR		
	
END:



  
