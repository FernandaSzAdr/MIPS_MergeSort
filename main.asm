# Descri��o do projeto:
# Ordena��o de vetores com o Merge Sort
# Esteprojeto consiste no desenvolvimento de um programa que implemente o m�todo 
# de ordena��o Merge Sort para ser aplicado na ordena��o de vetores. 
# Neste aspecto, o programa deve:
# 	* Ler o tamanho do vetor informado pelo usu�rio (admitir pelo menos 15 valores)
#	* Ler valores de um vetor inteiro fornecidos pelo usu�rio.
#	* Ordenar os elementos do vetor em ordem crescente
#	* Escrever na sa�da (console) o vetor ordenado. 

.data
    vetor: .space 60
.text
la $s1, vetor        		# armazena o endere�o do vetor de entrada em $s1			
li $t0, 0        		# i = 0, interador que sera usado para percorrer o vetor

For: sll $t1, $t0, 2     	# $t1 = i * 4
add $t2, $t1, $s1    		# $t2 = endre�o de vetor[i]
jal captura_valor    		# chama fun��o para pegar valor, que sera armazenado em $v0
sw $v0, 0($t2)       		# vetor[i] = $v0
addi $t0, $t0, 1    		# i = i + 1
bne $t0, 15, For    		# enquanto i != 15 continue
j exit_input

captura_valor:
li $v0, 5        
syscall
jr $ra

exit_input: