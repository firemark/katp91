#include "Vcpu.h"
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
            usleep(1000 * sleep_time);
            system("clear");
        }
    }
    cpu->final();
    delete cpu;
    exit(0);
}