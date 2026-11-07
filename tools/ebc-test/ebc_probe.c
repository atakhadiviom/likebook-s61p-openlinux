// Read-only probe of the stock Rockchip software-EBC driver (/dev/ebc) on the Likebook S61P.
// Ioctls (from ebc_io_ctl disassembly): 0x7000 GET_BUFFER (56-byte struct), 0x7001 SEND_BUFFER, 0x7002..0x7006 others.
// This build only calls GET_BUFFER once and dumps the struct; it does not send a frame.
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/ioctl.h>
#include <sys/mman.h>

int main(void) {
    int fd = open("/dev/ebc", O_RDWR);
    if (fd < 0) { perror("open /dev/ebc"); return 1; }
    int info[14] = {0};
    int r = ioctl(fd, 0x7000, info);
    printf("GET_BUFFER ret=%d\n", r);
    for (int i = 0; i < 14; i++) printf("  int[%2d] @+0x%02x = %d (0x%x)\n", i, i*4, info[i], info[i]);
    // framebuffer area is 0x600000 (6 MiB) per device tree
    void *m = mmap(NULL, 0x600000, PROT_READ, MAP_SHARED, fd, 0);
    printf("mmap(6MiB) = %p\n", m);
    if (m != MAP_FAILED) {
        unsigned char *p = (unsigned char*)m + info[0];
        printf("first bytes at offset %d:", info[0]);
        for (int i = 0; i < 16; i++) printf(" %02x", p[i]);
        printf("\n");
    }
    close(fd);
    return 0;
}
