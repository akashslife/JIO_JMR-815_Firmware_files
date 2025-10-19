🔧 JioFi JMR815 (ALT3800 Platform) – UART Access & Firmware Extraction Guide

⚠️ Disclaimer:
This documentation is for educational and reverse-engineering research only.
Do not redistribute or use extracted firmware for any unauthorized or commercial purpose.

-----------------------------------------------------------
1. Hardware Overview
-----------------------------------------------------------
![WhatsApp Image 2025-10-19 at 11 34 50 PM](https://github.com/user-attachments/assets/c14b0aa8-aa41-4e66-afbc-1f1f0d9a76b7)


Main SoC: Altair Semiconductor ALT3800-E0 (LTE Modem Processor)
PHY Controller: Altair ALT6300-C0
Memory: 128 MB LPDDR (FIDELIX FMN2ED1SBK)
NAND Flash: 256 MB Hynix
Bootloader: U-Boot 2012.10-svn3034
OS: Linux 3.4.22 (MIPS 34Kc core)

-----------------------------------------------------------
2. Locate and Connect UART Pins
-----------------------------------------------------------
Identify UART pads on the PCB:
- Usually 3-4 test pads labeled TX, RX, GND, sometimes VCC.
- Near the edge or beside the SoC.

UART Pinout Reference:
JMR815 Pad   | Arduino Uno | Notes
TX (Board)   | RX (Pin 0)  | Data from device
RX (Board)   | TX (Pin 1)  | Data to device
GND          | GND         | Common ground
VCC          | -           | Leave unconnected

Tip: Connect GND first, never connect 5V. Device runs on 3.3V logic.

-----------------------------------------------------------
3. Configure UART Terminal
-----------------------------------------------------------

![WhatsApp Image 2025-10-19 at 11 34 08 PM](https://github.com/user-attachments/assets/00a03824-8ee7-43e0-8b54-39d42f964688)


Using PuTTY:
- Connect Arduino via USB
- Note COM port (e.g., COM6 in my case check device manager and com(numbers) ports)
- Configure:
  Baud: 115200
  Data bits: -
  Stop bits: -
  Parity: None
  Flow control: None

Click "Open" to view boot logs.

-----------------------------------------------------------
4. Bootloader (U-Boot) Access
-----------------------------------------------------------
Boot output example:
NAND boot... transferring control
U-Boot 2012.10-svn3034 (Sep 29 2017 - 15:40:21)
Hit any key to stop autoboot: 0

Press any key to stop autoboot and get prompt: #

-----------------------------------------------------------
5. NAND Flash Partitions
-----------------------------------------------------------
Command:
  # mtdparts

Example output:
device nand0 <alt3800_nfc>, # parts = 16
 #: name      size       offset
 0: spl       0x00080000 0x00000000
 1: uboot1    0x000c0000 0x00080000
 6: kernel1   0x00400000 0x00580000
 8: rootfs1   0x02800000 0x009c0000

Key partitions:
- kernel1/kernel2 : Linux kernel
- rootfs1/rootfs2 : Root filesystem
- modem_fw1/fw2   : LTE modem firmware
- uboot1/uboot2   : Bootloader copies

-----------------------------------------------------------
6. Dump NAND Partitions (Firmware Extraction)
-----------------------------------------------------------
Method 1 — Using U-Boot:
nand read 0x82000000 0x009c0000 0x02800000
loady

Receive via YMODEM on PC (Tera Term / Minicom).

Method 2 — From Linux Shell:
cat /proc/mtd
dd if=/dev/mtdblock8 of=/var/rootfs1.bin
dd if=/dev/mtdblock6 of=/var/kernel1.bin

Transfer via netcat:
nc -l -p 5555 > rootfs1.bin
dd if=/dev/mtdblock8 | nc <PC_IP> 5555

-----------------------------------------------------------
7. Analyze Dumped Firmware
-----------------------------------------------------------
Use:
binwalk rootfs1.bin
unsquashfs rootfs1.bin

Common directories:
- /etc/init.d/
- /usr/local/bin/
- /lib/modules/

-----------------------------------------------------------
8. Restoring or Reflashing
-----------------------------------------------------------
nand erase 0x009c0000 0x02800000
nand write 0x82000000 0x009c0000 0x02800000

Caution: Wrong address = brick.

-----------------------------------------------------------
9. Useful Commands
-----------------------------------------------------------
mtdparts     - View NAND partitions
printenv     - Show U-Boot env
nand read    - Read from NAND
nand write   - Write to NAND
loady/loadb  - Serial file receive
tftpboot     - Network file receive
bootm        - Boot kernel image
version      - Show U-Boot version

-----------------------------------------------------------
10. Firmware Info
-----------------------------------------------------------
<img width="1346" height="698" alt="jiojmr815 boot img" src="https://github.com/user-attachments/assets/7cffdc06-357f-484a-8847-64e2e0d2bf72" />

Model: JMR815 By Akash
Software Version: JMR815_R09.51
Software Base: HN_02_01_08_00_58_IO
Compiled: 2019.06.19-10:51:49
Kernel: Linux 3.4.22 (MIPS 34Kc)
WiFi Driver: rtl8192es

-----------------------------------------------------------
11. Tools Required
-----------------------------------------------------------
Hardware:
- USB-TTL or Arduino Uno
Software:
- PuTTY / Minicom
- Binwalk
- dd / hexdump
- unsquashfs / 7-Zip
- netcat / TFTP

-----------------------------------------------------------
12. Directory Snapshot
-----------------------------------------------------------
/bin
/boot
/etc
/lib
/media
/mnt
/nvm
/opt
/proc
/root
/sbin
/sys
/tmp
/upload
/usr
/var

-----------------------------------------------------------
13. Boot Flow
-----------------------------------------------------------
1. BootROM loads SPL
2. SPL loads U-Boot
3. U-Boot → loads kernel1 + dtb1 + rootfs1
4. Linux mounts JFFS2 rootfs
5. root@PWRT:/# prompt

-----------------------------------------------------------
14. Key Learnings
-----------------------------------------------------------
- MIPS 34Kc architecture, Linux 3.4
- NAND MTD partitions
- UART = full root access
- Realtek 8192ES WiFi
- Altair LTE modem


Author: Akash Reddy
Embedded Systems Researcher | Firmware Analysis Enthusiast

