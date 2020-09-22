; Generated by Modix - 1.3
; Modified by fxstein 2020-06-10
;
; Changelog:

; Duet2Wifi Only:
; - Converted bed heater to Duet controller via k-coupler daughter board
; - Force join wireless network to support hidden SSID
; - Increased extruder max speed from 1200mm/min to 12000mm/min for quicker retractions
; - Increased extruder max acceleration from 250mm/s^2 to 8000mm/s^2 for quicker retractions
; - Increased extruder max instantaneous speed change from 120mm/min to 3000mm/min for quicker retractions
;   Quicker retractions aid in elimination of Volcano stringing
; - Increase Z max speed from 200mm/min to 300mm/min or 5mm/s for quicker z-hops
; - Recalibrated extruder steps per mm
; - Replace tmep sensor with PT1000 and increase max temp to 300C
;
; Duet2Wifi + Duex5
; - Split x-axis to individual drives 0:5
; - Split z-axis to individual drives 2:6:7:8
; - Increase max speed for X & Y to 18000 or 300mm/s
; - Increase max speed for Z to 900mm/min or 15mm/s for quicker z-hops
; - Increase max acceleration for X & Y to 3000 mm/s^2 (tested to 4000)
; - Increase max print acceleration to 1000 mm/s^2
; - Increase max travel acceleration to 2000 mm/s^2
; - Increase X & Y max instantaneous speed change to 600 mm/min
; - Setup and tuned stall guard for all axis - now with individual motor control possible
; - Add Duet and Duex PWM fans
; - Add LED control via heater 5 and PWM fan
; - Switch permanent tool cooling fans to temperature control
;
; Modix Big-60, Dual Printhead

; General preferences
G90									; Send absolute coordinates...
M83									; ...but relative extruder moves

; Network
M550 P"BIG60V3"						; Set machine name
									; See secrets.g for setting passwords and sensitive information
; Set secrets and passwords
M98 P"secrets.g"					; See secrets-example.g for first time setup

; Logging
M929 P"eventlog.txt" S1 			; Start logging to file eventlog.txt for e.g. stalls and other significant events

; Finish network setup
M552 P"IoT Network" S1				; Enable network and force join (if hidden) network
M586 P0 S1							; Enable HTTP
M586 P1 S0							; Disable FTP
M586 P2 S0							; Disable Telnet

; Drives
M569 P0 S1							; Physical drive 0 goes forwards. X-Axis. X1
M569 P1 S0							; Physical drive 1 goes backwards. Y-Axis.
M569 P2 S0							; Physical drive 2 goes backwards. Z-Axis. ZL1
M569 P3 S1							; Physical drive 3 goes forwards. E0-Extruder.
M569 P4 S0							; Physical drive 4 goes backwards. E1-Extruder.

; Duex5 expansion must come before M350 and M906
M569 P5 S0							; Physical drive 5 goes backwards. X-Axis. X2
M569 P6 S0							; Physical drive 6 goes backwards. Z-Axis. ZL2
M569 P7 S0							; Physical drive 7 goes backwards. Z-Axis. ZR1
M569 P8 S0							; Physical drive 8 goes backwards. Z-Axis. ZR2

; Setup combined axis - must define all axis and all extruders in order to remove extruder default assignements
M584 X0:5							; combine drive 0 (X1) and 5 (X2) for X-Axis
M584 Y1								; single drive 1 for Y-Axis
M584 Z2:6:7:8						; combine drives 2 (ZL1), 6 (ZL2), 7 (ZR1), 8(ZR2) for Z-Axis
M584 E3:4							; only 2 extruders to release the remaining Duex5 drivers from default extruder mapping

; Continue Drives setup
M350 X16 Y16 Z16 E16 I1				; Configure microstepping with interpolation
M92 X100 Y100 Z2000 E399			; Set steps per mm
M906 X1800 Y1800 Z1800 E1000 I30	; Set motor currents (mA) and motor idle factor in %
M84 S30								; Set idle timeout
M915 X S15 H200 F0 R2				; Stall detection. For X axis. Pause print
M915 Y S17 H200 F0 R2				; Stall detection. For Y axis. Pause print
M915 Z S16 H200 F0 R2				; Stall detection. For Z axis. Pause print
M915 P3:4 S7 H200 F0 R1				; Stall detection. For extruders. Just log it.

; Speed Settings
M201 X3000 Y3000 Z150 E8000			; Set maximum accelerations (mm/s^2)
M203 X18000 Y18000 Z900 E12000		; Set maximum speeds (mm/min)
M204 P1000 T2000					; Set print and travel accelerations  (mm/s^2)
M566 X600 Y600 Z10 E3000			; Set maximum instantaneous speed changes (mm/min)
M593 F30							; Cancel ringing at 30Hz

; Axis Limits
M208 X0 Y0 Z0 S1					; Set axis minima
M208 X600 Y600 Z660 S0				; Set axis maxima

; Endstops
M574 X1 Y2 S1						; Set active low and disabled endstops

; Z-Probe
M574 Z2 S2							; Set endstops controlled by probe
;M307 H3 A-1 C-1 D-1				; Disable heater on PWM channel for BLTouch
M307 H7 A-1 C-1 D-1					; Disable heater on PWM channel for BLTouch via PWM5 (Heater 7) on Duex5
;M558 P9 H5 F120 T6000 A1 R0.7		; Set Z probe type to bltouch and the dive height + speeds
M558 P9 H2 F120 T18000 A1 R0		; Set Z probe type to bltouch and the dive height + speeds
G31 P500 X-13 Y-18 Z2.546			; Set Z probe trigger value, offset and trigger height(Z-Offset)
M557 X0:580 Y0:580 P8:8				; Define mesh grid. 64 Points
M376 H10							; Height (mm) over which to taper off the bed compensation

; Z leadscrew positions - mainly when used with Duex5 expansion and individual z motor drivers
M671 X0:0:600:600 Y0:600:0:600		; Z leadscrews are approx at (0,0), (0,600), (600,0) and (600,600)
; TODO: correct leadscrew positions

; Heaters
;Bed:
;M140 H-1							; To disable heated bed
M305 P0 X150						; Add K-type thermocoupler for bed heater
M140 H0								; Enable heated bed
M143 H0 S120						; Set temperature limit for heater 0 to 120C
;M307 H0 A# C# D# V# S1.0 B0		; PID calibration template
M307 H0 A19 C26 D4 V24 S1.0 B0		; PID calibration from macro run

;E0:
;M305 P1 T100000 B4725 C7.060000e-8 R4700	; Set thermistor + ADC parameters for heater 1
M305 P1 X501 								; heater 1 uses a PT1000 connected to thermistor channel 1
M143 H1 S300								; Set temperature limit for heater 1 to 300C
;M307 H1 A# C# D# V# S1.0 B0				; PID calibration template
;M307 H1 A19 C26 D4 V24 S1.0 B0				; PID calibration from macro run

;E1:
;M305 P2 T100000 B4725 C7.060000e-8 R4700	; Set thermistor + ADC parameters for heater 2
M305 P2 X502 								; heater 2 uses a PT1000 connected to thermistor channel 2
M143 H2 S300								; Set temperature limit for heater 2 to 300C
;M307 H2 A# C# D# V# S1.0 B0				; PID calibration template
;M307 H2 A19 C26 D4 V24 S1.0 B0				; PID calibration from macro run

; Fans
M106 P0 S0 I0 F500 H-1 C"E0 Print Fan"		; Set fan 0 value, PWM signal inversion and frequency. Thermostatic control is turned off
M106 P1 S0 I0 F500 H-1 C"E1 Print Fan"		; Set fan 1 value, PWM signal inversion and frequency. Thermostatic control is turned off
; Duex5 expansion
M106 P2 T35:65 B10 H100:101:102 C"Duet Fan"	; Thermostatic fan to cool the Duet2
M106 P3 T35:65 B10 H100:101:102 C"Duex Fan"	; Thermostatic fan to cool the Duex5
M106 P4 T40:50 B10 H1 C"E0 Cool Fan"		; Thermostatic fan for cool side of E0 only when tool is heated
M106 P5 T40:50 B10 H2 C"E1 Cool Fan"		; Thermostatic fan for cool side of E1 only when tool is heated

; Tools
M563 P0 S"E0" D0 H1 F0				; Define tool 0
G10 P0 X0 Y0 Z0						; Set tool 0 axis offsets
G10 P0 R190 S210					; Set initial tool 0 active and standby temperatures to 0C
M563 P1 S"E1" D1 H2 F1				; Define tool 1
G10 P1 X0 Y51.5 Z0					; Set tool 1 axis offsets
G10 P1 R190 S210					; Set initial tool 1 active and standby temperatures to 0C

; Automatic power saving
M911 S22.5 R29.0 P"M913 X0 Y0 G91 M83 G1 Z3 E-5 F1000"	; Set voltage thresholds and actions to run on power loss. Power Failure Pause

; LED Lights - Duex5
M307 H6 A-1 C-1 D-1					; Use heater 5 for LED lights on Duex5
;M106 P6 S1.0 C"LEDs" A6			; Map to fan control, name and set to full bright
M106 P6 B1800 C"LEDs" A6			; Map to fan control, name and set to full bright for 30 min
M106 P6 S0.01						; Trigger blip of 1800 sec or 30 min full bright than go to 1%

; Custom settings
;M564 H0 S0							; Negative movements are allowed
G29 S1								; Load the height map from file and activate bed compensation
M591 D0 P1 C3 S1					; Regular filament sensor for E0
M591 D1 P1 C4 S1					; Regular filament sensor for E1
;M581 E2 S1 T0 C0					; Optional external switch for emergency stop
;M592 D0 A0.01 B0.0005 L0.25		; The amount of extrusion requested is multiplied by (1 + min(L, A*v + B*v^2)) where v is the requested extrusion speed (calculated from the actual speed at which the move will take place) in mm/sec.
;M592 D1 A0.01 B0.0005 L0.25		; The amount of extrusion requested is multiplied by (1 + min(L, A*v + B*v^2)) where v is the requested extrusion speed (calculated from the actual speed at which the move will take place) in mm/sec.
