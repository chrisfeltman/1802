	INCL '../1802-bios/bios.asm'


main:
	call init_lcd
main_loop:
	call blink_q
	load RA, out
	call output_string
	call clear_display
	load RA, out2
	call output_string
	call clear_display
	lbr main_loop

out:
	text "My program is cool............."
	db 0
out2:
	text "Too bad you're not!!!!!!!!!!!!!"
	db 0
	end

