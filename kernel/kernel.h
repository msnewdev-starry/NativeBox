#ifndef KERNEL_H
#define KERNEL_H

#include <stdint.h>
#include <stddef.h>

// Kernel function declarations
void kernel_main(void);
void clear_screen(void);
void putchar(char c);
void print(const char *str);
void init_graphics(void);
void draw_gui(void);
void draw_rectangle(int x, int y, int width, int height, uint8_t color);
void draw_text(const char *str, int x, int y);
void draw_char(char c, int x, int y);
void setup_idt(void);
void setup_pit(void);

// I/O port operations
void outb(uint16_t port, uint8_t value);
uint8_t inb(uint16_t port);

#endif // KERNEL_H
