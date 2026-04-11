.equ led_add, 0x00000100
.equ switch_add, 0x00000200
.text
.globl main
main:
inputWait:
 li t0, switch_add
 lw t1, 0(t0)
 beq t1, zero, inputWait
 mv a0, t1 # Store switch input as function argument
 jal ra, countdown # Call countdown routine
 j inputWait
countdown:
 addi sp, sp, -8 # Allocate stack space for ra and s0
 sw ra, 4(sp) # Save return address
 sw s0, 0(sp) # Save s0 register
 mv s0, a0 # Initialize counter with input value
 li t0, led_add # Load LED memory address
update_led:
 sw s0, 0(t0) # Output current count to LEDs
 # CHECK FOR RESET INPUT
 li t2, switch_add
 lw s1, 0(t2)
 bne s1, zero, handle_reset # If switch active, reset immediately
 # TIMING DELAY LOOP
 li t3, 2000000 # Load delay count (for ~10MHz clock)
delay_loop:
addi t3, t3, -1
 bne t3, zero, delay_loop
handle_reset:
 sw zero, 0(t0) # Turn off all LEDs
 lw s0, 0(sp) # Restore saved s0 register
 lw ra, 4(sp) # Restore return address
 addi sp, sp, 8 # Deallocate stack space
 j inputWait # Jump back to input polling loop
