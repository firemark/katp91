#include "VBoard.h"
#include "VBoard_Board.h"
#include "VBoard_Ram.h"
#include "verilated.h"
#include <unistd.h>
#include <stdio.h>
#include <SFML/Graphics.hpp>

#define RAM_SIZE 1 << 15
uint8_t ram[RAM_SIZE];
uint8_t reset = 1;
int screen_row = 0;
int screen_line = 0;
vluint64_t main_time = 0;

sf::Image background;
sf::Sprite sprite;
sf::Texture texture;

struct timespec tstart={0,0}, tend={0,0};

double sc_time_stamp() {
    return main_time;
}

void init(int argc, char **argv) {
    system("clear");
    if (argc > 1) {
        FILE * f = fopen(argv[1], "r");
        fread(ram, RAM_SIZE, 1, f);
        fclose(f);
    }
    Verilated::commandArgs(argc, argv);
    texture.create(1024, 625);
    background.create(1024, 625, sf::Color::Black);
}

int clock_and_eval(VBoard* board) {
    board->clk = ~board->clk;
    board->eval();
}

int board_sleep() {
    struct timespec tim;
    unsigned int delay = tend.tv_nsec - tstart.tv_nsec;
    //printf("%d\n", delay);
    if (delay >= 55)
        return -1;
    tim.tv_sec = 0;
    tim.tv_nsec = 55 - delay;
    
    nanosleep(&tim, NULL);
}

int end_loop() {
    printf("#END %d %d\n", main_time / 2, main_time % 2);
    main_time++;
    board_sleep();
    //system("clear");
}

int render(sf::RenderWindow &window, VBoard *board) {
    if (board->clk == 0)
        return -1;

    int r = board->r * 28;
    int g = board->g * 28;
    int b = board->b * 28;

    background.setPixel(screen_row, screen_line, sf::Color(r, g, b, 255));
    screen_row++;
    //printf("####%d %d (%d,%d,%d)\n", screen_row, screen_line, r, g, b);
    if (screen_row >= 1024){
        screen_row = 0;
        screen_line++;
    }

    if (screen_line >= 625) {
        screen_line = 0;
    }

    if (screen_line != 0)
        return -1;

    sf::Event event;
    while (window.pollEvent(event)) {
        if (event.type == sf::Event::Closed)
            window.close();
        if (event.type == sf::Event::Resized) {
            window.setView(sf::View(sf::FloatRect(0, 0, event.size.width, event.size.height)));
        }
    }
    window.clear();
    texture.loadFromImage(background);
    sprite.setTexture(texture);
    window.draw(sprite);
    window.display();      
    
}

int main(int argc, char **argv, char **env) {
    init(argc, argv);
    VBoard* board = new VBoard;
    board->reset = 1;
    for(int i=0; i < RAM_SIZE; i++)
        board->v->ram->store[i] = ram[i];
    sf::RenderWindow window(sf::VideoMode(1024, 625, 32), "KATPY91");

    while (window.isOpen() && !Verilated::gotFinish()) { 
        clock_gettime(CLOCK_MONOTONIC, &tstart);
        clock_and_eval(board);
        render(window, board);
        clock_gettime(CLOCK_MONOTONIC, &tend);
        end_loop();
    }
    board->final();
    window.close();
    delete board;
    exit(0);
}
