        .eqv	SYS_EXIT0, 10
        .data
file_in: .asciz "shape1.bmp"      # filename for output
file_out:.asciz "result_shape1.bmp"
buf: 	.space 4096
colors:	.word	
	0x00000000 # Black
	0x00FFFFFF # White
        .text       
  ###############################################################
  # Open test.bmp
	li   a7, 1024     # system call for open file
  	la   a0, file_in  # output file name
  	li   a1, 0        # Open for reading 
  	ecall             # open a file (file descriptor returned in a0)
  	mv   s6, a0       # save the file descriptor
  ###############################################################
  # Read test.bmp
  	li   a7, 63       # system call for read from file
  	mv   a0, s6       # file descriptor
  	la   a1, buf      # address of buffer from which to write
  	li   a2, 4096     # hardcoded buffer length
  	ecall             # write to file
  # Close test.bmp
  	li   a7, 57       # system call for close file
  	mv   a0, s6       # file descriptor to close
  	ecall             # close file
  ###############################################################
  	la	s0, buf
  	xor	s5, s5, s5
  	xor	s6, s6, s6
  	xor	s7, s7, s7
  	li	s9, 0x00FFFFFF # White
  	li	s10, 0x00000000 # Black
  	li	s11, 0x00FD0000 # Filling color - temporary blue
  # Read width -> t5
	lbu 	t5, 0x12(s0)
	lbu	t4, 0x13(s0)
	slli	t4, t4, 8
	or	t5, t4, t5
	lbu	t4, 0x14(s0)
	slli	t4, t4, 16
	or	t5, t4, t5
	lbu	t4, 0x15(s0)
	slli	t4, t4, 24
	or	t5, t4, t5	# number of pixels
	
	slli	t4, t5, 1
	add	t5, t4, t5
	addi	t5, t5, 3
	srli	t5, t5, 2
	slli	t5, t5, 2	# width in bytes
	
  # Read height -> t6
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
	
  ###############################################################
  	addi	s0, s0, 0x36 	# Move pointer to first pixel
  	add	t4, s0, t5
  	addi	t6, t6, -2
nxtline:
	mv	s0, t4
  	add	t4, t4, t5	# Move to next line
  	addi	t6, t6, -1
  	beqz	t6, fin
nxtsegment:
  	xor	s3, s3, s3	# Top pixels counter
  	xor	s4, s4, s4	# Bottom pixels counter
find_segment_start:
	bgeu	s0, t4, nxtline
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
################################################################
#Count pixels
	add	a0, s1, t5	# top-middle start segment
	#call 	color_pixel
	call	load_RGB
	andi	a1, a0, 1
	xori	a1, a1, 1
	add	s3, s3, a1
	add	a0, s1, t5	# top-left start segment
	addi	a0, a0, -3
	#call 	color_pixel
	call	load_RGB
	andi	a1, a0, 1
	xori	a1, a1, 1
	add	s3, s3, a1
	add	a0, s1, t5	# top-right start segment
	addi	a0, a0, 3
	#call 	color_pixel
	call	load_RGB
	andi	a1, a0, 1
	xori	a1, a1, 1
	add	s3, s3, a1
	add	a0, s2, t5	# top-middle end segment
	#call 	color_pixel
	call	load_RGB
	andi	a1, a0, 1
	xori	a1, a1, 1
	add	s3, s3, a1
	add	a0, s2, t5	# top-left end segment
	addi	a0, a0, -3
	#call 	color_pixel
	call	load_RGB
	andi	a1, a0, 1
	xori	a1, a1, 1
	add	s3, s3, a1
	add	a0, s2, t5	# top-right end segment
	addi	a0, a0, 3
	#call 	color_pixel
	call	load_RGB
	andi	a1, a0, 1
	xori	a1, a1, 1
	add	s3, s3, a1
	sub	a0, s1, t5	# bottom-middle start segment
	#call 	color_pixel
	call	load_RGB
	andi	a1, a0, 1
	xori	a1, a1, 1
	add	s4, s4, a1
	sub	a0, s1, t5	# bottom-left start segment
	addi	a0, a0, -3
	#call 	color_pixel
	call	load_RGB
	andi	a1, a0, 1
	xori	a1, a1, 1
	add	s4, s4, a1
	sub	a0, s1, t5	# bottom-right start segment
	addi	a0, a0, 3
	#call 	color_pixel
	call	load_RGB
	andi	a1, a0, 1
	xori	a1, a1, 1
	add	s4, s4, a1
	sub	a0, s2, t5	# bottom-middle end segment
	#call 	color_pixel
	call	load_RGB
	andi	a1, a0, 1
	xori	a1, a1, 1
	add	s4, s4, a1
	sub	a0, s2, t5	# bottom-left end segment
	addi	a0, a0, -3
	#call 	color_pixel
	call	load_RGB
	andi	a1, a0, 1
	xori	a1, a1, 1
	add	s4, s4, a1
	sub	a0, s2, t5	# bottom-right end segment
	addi	a0, a0, 3
	#call 	color_pixel
	call	load_RGB
	andi	a1, a0, 1
	xori	a1, a1, 1
	add	s4, s4, a1
#################################################################
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
	bgeu	s5, s6, filled
	mv	a0, s5
	call	color_pixel
	b	fill_between
filled:
	mv	s5, s7
	xor	s6, s6, s6
	xor	s7, s7, s7
	b	nxtsegment
###############################################################
fin:
  # Open test2.bmp
	li   a7, 1024     # system call for open file
	la   a0, file_out     # output file name
	li   a1, 1        # Open for writing (flags are 0: read, 1: write)
	ecall             # open a file (file descriptor returned in a0)
	mv   s6, a0       # save the file descriptor
  # Write test2.bmp
	li   a7, 64       # system call for write to file
	mv   a0, s6       # file descriptor
	la   a1, buf   # address of buffer from which to write
	li   a2, 4096       # hardcoded buffer length
	ecall             # write to file
   # Close test2.bmp
	li   a7, 57       # system call for close file
	mv   a0, s6       # file descriptor to close
	ecall             # close file
###############################################################
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
	sb	a1, 2(a0)
	srli	a1, a1, 8
	sb	a1, 1(a0)
	srli	a1, a1, 8
	sb	a1, 0(a0)
	ret
# Read width -> t5
  lbu 	t5, 18(s0)
  lbu	t4, 19(s0)
  slli	t4, t4, 8
  or	t5, t4, t5
  lbu	t4, 20(s0)
  slli	t4, t4, 16
  or	t5, t4, t5
  lbu	t4, 20(s0)
  slli	t4, t4, 24
  or	t5, t4, t5
  
  # Read height -> t6
  lbu 	t6, 22(s0)
  lbu	t4, 23(s0)
  slli	t4, t4, 8
  or	t5, t4, t6
  lbu	t4, 24(s0)
  slli	t4, t4, 16
  or	t6, t4, t6
  lbu	t4, 25(s0)
  slli	t4, t4, 24
  or	t6, t4, t6
