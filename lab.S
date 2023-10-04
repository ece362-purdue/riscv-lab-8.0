// Mark the 'main' label as visible to linker
// meaning other program can call this function
.global main

// the main function
// assign register a0 with val 1
// assign register a1 with val 2
// add a0 and a1 and assign value to register a2
// assign register a0 with val 0 
//   (set main return val to 0 so 'make' won't complain)
// jump to address ra + 0, and save PC + 4 to register x0
// return to address in register 'ra'
main:
    li a0, 1
    li a1, 2
    add a2, a0, a1
    li a0, 0
    jalr x0, ra, 0
    # or simply 'ret'