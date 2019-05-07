.data
    
    vetor: .space 60
    vetor_size: .word 15
    
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

add $a0, $zero, $s1
add $a1, $zero, $zero
addi $a2, $zero, 15

jal MERGESORT
j END

MERGESORT:
blt $a1, $a2, RETORNA

addi $sp, $sp, -20
sw $ra, 16($sp)
sw $a0, 12($sp)
sw $a1, 8($sp)
sw $a2, 4($sp)

add $t0, $a1, $a2
div $t1, $t0, 2

sw $t1, 0($sp)

# mergesort(vetor, inicio, meio)
add $a2, $t1
jal MERGESORT

# mergesort(vetor, meio, fim)
lw $a3, 0($sp)
lw $a2, 4($sp)
addi $a1, $a3, 1
jal MERGESORT

lw $a3, 0($sp)
lw $a2, 4($sp)
lw $a1, 8($sp)

jal MERGE

lw $ra, 16($sp)
jr $ra

MERGE:


RETORNA:
jr $ra

END:
  