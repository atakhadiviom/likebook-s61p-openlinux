// Draw a 16-level gray test pattern via the stock /dev/ebc driver and request a full refresh.
// epd_mode values (old Rockchip enum, confirmed by kernel strings): 0 AUTO, 1 FULL, 2 A2, 3 PART, 4 FULL_DITHER, 5 RESET, 6 BLACK_WHITE, 7 BG, 8 BLOCK.
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/ioctl.h>
#include <sys/mman.h>

#define W 1024
#define H 758

int main(int argc, char **argv) {
    int mode = argc > 1 ? atoi(argv[1]) : 1;
    int fd = open("/dev/ebc", O_RDWR);
    if (fd < 0) { perror("open"); return 1; }
    int info[14] = {0};
    if (ioctl(fd, 0x7000, info)) { perror("GET_BUFFER"); return 1; }
    unsigned char *fb = mmap(NULL, 0x600000, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
    if (fb == MAP_FAILED) { perror("mmap"); return 1; }
    unsigned char *p = fb + info[0];
    for (int y = 0; y < H; y++) {
        for (int x = 0; x < W; x += 2) {
            int a, b;
            if (y < H / 2) {                    // top: 16 vertical gray bars, 64 px each
                a = x / 64; b = (x + 1) / 64;
            } else {                            // bottom: 8px checkerboard black/white
                int c = (((x / 8) + (y / 8)) & 1) ? 0xf : 0x0;
                a = b = c;
            }
            p[y * (W / 2) + x / 2] = (b << 4) | a;
        }
    }
    info[1] = mode;
    info[9] = 0; info[10] = 0; info[11] = W; info[12] = H;
    int r = ioctl(fd, 0x7001, info);
    printf("SEND_BUFFER mode=%d ret=%d\n", mode, r);
    sleep(3);
    close(fd);
    return 0;
}
