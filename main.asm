; Matheus de Moraes Costa 00297121
;====================================================================
;  V 1: receber nome do arquivo para leitura
;  V 2: abrir arquivo e contar numero de bytes lidos
;   3: ler caractere por caractere e ir somando em 4 somas
;   4: fechar arquivo
;   5: imprimir numero de bytes lidos
;   6: imprimir resultado
;   7: converter hex para ascii
;   8: criar arquivo de saida (nome do arquivo antes do ponto + .res)
;   9: escrever resultado no arquivo de saida
;   10: fechar arquivo de saida
;   

;====================================================================
;	
;	Programa baseado nos exemplos do fornecidos pelo professor
;   upper, sprintf_w, contador, ftype,cletra
;		
;====================================================================
;
.model		small
	.stack

CR		equ		0dh
LF		equ		0ah

	.data
FileName		db		256 dup (?)		; Nome do arquivo a ser lido
FileBuffer		db		10 dup (?)		; Buffer de leitura do arquivo
FileHandle		dw		0				; Handler do arquivo
FileNameBuffer	db		150 dup (?)		; Buffer de leitura/escrita do arquivo
MsgPedeArquivo	db	"Nome do arquivo para abrir: ", 0

Buffer          dw        0         ; buffer registradores

NumeroBytes           dw       0         ; numero de bytes lidos

MsgErroOpenFile		db	"Erro na abertura do arquivo.", CR, LF, 0
MsgErroCreateFile	db	"Erro na criacao do arquivo.", CR, LF, 0
MsgErroReadFile		db	"Erro na leitura do arquivo.", CR, LF, 0
MsgErroWriteFile	db	"Erro na escrita do arquivo.", CR, LF, 0
MsgCRLF				db	CR, LF, 0

MsgBytesLidos        db	"Bytes: ", 0

MAXSTRING	equ		12
String	db		MAXSTRING dup (?)
H2D		db		10 dup (?)

sw_n	dw	0
sw_f	db	0
sw_m	dw	0

    
	
    

    .code
	.startup        

    call	GetFileName     ; pede nome do arquivo

    mov		al,0
	lea		dx,FileName
	mov		ah,3dh
	int		21h
	jnc		Next1
	
	lea		bx,MsgErroOpenFile
	call	printf_s
	
	.exit	1

Next1:
    mov		FileHandle,ax	; salva handler do arquivo
    
	


Ciclo:
    mov		bx,FileHandle
	mov		ah,3fh
	mov		cx,1
	lea		dx,FileBuffer
    
	int		21h

    
	jnc		Next2 

    lea		bx,MsgErroReadFile
	call	printf_s
	
    mov		al,1
	jmp		CloseAndFinal


Next2:
    mov     bx, 1
    add     NumeroBytes, bx

    cmp		ax,0
	je		Fim

    jmp Ciclo

	mov		al,0
	jmp		CloseAndFinal

Fim:
        lea		bx, MsgCRLF
	    call	printf_s

        lea     bx, MsgBytesLidos
        call    printf_s
       
        mov		ax,NumeroBytes
		lea		bx,String
		call	sprintf_w

		; printf("%s", String);

		lea		bx,String
		call	printf_s

        .exit


CloseAndFinal:
	mov		bx,FileHandle		; Fecha o arquivo
	mov		ah,3eh
	int		21h
    .exit

;--------------------------------------------------------------------
;--------------------------------------------------------------------		
;-----------------FIM DO PRINCIPAL-----------------------------------
;--------------------------------------------------------------------
;--------------------------------------------------------------------
;--------------------------------------------------------------------
;--------------------------------------------------------------------
;--------------------------------------------------------------------
;--------------------------------------------------------------------
;--------------------------------------------------------------------

GetFileName	proc	near

	;	printf_s("Nome do arquivo: ");
	lea		bx,MsgPedeArquivo
	call	printf_s

	;	// L� uma linha do teclado
	;	FileNameBuffer[0]=100;
	;	gets(ah=0x0A, dx=&FileNameBuffer)
	mov		ah,0ah
	lea		dx,FileNameBuffer
	mov		byte ptr FileNameBuffer,100
	int		21h

	;	// Copia do buffer de teclado para o FileName
	;	for (char *s=FileNameBuffer+2, char *d=FileName, cx=FileNameBuffer[1]; cx!=0; s++,d++,cx--)
	;		*d = *s;		
	lea		si,FileNameBuffer+2
	lea		di,FileName
	mov		cl,FileNameBuffer+1
	mov		ch,0
	mov		ax,ds						; Ajusta ES=DS para poder usar o MOVSB
	mov		es,ax
	rep 	movsb

	;	// Coloca o '\0' no final do string
	;	*d = '\0';
	mov		byte ptr es:[di],0
	ret
GetFileName	endp


printf_s	proc	near
	mov		dl,[bx]
	cmp		dl,0
	je		ps_1

	push	bx
	mov		ah,2
	int		21H
	pop		bx

	inc		bx		
	jmp		printf_s
		
ps_1:
	ret
printf_s	endp

sprintf_w	proc	near

;void sprintf_w(char *string, WORD n) {
	mov		sw_n,ax

;	k=5;
	mov		cx,5
	
;	m=10000;
	mov		sw_m,10000
	
;	f=0;
	mov		sw_f,0
	
;	do {
sw_do:

;		quociente = n / m : resto = n % m;	// Usar instru��o DIV
	mov		dx,0
	mov		ax,sw_n
	div		sw_m
	
;		if (quociente || f) {
;			*string++ = quociente+'0'
;			f = 1;
;		}
	cmp		al,0
	jne		sw_store
	cmp		sw_f,0
	je		sw_continue
sw_store:
	add		al,'0'
	mov		[bx],al
	inc		bx
	
	mov		sw_f,1
sw_continue:
	
;		n = resto;
	mov		sw_n,dx
	
;		m = m/10;
	mov		dx,0
	mov		ax,sw_m
	mov		bp,10
	div		bp
	mov		sw_m,ax
	
;		--k;
	dec		cx
	
;	} while(k);
	cmp		cx,0
	jnz		sw_do

;	if (!f)
;		*string++ = '0';
	cmp		sw_f,0
	jnz		sw_continua2
	mov		[bx],'0'
	inc		bx
sw_continua2:


;	*string = '\0';
	mov		byte ptr[bx],0
		
;}
	ret
		
sprintf_w	endp
;--------------------------------------------------------------------
		end
;--------------------------------------------------------------------


	

