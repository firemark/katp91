#include "Vcpu.h"
#include "verilated.h"
#include <unistd.h>

uint8_t ram[1 << 16];

vluint64_t main_time = 0;

double sc_time_stamp() {
    return main_time;
}

int main(int argc, char **argv, char **env) {
    int i;
    for(i=0; i < (1 << 16); i++)
        ram[i] = 0;
    if (argc > 1){
        FILE * f = fopen(argv[1], "r");
        fread(ram, 1 << 16, 1, f);
        fclose(f);
    }
    system("clear");
    Verilated::commandArgs(argc, argv);
    Vcpu* cpu = new Vcpu;
    int reset = 1;
    while (!Verilated::gotFinish()) { 
        cpu->clk = ~cpu->clk;
        cpu->reset = reset;
        if (cpu->r)
            cpu->date_bus = ram[cpu->adress_bus - 0x2000];
        cpu->eval();
        main_time++;
        if (!cpu->halt && main_time % 4 == 0) {
            printf("TIME %d\n", main_time);
            usleep(1000 * 500);
            system("clear");
        }
    }
    cpu->final();
    delete cpu;
    exit(0);
}
