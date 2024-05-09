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
  la   a0, file_in     # output file name
  li   a1, 0        # Open for writing (flags are 0: read, 1: write)
  ecall             # open a file (file descriptor returned in a0)
  mv   s6, a0       # save the file descriptor
  ###############################################################
  # Read test.bmp
  li   a7, 63       # system call for write to file
  mv   a0, s6       # file descriptor
  la   a1, buf   # address of buffer from which to write
  li   a2, 4096       # hardcoded buffer length
  ecall             # write to file
  # Close test.bmp
  li   a7, 57       # system call for close file
  mv   a0, s6       # file descriptor to close
  ecall             # close file
  ###############################################################
  la	s0, buf
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
