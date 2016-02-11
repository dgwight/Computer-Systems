# HW 2: Insertion Sort
# Dylan Wight
# CS 3650: Computer Systems


.text

#int main(void) {
main:
	#  int size = 16;
	lw $t0, size	
	#  char * data[] = {"Joe", "Jenny", "Jill", "John", "Jeff", "Joyce",
	#		"Jerry", "Janice", "Jake", "Jonna", "Jack", "Jocelyn",
	#		"Jessie", "Jess", "Janet", "Jane"};
	la $t1, data
	la $t2, names
	
	load_names:					# loop to load addresses of names in array 'data'
	beq $t0, 0, names_loaded
		sw $t2, ($t1)
		addi $t0, $t0, -1
		addi $t1, $t1, 4
		addi $t2, $t2, 16
		j load_names
	names_loaded:
	
	#  printf("Initial array is:\n");
	la $a0, before
	li $v0, 4
	syscall
	#  print_array(data, size);
	jal print_array
	#  insertSort(data, size);
	jal insert_sort
	#  printf("Insertion sort is finished!\n");
	la $a0, after
	li $v0, 4
	syscall
	#  print_array(data, size);
	jal print_array
	#  exit(0); }
	li $v0, 10
	syscall

#int str_lt (char *x, char *y) {
str_lt: 						# takes $a0 and $a1 both addresses to names,  if $a0 > $a1 returns $v0 = 1, else $v0 = 0
	addi $sp, $sp, -20
	sw $ra, ($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	sw $s3, 16($sp)				
	
	lw $s0, ($a0)					# load the address of the first string
	lw $s1, ($a1)					# load the address of the second string

	#  for (; *x!='\0' && *y!='\0'; x++, y++) {
	next_letter:
		lbu $t0, ($s0)				# $t0 = char from first word
		lbu $t1, ($s1)				# $t0 = char from second word

		add $t2, $t1, $t0			# check if both letters are '\0'
		beq $t2, 0, words_equal		
		
		beq $t1, $t0, letters_equal		# check if letters are equal, fall through if not equal
		#    if ( *x < *y ) return 1;
		#    if ( *y < *x ) return 0;
		slt $v0, $t1, $t0			# $v0 = 1 if the second word is less than the first
		j breakdown_str_lt
			
		letters_equal:
			addi $s0, $s0, 1		# advance the addresses to the next chars
			addi $s1, $s1, 1
			j next_letter
		#  if ( *y == '\0' ) return 0;	
		words_equal:
			li $v0, 0			
			j breakdown_str_lt
	

	breakdown_str_lt:				# breakdown_str_lt
	lw $s3, 16($sp)				
	lw $s2, 12($sp)
	lw $s1, 8($sp)
	lw $s0, 4($sp)
	lw $ra, ($sp)
	addi $sp, $sp, 20
	jr $ra

# void insertSort(char *a[], size_t length) {
insert_sort:
	addi $sp, $sp, -28				# setup insert_sort
	sw $ra, ($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	sw $s3, 16($sp)
	sw $s4, 20($sp)
	sw $s5, 24($sp)
	
	# int i, j;
	li $s0, 0					# $s0 = j inner_loop counter
	li $s1, 1					# $s1 = i outer_loop counter

	lw $s5, size

 
	# for(i = 1; i < length; i++) {
	outer_loop:
		beq $s1, $s5, breakdown_insert_sort
		# char *value = a[i];
		# for (j = i-1; j >= 0 && str_lt(value, a[j]); j--) {
		inner_loop:
			beq $s0, -1, next_outer 	# go to next outer if j < 0
			mul $t0, $s0, 4	
			la $t1, data
			add $s2, $t0, $t1		# $s2 = data[j] address of address
			add $s3, $s2, 4			# $s23 = data[j+1] address of address
			
			move $a0, $s2			# move data[j] and data[j+1] to arguments for str_lt
			move $a1, $s3	
			
			jal str_lt			# sets $v0 = 1 if swap needs to be made
			bne $v0, 1, next_outer		# swap values and continue on inner loop if str_lt returns 1
			
			next_inner:
				# a[j+1] = a[j];
				# a[j+1] = value;
				lw $t0, ($s2)		# $t0 = address of smaller word to be swapped
				lw $t1, ($s3)		# $t1 = address of larger word to be swapped 
				sw $t1, ($s2)		# swap values
				sw $t0, ($s3)
				
				addi $s0, $s0, -1	# decrements j
				j inner_loop
			
			next_outer:
				move $s0, $s1		# moves j back to front
				addi $s1, $s1, 1	# increments i
				j outer_loop
	
	
	
	breakdown_insert_sort:				# breakdown insert_sort
	lw $s5, 24($sp)
	lw $s4, 20($sp)						
	lw $s3, 16($sp)
	lw $s2, 12($sp)				
	lw $s1, 8($sp)				
	lw $s0, 4($sp)
	lw $ra, ($sp)
	addi $sp, $sp, 28
	jr $ra



#void print_array(char * a[], const int size) {
print_array:
	addi $sp, $sp, -12
	sw $ra, ($sp)
	sw $a0, 4($sp)
	sw $s0, 8($sp)
	
	lw $s0, size
	la $s1, data
	#  int i=0;
	li $t1, 0
	#  printf("[");
	la $a0, open
	li $v0, 4
	syscall
	

	#  while(i < size) printf("  %s", a[i++]);	
	print_name:
	beq $t1, $s0, breakdown_print_array 
		lw $t2, ($s1)
		la $a0, ($t2)
		li $v0, 4
		syscall
		
		la $a0, space
		li $v0, 4
		syscall
		
		addi $s1, $s1, 4
		addi $t1, $t1, 1
		j print_name
					
	breakdown_print_array:
	#  printf(" ]\n");
	la $a0, close			
	li $v0, 4
	syscall	
	
	lw $ra, ($sp)
	lw $a0, 4($sp)
	lw $s0, 8($sp)																	
	addi $sp, $sp, 12
	jr $ra

		
	
.data
	before: .asciiz "Initial array is:\n"
	after:  .asciiz "Insertion sort is finished!\n"
	space: 	.asciiz " "
	open:	.asciiz "[ "
	close:	.asciiz "]\n"
		.align 5
	data:	.space 64
	size:	.word 16
	names:
		.align 4
		.asciiz "Joe"
		.align 4
		.asciiz "Jenny"
		.align 4
		.asciiz "Jill"
		.align 4
		.asciiz "John"
		.align 4
		.asciiz "Jeff"
		.align 4
		.asciiz "Joyce"
		.align 4
		.asciiz "Jerry"
		.align 4
		.asciiz "Janice"
		.align 4
		.asciiz "Jake"
		.align 4
		.asciiz "Jonna"
		.align 4
		.asciiz "Jack"
		.align 4
		.asciiz "Jocelyn"
		.align 4
		.asciiz "Jessie"
		.align 4
		.asciiz "Jess"
		.align 4
		.asciiz "Janet"
		.align 4
		.asciiz "Jane"
	
	









	
