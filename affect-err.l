%include	'io.asm'

section	.bss
sinput:	resb	255	;reserve a 255 byte space in memory for the users input string
v$tab:	resd	10

section	.text
global _start
_start:
	call	main
	mov	eax, 1		 ; 1 est le code de SYS_EXIT
	int	0x80		 ; exit
initialiser:
	push	ebp		 ; sauvegarde la valeur de ebp
	mov	ebp, esp		 ; nouvelle valeur de ebp
	push	8
	push	0
	pop	eax
	add	eax, eax
	add	eax, eax
	pop	ebx
	mov	[v$tab + eax], ebx		 ; stocke registre dans variable
	push	6
	push	1
	pop	eax
	add	eax, eax
	add	eax, eax
	pop	ebx
	mov	[v$tab + eax], ebx		 ; stocke registre dans variable
	push	9
	push	2
	pop	eax
	add	eax, eax
	add	eax, eax
	pop	ebx
	mov	[v$tab + eax], ebx		 ; stocke registre dans variable
	push	9
	push	3
	pop	eax
	add	eax, eax
	add	eax, eax
	pop	ebx
	mov	[v$tab + eax], ebx		 ; stocke registre dans variable
	push	4
	push	4
	pop	eax
	add	eax, eax
	add	eax, eax
	pop	ebx
	mov	[v$tab + eax], ebx		 ; stocke registre dans variable
	push	2
	push	5
	pop	eax
	add	eax, eax
	add	eax, eax
	pop	ebx
	mov	[v$tab + eax], ebx		 ; stocke registre dans variable
	push	3
	push	6
	pop	eax
	add	eax, eax
	add	eax, eax
	pop	ebx
	mov	[v$tab + eax], ebx		 ; stocke registre dans variable
	push	1
	push	7
	pop	eax
	add	eax, eax
	add	eax, eax
	pop	ebx
	mov	[v$tab + eax], ebx		 ; stocke registre dans variable
	push	4
	push	8
	pop	eax
	add	eax, eax
	add	eax, eax
	pop	ebx
	mov	[v$tab + eax], ebx		 ; stocke registre dans variable
	push	5
	push	9
	pop	eax
	add	eax, eax
	add	eax, eax
	pop	ebx
	mov	[v$tab + eax], ebx		 ; stocke registre dans variable
	pop	ebp		 ; restaure la valeur de ebp
	ret
afficher:
	push	ebp		 ; sauvegarde la valeur de ebp
	mov	ebp, esp		 ; nouvelle valeur de ebp
	sub	esp, 4	; allocation variables locales
	push	0
	pop	ebx
	mov	[ebp - 4], ebx		 ; stocke registre dans variable
e0:
	mov	ebx, [ebp - 4]		 ; lit variable dans ebx
	push	ebx
	mov	ebx, [ebp + 8]		 ; lit variable dans ebx
	push	ebx
	pop	ebx		 ; depile la seconde operande dans ebx
	pop	eax		 ; depile la permière operande dans eax
	cmp	eax, ebx
	jl	e2
	push	0
	jmp	e3
e2:
	push	1
e3:
	pop	eax
	cmp	eax, 00
	jz	e1
	mov	ebx, [ebp - 4]		 ; lit variable dans ebx
	push	ebx
	pop	eax
	add	eax, eax
	add	eax, eax
	mov	ebx, [v$tab + eax]		 ; lit variable dans ebx
	push	ebx
	pop	eax
	call	iprintLF
	mov	ebx, [ebp - 4]		 ; lit variable dans ebx
	push	ebx
	push	1
	pop	ebx		 ; depile la seconde operande dans ebx
	pop	eax		 ; depile la permière operande dans eax
	add	eax, ebx		 ; effectue l'opération
	push	eax		 ; empile le résultat
	pop	ebx
	mov	[ebp - 4], ebx		 ; stocke registre dans variable
	jmp	e0
e1:
	push	0
	pop	eax
	call	iprintLF
	add	esp, 4	; desallocation variables locales
	pop	ebp		 ; restaure la valeur de ebp
	ret
echanger:
	push	ebp		 ; sauvegarde la valeur de ebp
	mov	ebp, esp		 ; nouvelle valeur de ebp
	sub	esp, 4	; allocation variables locales
	mov	ebx, [ebp + 8]		 ; lit variable dans ebx
	push	ebx
	pop	eax
	add	eax, eax
	add	eax, eax
	mov	ebx, [v$tab + eax]		 ; lit variable dans ebx
	push	ebx
	pop	ebx
	mov	[ebp - 4], ebx		 ; stocke registre dans variable
	mov	ebx, [ebp + 12]		 ; lit variable dans ebx
	push	ebx
	pop	eax
	add	eax, eax
	add	eax, eax
	mov	ebx, [v$tab + eax]		 ; lit variable dans ebx
	push	ebx
	mov	ebx, [ebp + 8]		 ; lit variable dans ebx
	push	ebx
	pop	eax
	add	eax, eax
	add	eax, eax
	pop	ebx
	mov	[v$tab + eax], ebx		 ; stocke registre dans variable
	mov	ebx, [ebp - 4]		 ; lit variable dans ebx
	push	ebx
	mov	ebx, [ebp + 12]		 ; lit variable dans ebx
	push	ebx
	pop	eax
	add	eax, eax
	add	eax, eax
	pop	ebx
	mov	[v$tab + eax], ebx		 ; stocke registre dans variable
	add	esp, 4	; desallocation variables locales
	pop	ebp		 ; restaure la valeur de ebp
	ret
trier:
	push	ebp		 ; sauvegarde la valeur de ebp
	mov	ebp, esp		 ; nouvelle valeur de ebp
	sub	esp, 12	; allocation variables locales
	mov	ebx, [ebp + 8]		 ; lit variable dans ebx
	push	ebx
	pop	ebx
	mov	[ebp - 12], ebx		 ; stocke registre dans variable
	push	1
	pop	ebx
	mov	[ebp - 4], ebx		 ; stocke registre dans variable
e4:
	mov	ebx, [ebp - 4]		 ; lit variable dans ebx
	push	ebx
	push	1
	pop	ebx		 ; depile la seconde operande dans ebx
	pop	eax		 ; depile la permière operande dans eax
	cmp	eax, ebx
	je	e6
	push	0
	jmp	e7
e6:
	push	1
e7:
	pop	eax
	cmp	eax, 00
	jz	e5
	push	0
	pop	ebx
	mov	[ebp - 4], ebx		 ; stocke registre dans variable
	push	0
	pop	ebx
	mov	[ebp - 8], ebx		 ; stocke registre dans variable
e8:
	mov	ebx, [ebp - 8]		 ; lit variable dans ebx
	push	ebx
	mov	ebx, [ebp - 12]		 ; lit variable dans ebx
	push	ebx
	push	1
	pop	ebx		 ; depile la seconde operande dans ebx
	pop	eax		 ; depile la permière operande dans eax
	sub	eax, ebx		 ; effectue l'opération
	push	eax		 ; empile le résultat
	pop	ebx		 ; depile la seconde operande dans ebx
	pop	eax		 ; depile la permière operande dans eax
	cmp	eax, ebx
	jl	e10
	push	0
	jmp	e11
e10:
	push	1
e11:
	pop	eax
	cmp	eax, 00
	jz	e9
	mov	ebx, [ebp - 8]		 ; lit variable dans ebx
	push	ebx
	push	1
	pop	ebx		 ; depile la seconde operande dans ebx
	pop	eax		 ; depile la permière operande dans eax
	add	eax, ebx		 ; effectue l'opération
	push	eax		 ; empile le résultat
	pop	eax
	add	eax, eax
	add	eax, eax
	mov	ebx, [v$tab + eax]		 ; lit variable dans ebx
	push	ebx
	mov	ebx, [ebp - 8]		 ; lit variable dans ebx
	push	ebx
	pop	eax
	add	eax, eax
	add	eax, eax
	mov	ebx, [v$tab + eax]		 ; lit variable dans ebx
	push	ebx
	pop	ebx		 ; depile la seconde operande dans ebx
	pop	eax		 ; depile la permière operande dans eax
	cmp	eax, ebx
	jl	e14
	push	0
	jmp	e15
e14:
	push	1
e15:
	pop	eax
	cmp	eax, 00
	jz	e13
	sub	esp, 4		 ; allocation valeur de retour
				; empile arg 0
	mov	ebx, [ebp - 8]		 ; lit variable dans ebx
	push	ebx
				; empile arg 1
	mov	ebx, [ebp - 8]		 ; lit variable dans ebx
	push	ebx
	push	1
	pop	ebx		 ; depile la seconde operande dans ebx
	pop	eax		 ; depile la permière operande dans eax
	add	eax, ebx		 ; effectue l'opération
	push	eax		 ; empile le résultat
	call	echanger
	add	esp, 8		; desallocation parametres
	add	esp, 4		 ; valeur de retour ignoree
	push	1
	pop	ebx
	mov	[ebp - 4], ebx		 ; stocke registre dans variable
e13:
	mov	ebx, [ebp - 8]		 ; lit variable dans ebx
	push	ebx
	push	1
	pop	ebx		 ; depile la seconde operande dans ebx
	pop	eax		 ; depile la permière operande dans eax
	add	eax, ebx		 ; effectue l'opération
	push	eax		 ; empile le résultat
	pop	ebx
	mov	[ebp - 8], ebx		 ; stocke registre dans variable
	jmp	e8
e9:
	mov	ebx, [ebp - 12]		 ; lit variable dans ebx
	push	ebx
	push	1
	pop	ebx		 ; depile la seconde operande dans ebx
	pop	eax		 ; depile la permière operande dans eax
	sub	eax, ebx		 ; effectue l'opération
	push	eax		 ; empile le résultat
	pop	ebx
	mov	[ebp - 12], ebx		 ; stocke registre dans variable
	jmp	e4
e5:
	add	esp, 12	; desallocation variables locales
	pop	ebp		 ; restaure la valeur de ebp
	ret
main:
	push	ebp		 ; sauvegarde la valeur de ebp
	mov	ebp, esp		 ; nouvelle valeur de ebp
	sub	esp, 4		 ; allocation valeur de retour
	call	initialiser
	add	esp, 4		 ; valeur de retour ignoree
	sub	esp, 4		 ; allocation valeur de retour
				; empile arg 0
	push	10
	call	afficher
	add	esp, 4		; desallocation parametres
	add	esp, 4		 ; valeur de retour ignoree
	sub	esp, 4		 ; allocation valeur de retour
				; empile arg 0
	push	10
	call	trier
	add	esp, 4		; desallocation parametres
	add	esp, 4		 ; valeur de retour ignoree
	sub	esp, 4		 ; allocation valeur de retour
				; empile arg 0
	push	10
	call	afficher
	add	esp, 4		; desallocation parametres
	add	esp, 4		 ; valeur de retour ignoree
	pop	ebp		 ; restaure la valeur de ebp
	ret

