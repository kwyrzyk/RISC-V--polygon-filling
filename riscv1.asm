        .eqv	SYS_EXIT0, 10
        .data
file_in: .asciz "find_segment.bmp"      # filename for output
file_out:.asciz "result_find_segment.bmp"
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
  	li	s9, 0x00FFFFFF # White
  	li	s10, 0x00000000 # Black
  	li	s11, 0x00FF0000 # Filling color - temporary blue
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
	or	t5, t4, t5
  
  # Read height -> t6
	lbu 	t6, 0x16(s0)
	lbu	t4, 0x17(s0)
	slli	t4, t4, 8
	or	t5, t4, t6
	lbu	t4, 0x18(s0)
	slli	t4, t4, 16
	or	t6, t4, t6
	lbu	t4, 0x19(s0)
	slli	t4, t4, 24
	or	t6, t4, t6
	
  ###############################################################
  	addi	s0, s0, 0x36 	# Move pointer to first pixel
  	#add	s0, s0, t5	# Move pointer to second line
find_segment_start:	
  	mv	a0, s0
  	addi	s0, s0, 3
  	call	load_RGB
  	beq	a0, s9, find_segment_start
  	addi	a0, s0, -3
  	call	color_pixel
find_segment_end:
	mv	a0, s0
  	addi	s0, s0, 3
  	call	load_RGB
  	beq	a0, s10, find_segment_end
  	addi	a0, s0, -6
  	call	color_pixel
  ###############################################################
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