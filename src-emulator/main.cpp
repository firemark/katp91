#include "VCpu.h"
#include "VCpu_Cpu.h"
#include "verilated.h"
#include <unistd.h>
#include <stdio.h>

#define RAM_SIZE 1 << 16
uint8_t ram[RAM_SIZE];
int sleep_time = 1000;

vluint64_t main_time = 0;

double sc_time_stamp() {
    return main_time;
}

int main(int argc, char **argv, char **env) {
    if (argc > 1) {
        FILE * f = fopen(argv[1], "r");
        fread(ram, RAM_SIZE, 1, f);
        fclose(f);
    }
    if (argc > 2) {
        sleep_time = atoi(argv[2]);
    }
    system("clear");
    Verilated::commandArgs(argc, argv);
    VCpu* cpu = new VCpu;
    int reset = 0;
    int cycles = 0;
    while (!Verilated::gotFinish()) { 
        cpu->clk = ~cpu->clk;
        cpu->reset = reset;
        if (cpu->r)
            cpu->data_bus = ram[cpu->address_bus];
        else if (cpu->w)
            ram[cpu->address_bus] = cpu->data_bus;
        cpu->eval();
        if (cpu->clk)
            main_time++;
        cycles++;
        if (!cpu->halt && cpu->v->cycle == 1) {
            printf("#TIME %d\n", main_time);
            usleep(1000 * cycles * sleep_time);
            cycles = 0;
            system("clear");
        }
    }
    printf("#TIME %d\n", main_time);
    cpu->final();
    delete cpu;
    exit(0);
}
