#!/bin/bash
#sudo rmmod xpad
sudo modprobe uinput
sudo modprobe joydev
sudo xboxdrv --evdev /dev/input/js0 --evdev-absmap ABS_GAS=RT,ABS_BRAKE=LT,ABS_X=x1,ABS_Y=y1,ABS_Z=X2,ABS_RZ=y2,ABS_HAT0X=dpad_x,ABS_HAT0Y=dpad_y --axismap -Y1=Y1,-Y2=Y2 --evdev-keymap BTN_START=start,KEY_HOMEPAGE=guide,KEY_BACK=back,BTN_A=A,BTN_B=B,BTN_X=X,BTN_Y=Y,BTN_TL=LB,BTN_TR=RB --mimic-xpad --detach-kernel-driver --controller-slot 0 
