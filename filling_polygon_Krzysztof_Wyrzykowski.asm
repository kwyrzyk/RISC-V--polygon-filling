        .eqv	PRINT_STR, 4
        .eqv	READ_STR, 8
        .eqv	ALLOCATE_MEMORY, 9
        .eqv	SYS_EXIT0, 10
        .eqv	CLOSE_FILE, 57
        .eqv	SEEK, 62
        .eqv	READ_FILE, 63
        .eqv 	WRITE_FILE, 64
        .eqv	OPEN_FILE, 1024
        .data
enter_file_path:.asciz "Enter path to your file: "
enter_RGB:	.asciz "Enter color you want to fill polygon in RGB format: "
file_out: 	.asciz "result.bmp"
header: .space 54
RGB:	.space 7
file: 	.space 100
	.text
# Ask for file path
	la	a0, enter_file_path
	li	a7, PRINT_STR
	ecall
# Read path
	la	a0, file
	li	a1, 100
	li	a7, READ_STR
	ecall
# Remove enter
	li	t1, '\n'
rem_enter:
	lbu	t0, (a0)
	addi	a0, a0, 1
	bne	t0, t1, rem_enter
	sb	zero, -1(a0)
# Ask for RGB
	la	a0, enter_RGB
	li	a7, PRINT_STR
	ecall
# Read filling color RGB
	la	a0, RGB
	li	a1, 7
	li	a7, READ_STR
	ecall
	li	t0, 6
	li	a6, '9'
	li	t3, '0'
nxtchr:
	lbu	t2, (a0)
	addi	a0, a0, 1
	bleu	t2, a6, dig
	addi	t2, t2, -55
	b	add_hex_value
dig:	
	sub	t2, t2, t3
add_hex_value:
	slli	s11, s11, 4
	add	s11, s11, t2
	addi	t0, t0, -1
	bnez	t0, nxtchr
# Open file   
  	la   	a0, file 
  	li   	a1, 0      
  	li   	a7, OPEN_FILE    
  	ecall             # Open file
  	mv   	s6, a0       # save the file descriptor
# Read file header

  	mv   	a0, s6       
  	la   	a1, header      
  	li   	a2, 54    
  	li   	a7, READ_FILE     
  	ecall             # Read header
# Read file width -> t5 ( in bytes)
	la	s0, header
	lbu 	t5, 0x12(s0)
	lbu	t4, 0x13(s0)
	slli	t4, t4, 8
	or	t5, t4, t5
	lbu	t4, 0x14(s0)
	slli	t4, t4, 16
	or	t5, t4, t5
	lbu	t4, 0x15(s0)
	slli	t4, t4, 24
	or	t5, t4, t5	# width in pixels
	mv	t2, t5		
	slli	t2, t2, 1
	add	t2, t2, t5	# width of line without trailing zeros
	slli	t4, t5, 1
	add	t5, t4, t5
	addi	t5, t5, 3
	srli	t5, t5, 2
	slli	t5, t5, 2	# width in bytes
	sub	t2, t5, t2	# number of trailing zero bytes	
# Read file height -> t6 
	lbu 	t6, 0x16(s0)
	lbu	t4, 0x17(s0)
	slli	t4, t4, 8
	or	t6, t4, t6
	lbu	t4, 0x18(s0)
	slli	t4, t4, 16
	or	t6, t4, t6
	lbu	t4, 0x19(s0)
	slli	t4, t4, 24
	or	t6, t4, t6
# Calculate bitmap size -> t0
	mul	t0, t5, t6
	addi	t0, t0, 54
	mv	a0, t0
# Allocate space for file
	li	a7, ALLOCATE_MEMORY
	ecall
	mv	a6, a0 # save buffor address
# Seek to 0 byte
	mv	a0, s6
	li	a1, 0
	li	a2, 0
	li	a7, SEEK
	ecall
# Read file
  	li   	a7, 63    
  	mv   	a0, s6       
  	mv   	a1, a6       
  	mv   	a2, t0       
  	ecall
# Close file
  	li   	a7, 57
  	mv   	a0, s6
  	ecall
# Define white and black
  	mv	t4, a6
  	addi	t4, t4, 54
  	add	t4, t4, t5
  	addi	t6, t6, -1
  	li	s9, 0x00FFFFFF # White
  	li	s10, 0x00000000 # Black
nxtline:
	mv	s5, zero	# Reset all points
  	mv	s6, zero
  	mv	s7, zero
	mv	s0, t4		# Move to next line
  	add	t4, t4, t5	# Next line adress -> t4
  	addi	t6, t6, -1
  	beqz	t6, fin
nxtsegment:
  	mv	s3, zero	# Top pixels counter
  	mv	s4, zero	# Bottom pixels counter
find_segment_start:
	add	t3, s0, t2
	bgeu	t3, t4, nxtline
  	mv	a0, s0
  	addi	s0, s0, 3
  	call	load_RGB
  	beq	a0, s9, find_segment_start
  	addi	s1, s0, -3	# save sagment start -> s1
find_segment_end:
	mv	a0, s0
  	addi	s0, s0, 3
  	call	load_RGB
  	beq	a0, s10, find_segment_end
  	addi	s2, s0, -6	# save segment end -> s2
#Count pixels
	add	a0, s1, t5	# top-left start segment
	addi	a0, a0, -3
	bltu	a0, t4, top_middle_start
	call	load_RGB
	beq	a0, s10, found_top_pixel
top_middle_start:
	add	a0, s1, t5	# top-middle start segment
	call	load_RGB
	beq	a0, s10, found_top_pixel
	add	a0, s1, t5	# top-right start segment
	addi	a0, a0, 3
	call	load_RGB
	beq	a0, s10, found_top_pixel
	add	a0, s2, t5	# top-left end segment
	addi	a0, a0, -3
	bltu	a0, t4, top_middle_end
	call	load_RGB
	beq	a0, s10, found_top_pixel
top_middle_end:
	add	a0, s2, t5	# top-middle end segment
	call	load_RGB
	beq	a0, s10, found_top_pixel
	add	a0, s2, t5	# top-right end segment
	addi	a0, a0, 3
	call	load_RGB
	bne	a0, s10, bottom_middle_start
found_top_pixel:
	not	s3, s3
bottom_middle_start:
	sub	a0, s1, t5	# bottom-middle start segment
	call	load_RGB
	beq	a0, s10, found_bottom_pixel
	sub	a0, s1, t5	# bottom-left start segment
	addi	a0, a0, -3
	call	load_RGB
	beq	a0, s10, found_bottom_pixel
	sub	a0, s1, t5	# bottom-right start segment
	addi	a0, a0, 6
	bgeu	a0, t4, bottom_middle_end
	addi	a0, a0, -3
	call	load_RGB
	beq	a0, s10, found_bottom_pixel
bottom_middle_end:
	sub	a0, s2, t5	# bottom-middle end segment
	call	load_RGB
	beq	a0, s10, found_bottom_pixel
	sub	a0, s2, t5	# bottom-right end segment
	addi	a0, a0, 6
	bgeu	a0, t5, bottom_left_end
	addi	a0, a0, -3
	call	load_RGB
	beq	a0, s10, found_bottom_pixel
	sub	a0, s2, t5	# bottom-left end segment
bottom_left_end:
	addi	a0, a0, -3
	call	load_RGB
	bne	a0, s10, save_points
found_bottom_pixel:
	not	s4, s4
save_points:
	beqz	s3, double_segment
	beqz	s4, double_segment
single_segment:
	bnez 	s5, save_to_second_point
	mv	s5, s2
	b	fill_between
save_to_second_point: 
	mv	s6, s1
	b	fill_between
double_segment:
	bnez 	s5, save_to_second_and_third_points
	mv	s5, s1
	mv	s6, s2
	b	fill_between
save_to_second_and_third_points:
	mv	s6, s1
	mv	s7, s2
fill_between:
	beqz	s6, nxtsegment
	addi	s5, s5, 3
	mv	a0, s5
	call	load_RGB
	beq	a0, s10, filled
	bgeu	s5, s6, filled
	mv	a0, s5
	call	color_pixel
	b	fill_between
filled:
	mv	s5, s7
	mv	s6, zero
	mv	s7, zero
	b	nxtsegment
fin:
  # Open file
	li  	a7, 1024     # system call for open file
	la   a0, file     # output file name
	#la	a0, file_out
	li  	a1, 1        # Open for writing (flags are 0: read, 1: write)
	ecall             # open a file (file descriptor returned in a0)
	mv   	s6, a0       # save the file descriptor
  # Write to file
	li  	a7, WRITE_FILE     
	mv   	a0, s6   
	mv   	a1, a6   
	mv   	a2, t0       
	ecall             # write to file
   # Close file
	li   	a7, CLOSE_FILE      
	mv   	a0, s6       
	ecall             # close file
  	li	a7, SYS_EXIT0
	ecall
load_RGB:
	lbu 	a1, (a0)
	lbu	a2, 1(a0)
	slli	a2, a2, 8
	or	a1, a2, a1
	lbu	a2, 2(a0)
	slli	a2, a2, 16
	or	a1, a2, a1
	mv	a0, a1
	ret
color_pixel:
	mv	a1, s11
	sb	a1, (a0)
	srli	a1, a1, 8
	sb	a1, 1(a0)
	srli	a1, a1, 8
	sb	a1, 2(a0)
	ret
