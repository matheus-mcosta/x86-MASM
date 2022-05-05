; 
;====================================================================
;  V 1: receber nome do arquivo para leitura
;  V 2: abrir arquivo e contar numero de bytes lidos
;  V 3: ler caractere por caractere e ir somando em 4 somas
;   4: fechar arquivo
;  V 5: imprimir numero de bytes lidos
;   6: imprimir resultado
;   V 7: converter hex para ascii
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

FileNameDst		db		256 dup (?)		; Nome do arquivo a ser escrito
FileHandleDst	dw		0				; Handler do arquivo destino
FileBuffer		db		10 dup (?)		; Buffer de leitura do arquivo
FileHandle		dw		0				; Handler do arquivo
FileNameBuffer	db		150 dup (?)		; Buffer de leitura/escrita do arquivo
MsgPedeArquivo	db	"Nome do arquivo para abrir: ", 0

Buffer          dw        0         ; buffer registradores

Somaindex		dw		0				; Index da soma
Soma 			db 		4 dup (?)		; Soma dos caracteres

Temps 			dw 		4 dup (?)		; Tempo de execucao

NumeroBytes           dw       0
NumeroBytes2		  dw 	   0        ; numero de bytes lidos

MsgErroOpenFile		db	"Erro na abertura do arquivo.", CR, LF, 0
MsgErroCreateFile	db	"Erro na criacao do arquivo.", CR, LF, 0
MsgErroReadFile		db	"Erro na leitura do arquivo.", CR, LF, 0
MsgErroWriteFile	db	"Erro na escrita do arquivo.", CR, LF, 0

MsgPlus  			db	" + ", 0
MsgCRLF				db	CR, LF, 0

MsgSpace  			db		" ", 0

MsgBytesLidos        db	"Bytes: ", 0

MsgSoma				db	"Soma: ", 0

MAXSTRING	equ		12
String	db		MAXSTRING dup (?)
H2D		db		10 dup (?)

sw_n	dw	0
sw_f	db	0
sw_m	dw	0

    
	

    .code
	.startup        

    call	GetFileName     ; pede nome do arquivo


	lea		dx,FileName
    mov		al,0
	
	mov		ah,3dh
	int		21h
	mov		FileHandle,ax	
	jnc		Next1
	
	lea		bx,MsgErroOpenFile
	call	printf_s
	
	.exit	1

Next1:
    call	GetFileNameDst


	lea		dx,FileNameDst
	call	fcreate
	mov		FileHandleDst,bx
	jnc		Ciclo




	mov		bx,FileHandle
	call	fclose
	lea		bx, MsgErroCreateFile
	call	printf_s
	.exit	1
    
	


Ciclo:
    mov		bx,FileHandle
	mov		ah,3fh
	mov		cx,1
	lea		dx,FileBuffer
	int		21h

	mov		dl,FileBuffer
	

fimgetChar:
    
	jnc		Next2 

    lea		bx,MsgErroReadFile
	call	printf_s
	
    mov		al,1
	jmp		CloseAndFinal


Next2:
    
    cmp		ax,0
	je		Fim
	cmp dl, '~'
	jg 		Ciclo

	mov     bx,[Somaindex]

	add 	[Soma+bx],dl
	inc		bx
	cmp 	bx,3
	jg 		ZeraIndex

	mov		[Somaindex],bx

	jmp		DepoisZera



ZeraIndex:
	mov 	bx, 0
	mov 	[Somaindex],bx

DepoisZera:
	mov     bx, 1
    add     NumeroBytes, bx
	JNO      Over
	add     NumeroBytes, bx
	add   NumeroBytes2, 65535


Over:


	mov	    bx, FileHandleDst
	call 	setChar
	jnc 	Ciclo

	lea		bx, MsgErroWriteFile
	call	printf_s
	mov		bx,FileHandle		; Fecha arquivo origem
	call	fclose
	mov		bx,FileHandleDst		; Fecha arquivo destino
	call	fclose
	.exit	1
	


Next3:


    jmp Ciclo

	mov		al,0
	jmp		CloseAndFinal

Fim:
        lea		bx, MsgCRLF
	    call	printf_s

        lea     bx, MsgBytesLidos
        call    printf_s

		mov     ax,NumeroBytes2
		cmp    ax,0
		je		Fim2
		
		lea		bx,String
		call	sprintf_w

		; printf("%s", String);

		lea		bx,String
		call	printf_s
	
		 lea		bx, MsgPlus
	    call	printf_s
Fim2:	
		mov     ax,NumeroBytes
		
		lea		bx,String
		call	sprintf_w

		; printf("%s", String);

		lea		bx,String
		call	printf_s

		lea		bx, MsgCRLF
	    call	printf_s

		lea		bx, MsgSoma
	    call	printf_s

		mov     ah, 0
        mov		al,[Soma]

		call hex
		
	;	lea		bx,String
	;	call	sprintf_w
	;	lea		bx,String
	;	call	printf_s

		lea		bx, MsgSpace
	    call	printf_s

		mov     ah, 0
        mov		al,[Soma+1]
		
		call hex

		lea		bx, MsgSpace
	    call	printf_s

		mov     ah, 0
        mov		al,[Soma+2]
		
		call hex

		lea		bx, MsgSpace
	    call	printf_s

		mov     ah, 0
        mov		al,[Soma+3]
		
		call hex




        .exit


CloseAndFinal:
	mov		bx,FileHandle		; Fecha o arquivo
	mov		ah,3eh
	int		21h

	mov		bx,FileHandleDst		; Fecha o arquivo
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
	;printf("Nome do arquivo origem: ")
	lea		bx, MsgPedeArquivo
	call	printf_s

	;gets(FileNameSrc);
	lea		bx, FileName
	call	gets
	
	;printf("\r\n")
	lea		bx, MsgCRLF
	call	printf_s
	
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

GetFileNameDst	proc	near
	;printf("Nome do arquivo destino: ");
	lea  si, FileName
	lea  di, FileNameDst

Lx:
    mov  al,[si]          
    mov  [di],al           
    inc  si              
    inc  di
    cmp byte ptr [di],0   ; Check for null terminator
    jne Lx                 ; loop if not null

	mov  [di],'.'
	inc  di
	mov  [di],'r'
	inc  di
	mov  [di],'e'
	inc  di
	mov  [di],'s'
	inc  di
	mov  [di],0

	;printf("\r\n")
	lea		bx, MsgCRLF
	call	printf_s
	
	ret
GetFileNameDst	endp

gets	proc	near
	push	bx

	mov		ah,0ah						; L� uma linha do teclado
	lea		dx,String
	mov		byte ptr String, MAXSTRING-4	; 2 caracteres no inicio e um eventual CR LF no final
	int		21h

	lea		si,String+2					; Copia do buffer de teclado para o FileName
	pop		di
	mov		cl,String+1
	mov		ch,0
	mov		ax,ds						; Ajusta ES=DS para poder usar o MOVSB
	mov		es,ax
	rep 	movsb

	mov		byte ptr es:[di],0			; Coloca marca de fim de string
	ret
gets	endp


fopen	proc	near
	mov		al,0
	mov		ah,3dh
	int		21h
	mov		bx,ax
	ret
fopen	endp

;--------------------------------------------------------------------
;Fun��o Cria o arquivo cujo nome est� no string apontado por DX
;		boolean fcreate(char *FileName -> DX)
;Sai:   BX -> handle do arquivo
;       CF -> 0, se OK
;--------------------------------------------------------------------
fcreate	proc	near
	mov		cx,0
	mov		ah,3ch
	int		21h
	mov		bx,ax
	ret
fcreate	endp

;--------------------------------------------------------------------
;Entra:	BX -> file handle
;Sai:	CF -> "0" se OK
;--------------------------------------------------------------------
fclose	proc	near
	mov		ah,3eh
	int		21h
	ret
fclose	endp

;--------------------------------------------------------------------
;Fun��o	Le um caractere do arquivo identificado pelo HANLDE BX
;		getChar(handle->BX)
;Entra: BX -> file handle
;Sai:   dl -> caractere
;		AX -> numero de caracteres lidos
;		CF -> "0" se leitura ok
;--------------------------------------------------------------------

		
;--------------------------------------------------------------------
;Entra: BX -> file handle
;       dl -> caractere
;Sai:   AX -> numero de caracteres escritos
;		CF -> "0" se escrita ok
;--------------------------------------------------------------------
setChar	proc	near
	mov		ah,0
	mov al, dl
	mov cx, 0
	mov dx, 0

label2:
	cmp ax, 0
	je print2

	mov bx, 16
	div bx
	push dx
	inc cx 

	mov dx, 0
	jmp label2

print2:
	cmp cx, 0
	je exit2

	pop dx

	cmp dx, 9
	jle continue2

	add dx, 7

continue2:
	add dx, 48
	mov [Temps], cx
	mov [Temps+2], bx
	



	
	mov  	bx, FileHandleDst
	mov		ah,40h
	mov		cx,1
	mov     dh, 0
	mov		FileBuffer,dl
	lea		dx,FileBuffer
	int		21h


	mov bx, [Temps+2]
	mov cx, [Temps]
	dec cx
	jmp print2
exit2:
	ret
setChar	endp	


 hex proc near
  
;initialize count
    mov cx, 0
	mov dx, 0
 label1:
;if  ax is zero
    cmp ax, 0
	je print1
  
;initialize bx to 16 
mov bx, 16
  
;divide it by 16
;to convert it to Hexadecimal
    div bx
  
;push it in the stack
    push dx
  
;increment the count
    inc cx
  
;set dx to 0
    xor dx, dx
    jmp label1
print1:
;check if count
;is greater than zero
    cmp cx,0 
	je exit
  
;pop the top of stack
    pop dx
  
;compare the value
;with 9 
cmp dx, 9 
jle continue
  
;if value is greater than 9
;then add 7 so that after
;adding 48 it represents A
;for example 10 + 7 + 48 = 65
;which is ASCII value of A
    add dx, 7
  
continue:
  
;add 48 so that it
;represents the ASCII
;value of digits
    add dx,48
  
;interrupt to print a;

    mov ah,02h
	int 21h
	


  
;decrease the count
    dec cx
    jmp print1
 exit : 
 ret
hex endp

;--------------------------------------------------------------------
		end
;--------------------------------------------------------------------


	

