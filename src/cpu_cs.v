`define CS(x) (1 << x)

// registers
`define CS_OUT_RG1 `CS(0)
`define CS_OUT_RG2 `CS(1)
`define CS_IN_RG1 `CS(2)
`define CS_IN_RG2 `CS(3)
`define CS_OUT_ERG1 `CS(4)
`define CS_OUT_ERG2 `CS(5)
`define CS_IN_ERG1 `CS(6)
`define CS_IN_ERG2 `CS(7)


// internal bus
`define CS_OUT_DATA `CS(8)
`define CS_IN_DATA `CS(9)
`define CS_IN_ADDR `CS(10)

// program counter
`define CS_OUT_PC `CS(11)
`define CS_IN_PC `CS(12)
`define CS_OUT_PC_H `CS(26)
`define CS_IN_PC_H `CS(27)
`define CS_OUT_PC_L `CS(28)
`define CS_IN_PC_L `CS(29)

// word counter
`define CS_OUT_WD `CS(30)
`define CS_IN_WD `CS(31)
`define CS_OUT_WD_H `CS(32)
`define CS_IN_WD_H `CS(33)
`define CS_OUT_WD_L `CS(34)
`define CS_IN_WD_L `CS(35)

// stack pointer
`define CS_IN_SP `CS(24)
`define CS_OUT_SP `CS(25)

// alu
`define CS_OUT_ALU8 `CS(13)
`define CS_IN_ALU8 `CS(14)

// flags
`define CS_OUT_FLAGS_ALU8 `CS(15)
`define CS_IN_FLAGS `CS(16)

// inc/dec
`define CS_OUT_INC_DEC `CS(17)
`define CS_INC `CS(18)
`define CS_DEC `CS(19)

// special
`define CS_DECODER `CS(20)
`define CS_NEW_PC `CS(21)
`define CS_WRITE `CS(22)
`define CS_READ `CS(23)