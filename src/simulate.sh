set -e
iverilog -o testerCpu \
    testerCpu.v \
    Cpu.v \
    Alu.v CheckBranch.v \
    Decoder.v Registers.v \
    IntAddrs.v \
    Diodes.v \
    Ram.v 
./testerCpu

