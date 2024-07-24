; Program do puszczania dźwięków napisany w taki sposób, aby łatwo zapisywać i puszczać utwory muzyczne.
; Źródło, z którego pobrałam wartości odpowiadające częstotliwości poszczególnych tonów oraz oryginalną funkcję puszczania pojedynczego dźwięku:
; http://muruganad.com/8086/8086-assembly-language-program-to-play-sound-using-pc-speaker.html
; Aby zapisać dowolny utwór, należy utworzyć tablicę, w której każdy dźwięk jest zapisany w 4 bajtach - pierwsze 3 to ton, ostatni to długość.
; Przed tablicą należy podać zmienną zawierającą ilość dzwięków w danym utworze. Po przekazaniu adresu tablicy do bp można wywołać funkcję playsong,
; która odszyfrowuje ton zapisany stringiem na odpowiednią częstotliwość i puszcza go przez podany czas, a następnie wykonuje ten proces
; zadeklarowaną ilość razy. Dzięki temu zagranie całego utworu wymaga jedynie zapisania dźwięków w jednej czytelnej tablicy.
; Program zawiera 3 przykładowe utwory z gier. Aranżacja jest moja własna.

org 100h
	
menu:
	mov	ah, 9
	mov	dx, menutxt1
	int	21h
	
	mov	ah, 2
	mov	dx, 36
	int	21h
	
	mov	ah, 9
	mov	dx, menutxt2
	int	21h

inp:
	mov	ah, 00h
	int	16h
	
	cmp	ah, 1
	je	close
	
	cmp	ah, 2
	je	fallendown
	
	cmp	ah, 3
	je	stw
	
	cmp	ah, 4
	je	sacrificial
	
	jmp	inp
	
fallendown:				; Fallen Down - Toby Fox (from "Undertale")
	mov	ah, 9
	mov	dx, pfd
	int	21h
	
	mov	bp, fdn
	call	playsong
	
	mov	ah, 9
	mov	dx, ent
	int	21h
	
	jmp	menu
	
stw:					; Sunlight Through Water - Bill Kiley (from "Why Am I Dead at Sea")
	mov	ah, 9
	mov	dx, pstw
	int	21h
	
	mov	bp, stwn
	call	playsong
	
	mov	ah, 9
	mov	dx, ent
	int	21h

	jmp	menu
	
sacrificial:			; $4cr1f1c1a|_ - Danny Baranowsky (from "The Binding of Isaac")
	mov	ah, 9
	mov	dx, psac1
	int	21h
	
	mov	ah, 2
	mov	dx, 36
	int	21h
	
	mov	ah, 9
	mov	dx, psac2
	int	21h
	
	mov	bp, sacn
	call	playsong
	
	mov	ah, 9
	mov	dx, ent
	int	21h
	
	jmp	menu
	
playsong:
	xor	dx, dx
	xor	cx, cx
	xor	bx, bx
	mov dl, [bp - 1]
	
	xor si, si
	xor	di, di
	tofreq:
		xor	di, di
	
		mov	al, [bp + si + 2]
		cmp	al, 54	; 6
		je	fin
			
		inc	di
		cmp	al, 53	; 5
		je	ifsharp
		
		add	di, 12
		cmp	al, 52	; 4
		je	ifsharp
		
		add	di, 12	; tu musi byc 3
		
		ifsharp:
		mov	al, [bp + si + 1]
		cmp	al, 48	; 0
		je	note
		
		dec	di	; tu musi byc #
		
		note:
		mov	al, [bp + si]
		cmp	al, 'H'
		je	fin
		
		add	di, 2
		cmp	al, 'A'
		je	fin
		
		add	di, 2
		cmp	al, 'G'
		je	fin
		
		add	di, 2
		cmp	al, 'F'
		je	fin
		
		inc	di
		cmp	al, 'E'
		je	fin
		
		add	di, 2
		cmp	al, 'D'
		je	fin
		
		add	di, 2	; tu juz musi byc C
		
		fin:		
		add	di, di
		mov	cx, [notes + di]
		mov bl, [bp + si + 3]
		
		add si, 4
		call playnote
		
	dec dx
	jnz tofreq
ret
	
playnote:	; cx - tone, bx - duration
	mov	al, 182
	out	43h, al
	mov	ax, cx
	
	out	42h, al
	mov	al, ah
	out	42h, al
	in	al, 61h
	
	or	al, 00000011b
	out	61h, al
	
	push bx
	call sleep
	pop bx
	
	
	in	al, 61h
	and	al, 11111100b ; koniec
	out	61h, al
ret

sleep:
	pusha
	pushf
	
	mov bp, sp
	mov bx, [bp + 20] ; bx = duration
	
	.for1:
		mov cx, 30000
		.for2:
			nop
		loop .for2
	dec bx
	jnz .for1
	
	popf
	popa
ret

close:	
	mov	ax, 4C00h
	int	21h

menutxt1	db	10, 13, "Wybierz utw", 162, "r:", 10, 13, "1 - Fallen Down - Toby Fox (from ", 34, "Undertale", 34, ")", 10, 13, "2 - Sunlight Through Water - Bill Kiley (from ", 34, "Why Am I Dead at Sea", 34, ")", 10, 13, "3 - $"
menutxt2	db	"4cr1f1c1a|_ - Danny Baranowsky (from ", 34, "The Binding of Isaac", 34, ")", 10, 13, "ESC - Zako", 228, "cz program", 10, 13, "$"
pfd		db	14, " Fallen Down ", 14, "$"
pstw	db	14, " Sunlight Through Water ", 14, "$"
psac1	db	14, 32, "$"
psac2	db	"4cr1f1c1a|_ ", 14, "$"
ent		db	10, 13, "$"

fdd		db	43
fdn		db	"F#5", 14
		db	"C#5", 14
		db	"F#5", 14
		db	"C#5", 14
		db	"F#5", 14
		db	"C#5", 14
		
		db	"F#5", 14
		db	"C#5", 14
		db	"F#5", 14
		db	"C#5", 14
		db	"F#5", 14
		db	"C#5", 14
		
		db	"H04", 14
		db	"A04", 14
		db	"C#5", 28
		db	"A04", 14
		db	"H04", 14
		
		db	"E05", 14
		db	"D#5", 14
		db	"E05", 14
		db	"F#5", 14
		db	"D#5", 14
		db	"H04", 14
		
		db	"F#5", 14
		db	"H04", 14
		db	"F#5", 14
		db	"H04", 14
		db	"F#5", 14
		db	"H04", 14
		
		db	"F#5", 14
		db	"A#4", 14
		db	"F#5", 14
		db	"A#4", 14
		db	"G05", 28
		
		db	"F#5", 14
		db	"D05", 14
		db	"F#5", 14
		db	"D05", 14
		db	"E05", 14
		db	"F#5", 14
		
		db	"E05", 28
		db	"D05", 28
		db	"C#5", 28

stwd	db	139
stwn	db	"F#5", 18
		db	"D05", 6
		db	"E05", 6
		db	"F#5", 6
		db	"A05", 18
		db	"H05", 18
		
		db	"F#5", 18
		db	"D05", 18
		db	"E05", 36
		
		db	"G03", 6
		db	"H03", 6
		db	"D04", 6
		db	"F#4", 6
		db	"D04", 6
		db	"H03", 6
		db	"G03", 6
		db	"H03", 6
		db	"D04", 6
		db	"F#4", 6
		db	"D04", 6
		db	"H03", 6

		db	"G03", 6
		db	"H03", 6
		db	"D04", 6
		db	"F#4", 6
		db	"D04", 6
		db	"H03", 6
		db	"G03", 6
		db	"H03", 6
		db	"D04", 6
		db	"F#3", 6
		db	"H03", 6
		db	"D04", 6
		
		db	"F#5", 18
		db	"D05", 6
		db	"E05", 6
		db	"F#5", 6
		db	"A05", 18
		db	"H05", 18
		
		db	"F#5", 18
		db	"D05", 18
		db	"C#5", 36
		
		db	"G03", 6
		db	"H03", 6
		db	"D04", 6
		db	"F#4", 6
		db	"D04", 6
		db	"H03", 6
		db	"G03", 6
		db	"H03", 6
		db	"D04", 6
		db	"F#4", 6
		db	"D04", 6
		db	"H03", 6

		db	"G03", 6
		db	"H03", 6
		db	"D04", 6
		db	"F#4", 6
		db	"D04", 6
		db	"H03", 6
		db	"G03", 6
		db	"H03", 6
		db	"D04", 6
		db	"F#3", 6
		db	"H03", 6
		db	"D04", 6
		
		db	"H04", 18
		db	"D05", 6
		db	"E05", 6
		db	"F#5", 6
		db	"G05", 18
		db	"F#5", 6
		db	"D05", 6
		db	"A04", 6
		
		db	"H04", 18
		db	"D05", 6
		db	"E05", 6
		db	"F#5", 6
		db	"G05", 6
		db	"F#5", 6
		db	"D05", 6
		db	"F#5", 6
		db	"D05", 6
		db	"F#4", 6
		
		db	"G04", 18
		db	"D05", 6
		db	"G05", 6
		db	"A05", 6
		db	"H05", 18
		db	"A05", 6
		db	"F#5", 6
		db	"E05", 6
		
		db	"D05", 18
		db	"A04", 6
		db	"F#4", 6
		db	"E04", 6
		db	"D04", 36
		
		db	"E04", 6
		db	"D04", 6
		db	"E04", 6
		db	"H03", 6
		db	"A03", 6
		db	"E03", 6
		db	"A03", 6
		db	"G03", 6
		db	"A03", 6
		db	"H03", 18
		
		db	"E03", 6
		db	"F#3", 12
		db	"G03", 12
		db	"A03", 6
		db	"H03", 6
		db	"D04", 6
		db	"E04", 6
		db	"G04", 6
		db	"F#4", 6
		db	"D04", 6
		
		db	"H04", 6
		db	"A04", 6
		db	"H04", 6
		db	"G04", 6
		db	"D04", 6
		db	"H03", 6
		db	"G03", 6
		db	"A03", 6
		db	"D04", 6
		db	"H03", 18
		
		db	"D03", 6
		db	"F#3", 6
		db	"A03", 6
		db	"D04", 6
		db	"A03", 6
		db	"F#3", 6
		db	"D04", 6
		db	"F#4", 6
		db	"A04", 6
		db	"D05", 6
		db	"A04", 6
		db	"F#4", 6
		
sacd	db	110
sacn	db	"E04", 16
		db	"C05", 24
		db	"G#4", 8
		db	"A04", 16
		db	"H04", 16
		db	"G04", 8
		db	"A04", 8
		
		db	"G04", 8
		db	"F#4", 8
		db	"E04", 32
		db	"H03", 16
		db	"G04", 24
		db	"D#4", 8
		
		db	"E04", 16
		db	"H04", 24
		db	"E04", 8
		db	"F#4", 16
		db	"G04", 16
		db	"A04", 8
		db	"H04", 8
		
		db	"E05", 16
		db	"H04", 16
		db	"A04", 16
		db	"G04", 16
		db	"A04", 8
		db	"H04", 8
		db	"A04", 8
		db	"G04", 8
		
		db	"F#4", 16
		db	"D#4", 16
		db	"E04", 16
		db	"F#4", 16
		db	"G04", 16
		db	"A04", 16
		
		db	"D#4", 16
		db	"E04", 16
		db	"F#4", 16
		db	"H03", 16
		db	"D#4", 16
		db	"F#4", 16
		
		db	"E05", 8
		db	"H04", 8
		db	"E05", 8
		db	"G05", 8
		db	"E05", 8
		db	"H04", 8
		db	"E05", 8
		db	"H04", 8
		db	"E05", 8
		db	"G05", 8
		db	"E05", 8
		db	"H04", 8
		
		db	"E05", 8
		db	"H04", 8
		db	"E05", 8
		db	"G05", 8
		db	"E05", 8
		db	"F#5", 4
		db	"E05", 4
		db	"D#5", 16
		db	"E05", 16
		db	"F#5", 16
		
		db	"H05", 32
		db	"F#5", 16
		db	"A05", 16
		db	"G05", 16
		db	"F#5", 16
		
		db	"E05", 24
		db	"F#5", 8
		db	"E05", 16
		db	"D#5", 32
		db	"H04", 16
		
		db	"C05", 32
		db	"H04", 16
		db	"A04", 16
		db	"H04", 16
		db	"A04", 16
		
		db	"G04", 16
		db	"A04", 16
		db	"G04", 16
		db	"F#4", 16
		db	"D#4", 16
		db	"F#4", 16
		
		db	"E05", 48
		db	"G05", 48
		
		db	"E05", 48
		db	"F#5", 48
		
		db	"G05", 96
		
		db	"A05", 48
		db	"G05", 48
		
		db	"E05", 144
		
		db	"F#5", 32
		db	"G05", 16
		
		db	"E05", 48
		db	"H04", 16
		db	"H04", 8
		db	"H04", 8
		db	"H04", 8
		db	"H04", 8
		
		db	"E05", 48
		db	"H04", 16
		db	"H04", 8
		db	"H04", 8
		db	"H04", 8
		db	"H04", 8
		
		db	"C05", 96
		
		db	"D05", 48
		db	"C05", 48
		
		db	"A04", 144
		
		db	"H04", 48
		
notes	dw	1140	; C06

		dw	1207	; H05
		dw	1292	; A#5
		dw	1355	; A05
		dw	1436	; G#5
		dw	1521	; G05
		dw	1612	; F#5
		dw	1715	; F05
		dw	1809	; E05
		dw	1917	; D#5
		dw	2031	; D05
		dw	2152	; C#5
		dw	2280	; C05
			
		dw	2415	; H04
		dw	2559	; A#4
		dw	2711	; A04
		dw	2873	; G#4
		dw	3043	; G04
		dw	3224	; F#4
		dw	3416	; F04
		dw	3619	; E04
		dw	3834	; D#4
		dw	4063	; D04
		dw	4304	; C#4
		dw	4560	; C04
			
		dw	4831	; H03
		dw	5119	; A#3
		dw	5423	; A03
		dw	5746	; G#3
		dw	6087	; G03
		dw	6449	; F#3
		dw	6833	; F03
		dw	7239	; E03
		dw	7670	; D#3
		dw	8126	; D03
		dw	8609	; C#3
		dw	9121	; C03