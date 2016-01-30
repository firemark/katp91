# katp91
simple computer written in Verilog to FPGA

# Compile emulator

```bash
./verilator.sh  # required verilator
cp obj_dir/Vcpu . 
```
# Compile asm to bytecode and run

```bash
./asm.py asm.code > asm.hex  # required python3
./Vcpu asm.hex 
```

