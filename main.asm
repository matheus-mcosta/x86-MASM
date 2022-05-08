;====================================================================
;  V 1: receber nome do arquivo para leitura
;  V 2: abrir arquivo e contar numero de bytes lidos
;  V 3: ler caractere por caractere e ir somando em 4 somas
;  V 4: fechar arquivo
;  V 5: imprimir numero de bytes lidos
;  V 6: imprimir resultado
;  V 7: converter hex para ascii
;  V 8: criar arquivo de saida (nome do arquivo antes do ponto + .res)
;  V 9: escrever resultado no arquivo de saida
;  V 10: fechar arquivo de saida
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

Counter		  dw        0         ; contador para indentacao arquivo
Somaindex		dw		0				; Index da soma
Soma 			db 		4 dup (?)		; Soma dos caracteres

Temps 			dw 		10 dup (?)		; Tempo de execucao

NumeroBytes           dw       0
NumeroBytes2		  dw 	   0        ; numero de bytes lidos

MsgErroOpenFile		db	"Erro na abertura do arquivo.", CR, LF, 0
MsgErroCreateFile	db	"Erro na criacao do arquivo.", CR, LF, 0
MsgErroReadFile		db	"Erro na leitura do arquivo.", CR, LF, 0
MsgErroWriteFile	db	"Erro na escrita do arquivo.", CR, LF, 0

MsgPlus  			db	" + ", 0 ; Mensagem para soma de bytes lidos
MsgCRLF				db	CR, LF, 0;	\n

MsgSpace  			db		" ", 0 ; mensage de space

MsgBytesLidos        db	"Bytes: ", 0 ; mensagem de bytes lidos

MsgSoma				db	"Soma: ", 0	; mensagem de soma

MAXSTRING	equ		12
String	db		MAXSTRING dup (?)	; String para imprimir

sw_n	dw	0
sw_f	db	0
sw_m	dw	0

    
	

    .code
	.startup        

    call	GetFileName     ; pede nome do arquivo


	lea		dx,FileName
    mov		al,0
	
	mov		ah,3dh			; abre arquivo
	int		21h
	mov		FileHandle,ax	
	jnc		Next1
	
	lea		bx,MsgErroOpenFile	; mensagem de erro
	call	printf_s
	
	.exit	1

Next1:
    call	GetFileNameDst	; pede nome do arquivo destino


	lea		dx,FileNameDst
	call	fcreate			; cria arquivo
	mov		FileHandleDst,bx
	jnc		Ciclo		; se criou, continua	




	mov		bx,FileHandle	; fecha arquivo
	call	fclose
	lea		bx, MsgErroCreateFile	; mensagem de erro
	call	printf_s
	.exit	1
    
	


Ciclo:
    mov		bx,FileHandle		; passa handle para bx
	mov		ah,3fh				; le arquivo
	mov		cx,1
	lea		dx,FileBuffer		; passa buffer para dx
	int		21h	

	mov		dl,FileBuffer	; passa buffer para dl
	

fimgetChar:
    
	jnc		Next2 	

    lea		bx,MsgErroReadFile	; mensagem de erro
	call	printf_s
	
    mov		al,1
	jmp		CloseAndFinal	; fecha e finaliza


Next2:
    
    cmp		ax,0			; se nao eh fim de arquivo
	je		Fim
	cmp dl, 126
	ja		Ciclo	; se for maior que o ~ (126), ignora e vai para o ciclo novamente



	mov     bx,[Somaindex]	; passa index para bx

	add 	[Soma+bx],dl		; soma o caractere
	inc		bx					; incrementa index
	cmp 	bx,3				
	jg 		ZeraIndex		; se for maior, zera

	mov		[Somaindex],bx		; passa index(bx) para index

	jmp		DepoisZera	



ZeraIndex:
	mov 	bx, 0			; zera index
	mov 	[Somaindex],bx

DepoisZera:
	mov     bx, 1			; passa 1 para bx
    add     NumeroBytes, bx	; incrementa numero de bytes lidos
	JNO      Over			; se nao eh overflow, continua
	add     NumeroBytes, bx	; incrementa numero de bytes lidos
	add   NumeroBytes2, 65535	; bota que leu 16bits


Over:
	mov 	bx, 1			
	add     Counter, bx			; incrementa contador
	mov 	bx, [Counter]			; passa contador para bx
	cmp 	bx, 5			
	jne     Over2				; se nao for 5, jump para over2
	mov 	bx, 1
	mov 	[Counter],bx		; zera contador

	mov 	[Temps+6], dx		; salva dx em temps	+6	
	mov	    bx, FileHandleDst	; passa handler para bx
	;mov     dl, LF
	;call Linebreak

	mov     dl, CR    ; habilitando os 2 pulava 2 linhas
	call Linebreak		; chama para pular de linha com CR

	mov 	dx, [Temps+6]	; passa temporario para dx

Over2:
	mov	    bx, FileHandleDst
	call 	setChar				; escreve caractere
	jnc 	Ciclo				; se nao eh carry, volta para inicio do ciclo

	lea		bx, MsgErroWriteFile
	call	printf_s
	mov		bx,FileHandle		; Fecha arquivo origem
	call	fclose
	mov		bx,FileHandleDst		; Fecha arquivo destino
	call	fclose
	.exit	1
	


Fim:
        lea		bx, MsgCRLF		; pula uma linha
	    call	printf_s

        lea     bx, MsgBytesLidos	; mensagem de bytes lidos
        call    printf_s

		mov     ax,NumeroBytes2		; passa numero de bytes lidos para ax
		cmp    ax,0
		je		Fim2
		
		lea		bx,String			; passa string para bx
		call	sprintf_w			; converte numero para string
		; printf("%s", String);

		lea		bx,String		; passa string para bx
		call	printf_s			; imprime string
	
		 lea		bx, MsgPlus	; mensagem de + para indicar que ja leu 16 bits
	    call	printf_s
Fim2:	
		mov     ax,NumeroBytes	; passa numero de bytes lidos para ax
		
		lea		bx,String
		call	sprintf_w		; converte numero para string

		; printf("%s", String);

		lea		bx,String
		call	printf_s		; imprime string

		lea		bx, MsgCRLF	; pula uma linha
	    call	printf_s

		lea		bx, MsgSoma	
	    call	printf_s		; imprime mensagem de soma

		mov     ah, 0
        mov		al,[Soma]	; passa soma para al

		call hex			; imprime resultado da primeira coluna da soma em hexdadecimal
		
	;	lea		bx,String
	;	call	sprintf_w
	;	lea		bx,String
	;	call	printf_s

		lea		bx, MsgSpace	; pula um espaco
	    call	printf_s

		mov     ah, 0
        mov		al,[Soma+1]
		
		call hex		; imprime resultado da segunda coluna da soma em hexdadecimal

		lea		bx, MsgSpace	; pula um espaco
	    call	printf_s	

		mov     ah, 0
        mov		al,[Soma+2]
		
		call hex		; imprime resultado da terceira coluna da soma em hexdadecimal

		lea		bx, MsgSpace		; pula um espaco
	    call	printf_s

		mov     ah, 0
        mov		al,[Soma+3]	
		call hex		; imprime resultado da quarta coluna da soma em hexdadecimal

	
		mov		dh,0
		mov		dl,[Soma]		
		mov     bx, FileHandleDst
		call    writeResult		; escreve resultado da primeira coluna da soma no arquivo

		mov		dh,0
		mov     dl,[Soma+1]
		mov     bx, FileHandleDst
		call    writeResult		; escreve resultado da segunda coluna da soma no arquivo

		mov		dh,0
		mov     dl,[Soma+2]
		mov     bx, FileHandleDst
		call    writeResult		; escreve resultado da terceira coluna da soma no arquivo
	
		mov		dh,0
		mov     dl,[Soma+3]
		mov     bx, FileHandleDst
		call    writeResult		; escreve resultado da quarta coluna da soma no arquivo



      


CloseAndFinal:				; fecha arquivos e finaliza
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


printf_s	proc	near			; imprime string funcao do professor
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

sprintf_w	proc	near		; converte numero para string funcao do professor

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

GetFileNameDst	proc	near		; cria o nome do arquivo de destino com .res no final
	;printf("Nome do arquivo destino: ");
	lea  si, FileName
	lea  di, FileNameDst

Lx:
    mov  al,[si]          
    mov  [di],al           
    inc  si              
    inc  di
    cmp byte ptr [di],0   ; se o caracter for nulo, sai do loop
    jne Lx                

	mov  [di],'.'		; adiciona o .res no final
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

gets	proc	near		; le uma string  funcao do professor
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


fopen	proc	near	; abre um arquivo
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
fcreate	proc	near		; cria um arquivo
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
fclose	proc	near	; fecha um arquivo
	mov		ah,3eh
	int		21h
	ret
fclose	endp


;--------------------------------------------------------------------
setChar	proc	near	; escreve um caracter no arquivo, se for de um digito, imprime um 0 antes
	mov	ah,0
	mov al, dl
	mov cx, 0
	mov dx, 0

	cmp al, 17		; se for um caracter de unm digito, imprime um 0 antes
	jnl label2

	mov [Temps+8],ax


	mov dl, 30h

	mov  	bx, FileHandleDst
	mov		ah,40h
	mov		cx,1
	mov     dh, 0
	mov		FileBuffer,dl
	lea		dx,FileBuffer
	int		21h


	mov cx, 0
	mov dx, 0
	mov ax, [Temps+8]

label2:
	cmp ax, 0		
	je print2

	mov bx, 16		; divide por 16 para obter o digito em hexadecimal
	div bx
	push dx
	inc cx 

	mov dx, 0
	jmp label2

print2:
	cmp cx, 0
	je exit2

	pop dx

	cmp dx, 9		; se for um numero de 1 a 9
	jle continue2

	add dx, 7		; se for um numero de 10 a 16

continue2:
	add dx, 48		; converte para ASCII
	mov [Temps], cx
	mov [Temps+2], bx	; salva registradores em Temps
	



	
	mov  	bx, FileHandleDst
	mov		ah,40h		; escreve no arquivo
	mov		cx,1
	mov     dh, 0
	mov		FileBuffer,dl
	lea		dx,FileBuffer
	int		21h	


	mov bx, [Temps+2]	; devolve registradores 
	mov cx, [Temps]
	dec cx				; decrementa contador
	jmp print2
exit2:
	ret
setChar	endp	

	
 hex proc near

	cmp ax,17			; se for um caracter de um digito, imprime um 0 antes
	jnl divide

	mov [Temps+7],ax

	mov dx, 30h
	mov ah,02h
	int 21h

	mov ax, [Temps+7]

divide:

	


  
;initialize count
    mov cx, 0
	mov dx, 0
 label1:
;if  ax is zero
    cmp ax, 0
	je print1
	

  

	mov bx, 16			; divide por 16 para obter o digito em hexadecimal
  
    div bx
  
    push dx			; bota resultado na pilha
  
    inc cx			; incrementa contador
  
    xor dx, dx		; zera dx
    jmp label1
print1:

    cmp cx,0 		; se o contador for zero
	je exit
  

    pop dx			; retira resultado da pilha
  

	cmp dx, 9 			; se for um numero de 1 a 9
	jle continue
  

    add dx, 7		; se for um numero de 10 a 16
  
continue:
  
    add dx,48			; converte para ASCII
  


    mov ah,02h		; imprime				
	int 21h				
	


  
    dec cx		; decrementa contador
    jmp print1
 exit : 
 ret
hex endp


Linebreak	proc	near		; imprime uma linha no arquivo
	mov		ah,40h
	mov		cx,1
	mov		FileBuffer,dl
	lea		dx,FileBuffer
	int		21h
	ret
Linebreak	endp

writeResult	proc	near

mov	ah,0
	mov al, dl
	mov cx, 0
	mov dx, 0


label3:
	
	cmp ax, 0		
	je print3

	mov bx, 16		; divide por 16 para obter o digito em hexadecimal
	div bx
	push dx		; bota resultado na pilha
	inc cx 		; incrementa contador

	mov dx, 0	; zera dx
	jmp label3

print3:
	cmp cx, 0	; se o contador for zero
	je exit3

	pop dx		; retira resultado da pilha

	cmp dx, 9		; se for um numero de 1 a 9
	jle continue3

	add dx, 7		; se for um numero de 10 a 16

continue3:
	add dx, 48		; converte para ASCII
	mov [Temps], cx		; retorna registradores
	mov [Temps+2], bx
	mov [Temps+3],dx



; verifica se tem que ter um cr no final
	mov 	bx, 1
	add     Counter, bx
	mov 	bx, [Counter]
	cmp 	bx, 5
	jne     proximasoma
	mov 	bx, 1
	mov 	[Counter],bx

	
	mov	    bx, FileHandleDst
	;mov     dl, LF
	;call Linebreak
	mov     dh, 0
	mov     dl, CR    ; habilitando os 2 pulava 2 linhas
	call Linebreak			


proximasoma:
	
; print  0 antes do caracter do resultado da soma

	mov dl, 30h
	mov  	bx, FileHandleDst
	mov		ah,40h
	mov		cx,1
	mov     dh, 0
	mov		FileBuffer,dl
	lea		dx,FileBuffer
	int		21h


; verifica se tem que ter um cr no final
	
	cmp 	bx, 5
	jne     proximasoma2
	mov 	bx, 1
	mov 	[Counter],bx

	
	mov	    bx, FileHandleDst
	;mov     dl, LF
	;call Linebreak
	mov     dh, 0
	mov     dl, CR    ; habilitando os 2 pulava 2 linhas
	call Linebreak			


proximasoma2:
	
	mov  dx, [Temps+3]
	; print um caracter do resultado da soma
	mov  	bx, FileHandleDst
	mov		ah,40h
	mov		cx,1
	mov     dh, 0
	mov		FileBuffer,dl
	lea		dx,FileBuffer
	int		21h

	mov bx, [Temps+2]
	mov cx, [Temps]			; retorna registradores
	dec cx
	jmp print3
exit3:
	ret
writeResult	endp	
;--------------------------------------------------------------------
		end		; fim do programa			07/05/2022
;--------------------------------------------------------------------


	

