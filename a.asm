.686
.model flat, stdcall
option casemap :none

include \masm32\include\windows.inc
include \masm32\include\masm32.inc
include \masm32\include\kernel32.inc
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\masm32.lib

; para usar macro do PRINTF *** APAGAR DEPOIS ***
include \masm32\include\msvcrt.inc
includelib \masm32\lib\msvcrt.lib
include \masm32\macros\macros.asm

.data
    newLine 				db 0Ah
    messageArquivoEntrada 	db "Qual o nome do arquivo principal?(max 15 caracteres): ", 0h
    messageArquivoSaida 	db "Qual o nome do arquivo de saida?(max 16 caracteres): ", 0h
    messageXCoordenate 		db "Digite a coordenada X inicial para a sensura: ", 0h
    messageYCoordenate 		db "Digite a coordenada Y inicial para a sensura: ", 0h
    messageStripeWidth 		db "Digite a largura da tarja: ", 0h
    messageStripeHeight 	db "Digite a altura da tarja: ", 0h
    
    xCoordenate 			dd 0 ; coordenada X para inicio da sensura
    yCoordenate 			dd 0 ; coordenada Y para inicio da sensura
    stripeWidth             dd 0 ; largura da sensura
    stripeHeight            dd 0 ; altura da sengura

    imgName 			    db 17 dup(0) ; nome da imagem no diretorio
    newImgName 			    db 18 dup(0) ; nome da imagem a ser gerada
    
    fileBuffer 			    dd 6480  dup(0)

    tamanhoAux 				dd 0
    firstHeaderSize         dd 18
    imageWidth              dd 4
    secondHeaderSize        dd 32 

    pixelSize 				dd 3
    pixelArray 				db 3 dup(0)
	
    imgEntradaHandle 		dd 0 ; handle do arquivo original
    imgSaidaHandle		    dd 0 ; handle do arquivo novo
    
    inputHandle 			dd 0
    outputHandle 			dd 0
    consoleCount 			dd 0
    
    inputString 			db 12 dup(0)
    
    msg 					db "valor digitado eh: ", 0h  
    imageWidthValuemsg		db "A largura da imagem eh: ", 0h  
	
.code
start:
    ;------------------------------------- pegando handles de IO
    invoke GetStdHandle, STD_OUTPUT_HANDLE
    mov outputHandle, eax
    invoke GetStdHandle, STD_INPUT_HANDLE
    mov inputHandle, eax 
    ;-------------------------------------

    ;------------------------------------- Pegando coordenadas
    invoke WriteConsole, outputHandle, addr messageXCoordenate, sizeof messageXCoordenate, addr consoleCount, NULL
    invoke ReadConsole, inputHandle, addr inputString, sizeof inputString, addr consoleCount, NULL
    invoke WriteConsole, outputHandle, addr newLine, sizeof newLine, addr consoleCount, NULL
    mov esi, offset inputString
    nextLoopCoordenateX:
        mov al, [esi]
        inc esi
        cmp al, 48
        jl endLoopCoordenateX
        cmp al, 58
        jl nextLoopCoordenateX
    endLoopCoordenateX:
        dec esi
        xor al, al
        mov [esi], al
   
    invoke atodw, addr inputString
    mov xCoordenate, eax
    invoke dwtoa, xCoordenate, addr inputString
    invoke StrLen, addr inputString
    mov tamanhoAux, eax
    
    invoke WriteConsole, outputHandle, addr msg, sizeof msg, addr consoleCount, NULL
    invoke WriteConsole, outputHandle, addr inputString, tamanhoAux, addr consoleCount, NULL
    invoke WriteConsole, outputHandle, addr newLine, sizeof newLine, addr consoleCount, NULL
	
    invoke WriteConsole, outputHandle, addr messageYCoordenate, sizeof messageYCoordenate, addr consoleCount, NULL
    invoke ReadConsole, inputHandle, addr inputString, sizeof inputString, addr consoleCount, NULL
    invoke WriteConsole, outputHandle, addr newLine, sizeof newLine, addr consoleCount, NULL
    mov esi, offset inputString
    nextLoopCoordenateY:
        mov al, [esi]
        inc esi
        cmp al, 48
        jl endLoopCoordenateY
        cmp al, 58
        jl nextLoopCoordenateY
    endLoopCoordenateY:
        dec esi
        xor al, al
        mov [esi], al

    invoke atodw, addr inputString
    mov yCoordenate, eax
    invoke dwtoa, yCoordenate, addr inputString
    invoke StrLen, addr inputString
    mov tamanhoAux, eax
    
    invoke WriteConsole, outputHandle, addr msg, sizeof msg, addr consoleCount, NULL
    invoke WriteConsole, outputHandle, addr inputString, tamanhoAux, addr consoleCount, NULL
    invoke WriteConsole, outputHandle, addr newLine, sizeof newLine, addr consoleCount, NULL


    ; altura e largura
    invoke WriteConsole, outputHandle, addr messageStripeWidth, sizeof messageStripeWidth, addr consoleCount, NULL
    invoke ReadConsole, inputHandle, addr inputString, sizeof inputString, addr consoleCount, NULL
    invoke WriteConsole, outputHandle, addr newLine, sizeof newLine, addr consoleCount, NULL
    mov esi, offset inputString
    nextLoopStripeWidth:
        mov al, [esi]
        inc esi
        cmp al, 48
        jl endLoopStripeWidth
        cmp al, 58
        jl nextLoopStripeWidth
    endLoopStripeWidth:
        dec esi
        xor al, al
        mov [esi], al
   
    invoke atodw, addr inputString
    mov stripeWidth, eax
    invoke dwtoa, stripeWidth, addr inputString
    invoke StrLen, addr inputString
    mov tamanhoAux, eax
    
    invoke WriteConsole, outputHandle, addr msg, sizeof msg, addr consoleCount, NULL
    invoke WriteConsole, outputHandle, addr inputString, tamanhoAux, addr consoleCount, NULL
    invoke WriteConsole, outputHandle, addr newLine, sizeof newLine, addr consoleCount, NULL

    invoke WriteConsole, outputHandle, addr messageStripeHeight, sizeof messageStripeHeight, addr consoleCount, NULL
    invoke ReadConsole, inputHandle, addr inputString, sizeof inputString, addr consoleCount, NULL
    invoke WriteConsole, outputHandle, addr newLine, sizeof newLine, addr consoleCount, NULL
    mov esi, offset inputString
    nextLoopStripeHeight:
        mov al, [esi]
        inc esi
        cmp al, 48
        jl endLoopStripeHeight
        cmp al, 58
        jl nextLoopStripeHeight
    endLoopStripeHeight:
        dec esi
        xor al, al
        mov [esi], al
   
    invoke atodw, addr inputString
    mov stripeHeight, eax
    invoke dwtoa, stripeHeight, addr inputString
    invoke StrLen, addr inputString
    mov tamanhoAux, eax
    
    invoke WriteConsole, outputHandle, addr msg, sizeof msg, addr consoleCount, NULL
    invoke WriteConsole, outputHandle, addr inputString, tamanhoAux, addr consoleCount, NULL
    invoke WriteConsole, outputHandle, addr newLine, sizeof newLine, addr consoleCount, NULL
    ;-------------------------------------

    ; 		NOME DO ARQUIVO PRINCIPAL
	invoke WriteConsole, outputHandle, addr newLine, sizeof newLine, addr consoleCount, NULL 
    invoke WriteConsole, outputHandle, addr messageArquivoEntrada, sizeof messageArquivoEntrada, addr consoleCount, NULL
    invoke ReadConsole, inputHandle, addr imgName, sizeof imgName, addr consoleCount, NULL
	
	mov esi, offset imgName ; Armazenar apontador da string em esi
	proximo3:
	mov al, [esi] ; Mover caractere atual para al
	inc esi ; Apontar para o proximo caractere
	cmp al, 13 ; Verificar se eh o caractere ASCII CR - FINALIZAR
	jne proximo3
	dec esi ; Apontar para caractere anterior
	xor al, al ; ASCII 0
	mov [esi], al ; Inserir ASCII 0 no lugar do ASCII CR
	
    invoke WriteConsole, outputHandle, addr newLine, sizeof newLine, addr consoleCount, NULL
    invoke WriteConsole, outputHandle, addr msg, sizeof msg, addr consoleCount, NULL
    invoke WriteConsole, outputHandle, addr imgName, 11, addr consoleCount, NULL
    invoke WriteConsole, outputHandle, addr newLine, sizeof newLine, addr consoleCount, NULL 

    ; 		NOME DO ARQUIVO DE SAIDA
	invoke WriteConsole, outputHandle, addr newLine, sizeof newLine, addr consoleCount, NULL 
    invoke WriteConsole, outputHandle, addr messageArquivoSaida, sizeof messageArquivoSaida, addr consoleCount, NULL
    invoke ReadConsole, inputHandle, addr newImgName, sizeof newImgName, addr consoleCount, NULL
	
	mov esi, offset newImgName ; Armazenar apontador da string em esi
	proximo4:
	mov al, [esi] ; Mover caractere atual para al
	inc esi ; Apontar para o proximo caractere
	cmp al, 13 ; Verificar se eh o caractere ASCII CR - FINALIZAR
	jne proximo4
	dec esi ; Apontar para caractere anterior
	xor al, al ; ASCII 0
	mov [esi], al ; Inserir ASCII 0 no lugar do ASCII CR
	
    invoke WriteConsole, outputHandle, addr msg, sizeof msg, addr consoleCount, NULL
    invoke WriteConsole, outputHandle, addr newImgName, 12, addr consoleCount, NULL
    invoke WriteConsole, outputHandle, addr newLine, sizeof newLine, addr consoleCount, NULL 
    ;-------------------------------------
    
    ;------------------------------------ abrindo arquivo original
    invoke CreateFile, addr imgName, GENERIC_READ, 0, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL
    mov imgEntradaHandle, eax
    ;------------------------------------- 

    ;------------------------------------- criando novo arquivo
    invoke CreateFile, addr newImgName, GENERIC_WRITE, 0, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL
    mov imgSaidaHandle, eax
    ;------------------------------------- 

	;------------------------------------- lendo o arquivo original e gravando header no novo arquivo
    invoke ReadFile, imgEntradaHandle, addr fileBuffer, firstHeaderSize, addr consoleCount, NULL
    invoke WriteFile, imgSaidaHandle, addr fileBuffer, firstHeaderSize, addr consoleCount, NULL

    invoke ReadFile, imgEntradaHandle, addr imageWidth, 4, addr consoleCount, NULL
    invoke WriteFile, imgSaidaHandle, addr imageWidth, 4, addr consoleCount, NULL

    invoke dwtoa, imageWidth, addr inputString  
    invoke StrLen, addr inputString  
    mov tamanhoAux, eax
    
    invoke WriteConsole, outputHandle, addr imageWidthValuemsg, sizeof imageWidthValuemsg, addr consoleCount, NULL
    invoke WriteConsole, outputHandle, addr inputString  , tamanhoAux, addr consoleCount, NULL
    invoke WriteConsole, outputHandle, addr newLine, sizeof newLine, addr consoleCount, NULL

    invoke ReadFile, imgEntradaHandle, addr fileBuffer, secondHeaderSize, addr consoleCount, NULL
    invoke WriteFile, imgSaidaHandle, addr fileBuffer, secondHeaderSize, addr consoleCount, NULL
	;-------------------------------------

	;------------------------------------- leitura do restante dos bytes da imagem original
    mov eax, imageWidth ; pegando o valor maximo de bytes da linha e guardando em imageWidth
    mov ebx, pixelSize
    mul ebx
    mov imageWidth, eax

    ler_linha: ; inicio loop para ler e escrever as linhas da imagem
        invoke ReadFile, imgEntradaHandle, addr fileBuffer, imageWidth, addr consoleCount, NULL

        cmp consoleCount, 0
        jz fim_leitura

        invoke WriteFile, imgSaidaHandle, addr fileBuffer, imageWidth, addr consoleCount, NULL

        jnz ler_linha ; Continue o loop se ecx não for zero
    fim_leitura:

	;-------------------------------------
	
    ;------------------------------------ fechando arquivos
    invoke CloseHandle, imgEntradaHandle
    invoke CloseHandle, imgSaidaHandle
    ;------------------------------------

    invoke ExitProcess, 0
end start
