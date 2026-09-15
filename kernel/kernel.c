#include "kernel.h"

// Video memory address for VGA text mode
#define VIDEO_MEMORY 0xB8000
#define MAX_ROWS 25
#define MAX_COLS 80

// Global variables
static int cursor_row = 0;
static int cursor_col = 0;
static uint8_t current_color = 0x0F; // White text on black background

// Forward declarations
void setup_idt(void);
void setup_pit(void);
void clear_screen(void);
void putchar(char c);
void print(const char *str);

// Entry point from bootloader
void kernel_main(void)
{
    // Disable interrupts initially
    asm("cli");
    
    // Clear screen
    clear_screen();
    
    // Print welcome message
    print("NativeBox Kernel v1.0\n");
    print("================================\n");
    print("Initializing system components...\n\n");
    
    // Setup IDT (Interrupt Descriptor Table)
    print("[*] Setting up IDT...\n");
    setup_idt();
    
    // Setup PIT (Programmable Interval Timer)
    print("[*] Setting up PIT...\n");
    setup_pit();
    
    // Setup graphics mode
    print("[*] Initializing graphics...\n");
    init_graphics();
    
    // Enable interrupts
    asm("sti");
    
    print("\n[OK] System initialization complete!\n");
    print("================================\n");
    print("Starting NativeBox GUI...\n\n");
    
    // Draw GUI
    draw_gui();
    
    // Halt the system
    print("\nSystem ready. Halting.\n");
    asm("hlt");
}

// Clear VGA text mode screen
void clear_screen(void)
{
    uint16_t *video = (uint16_t *)VIDEO_MEMORY;
    uint16_t blank = (current_color << 8) | ' ';
    
    for (int i = 0; i < MAX_ROWS * MAX_COLS; i++) {
        video[i] = blank;
    }
    
    cursor_row = 0;
    cursor_col = 0;
}

// Put a character on screen
void putchar(char c)
{
    uint16_t *video = (uint16_t *)VIDEO_MEMORY;
    
    if (c == '\n') {
        cursor_row++;
        cursor_col = 0;
        if (cursor_row >= MAX_ROWS) {
            cursor_row = MAX_ROWS - 1;
            // Scroll screen (simple implementation)
        }
        return;
    }
    
    if (c == '\r') {
        cursor_col = 0;
        return;
    }
    
    int offset = cursor_row * MAX_COLS + cursor_col;
    video[offset] = (current_color << 8) | c;
    
    cursor_col++;
    if (cursor_col >= MAX_COLS) {
        cursor_col = 0;
        cursor_row++;
        if (cursor_row >= MAX_ROWS) {
            cursor_row = MAX_ROWS - 1;
        }
    }
}

// Print a string
void print(const char *str)
{
    while (*str) {
        putchar(*str++);
    }
}

// Initialize graphics mode
void init_graphics(void)
{
    // Set VGA mode to 13h (320x200x256 graphics mode)
    asm volatile("int $0x10" : : "a"(0x13));
}

// Draw the graphical user interface
void draw_gui(void)
{
    // Draw taskbar at bottom
    draw_rectangle(0, 190, 320, 10, 0x01); // Blue taskbar
    
    // Draw window title bar
    draw_rectangle(10, 10, 300, 20, 0x02); // Green title bar
    
    // Draw window content area
    draw_rectangle(10, 30, 300, 150, 0x0F); // White content area
    
    // Draw some UI elements
    draw_text("NativeBox v1.0", 20, 15);
    draw_text("Welcome to NativeBox!", 20, 40);
    draw_text("A minimal graphical OS", 20, 50);
    
    // Draw a button
    draw_rectangle(50, 100, 80, 30, 0x08); // Gray button
    draw_text("Click Me", 60, 110);
    
    // Draw system info
    draw_text("Memory: 64MB", 20, 200);
}

// Draw a filled rectangle
void draw_rectangle(int x, int y, int width, int height, uint8_t color)
{
    uint8_t *video = (uint8_t *)VIDEO_MEMORY;
    int screen_width = 320;
    
    for (int row = 0; row < height; row++) {
        for (int col = 0; col < width; col++) {
            int offset = (y + row) * screen_width + (x + col);
            if (offset < 320 * 200) {
                video[offset] = color;
            }
        }
    }
}

// Draw text in graphics mode (simple 8x8 font)
void draw_text(const char *str, int x, int y)
{
    // Simple text drawing - each character is 8x8
    while (*str) {
        draw_char(*str, x, y);
        x += 8;
        str++;
    }
}

// Draw a single character in graphics mode
void draw_char(char c, int x, int y)
{
    uint8_t *video = (uint8_t *)VIDEO_MEMORY;
    int screen_width = 320;
    
    // Simple 8x8 character representation
    uint8_t font[256][8] = {
        // This would contain actual font data
        // For now, just draw a simple pattern
    };
    
    // Draw character at position
    for (int row = 0; row < 8; row++) {
        for (int col = 0; col < 8; col++) {
            int offset = (y + row) * screen_width + (x + col);
            if (offset < 320 * 200) {
                video[offset] = 0x0F; // White text
            }
        }
    }
}

// Setup IDT (Interrupt Descriptor Table)
void setup_idt(void)
{
    // IDT setup code would go here
    // For now, this is a placeholder
}

// Setup PIT (Programmable Interval Timer)
void setup_pit(void)
{
    // PIT setup code would go here
    // Configure for ~100Hz timer interrupts
    uint16_t divisor = 11932; // 1193182 / 100 Hz
    
    // Send command byte
    outb(0x43, 0x36);
    
    // Send divisor
    outb(0x40, (uint8_t)divisor);
    outb(0x40, (uint8_t)(divisor >> 8));
}

// Output byte to I/O port
void outb(uint16_t port, uint8_t value)
{
    asm volatile("outb %0, %1" : : "a"(value), "d"(port));
}

// Input byte from I/O port
uint8_t inb(uint16_t port)
{
    uint8_t result;
    asm volatile("inb %1, %0" : "=a"(result) : "d"(port));
    return result;
}
