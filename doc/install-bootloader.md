# Installing the bootloader
The programs compiled with this toolchain require a bootloader to be present
on the microcontroller. If you are using a board, such as the Digilent Chipkit
Uno32, this bootloader should already be installed on your stock unit.

## Download the bootloader
Download and unzip the boot loader from Digilent. For the Uno32, use the
following URL:
https://www.digilentinc.com/Products/Detail.cfm?NavPath=2,892,893&Prod=CHIPKIT-UNO32

## Installing using a Pickit 2
Install the bootloader using pk2cmd. For the Uno32, issue the following
command:
`pk2cmd -PPIC32MX320F128H -M -Farduino-bootloader.X.Uno32_8-19-11.hex`

## Installing using a Pickit 3
To install the bootloader using a Pickit 3, you need to have either
Mplab or Mplab X installed on your computer. Start the Mplab IPE
(Integrated Programming Environment). Select the target pic32 device,
for the Uno32, this is PIC32MX320F128H. Browse for the hex-file with
the bootloader and click the "Program" button.
