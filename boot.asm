 [org 0x7c00]; add 0x7C00 to label addresses
 [bits 16]      ; tell the assembler to use 16 bit code
 
   mov ax, 0  ; set up segments
   mov ds, ax
   mov es, ax
   mov ss, ax     ; setup stack
   mov sp, 0x7C00 ; stack grows downwards from 0x7C00
   mov si, Welcome
   call print_string
 mainloop:
   mov si, prompt
   call print_string
   mov di, buffer
   call get_string
   mov si, buffer
   cmp byte [si], 0  ; blank line?
   je mainloop       ; if yes, ignore it and doesn't do nothing
   mov si, buffer
   mov di, cmd_hi  ;
   call strcmp
   jc .msg_helloworld
   mov si, buffer
   mov di, cmd_help  ;
   call strcmp
   jc .help
   mov si, buffer
   mov di, cmd_star_wars  
   call strcmp
   jc .star_wars
   mov si, buffer
   mov di, cmd_twitch
   call strcmp
   jc .twitch
   mov si, buffer
   mov di, cmd_youtube 
   call strcmp
   jc .yt
   mov si,badcommand
   call print_string 
   jmp mainloop  
 
 .msg_helloworld:
   mov si, msg_helloworld
   call print_string
 
   jmp mainloop
 
 .help:
   mov si, msg_help
   call print_string
 
   jmp mainloop
 .star_wars:
   mov si, star_wars
   call print_string
 
   jmp mainloop
 .twitch:
   mov si, t
   call print_string
   jmp mainloop
 .yt:
   mov si, yt
   call print_string
   jmp mainloop
 
 msg_helloworld db 'all rights to cocco and Dino.' , 0x0D, 0x0A, 0
 Welcome db 'Welcome to DynOS,asm only ', 0x0D, 0x0A, 0
 badcommand db 'unknown', 0x0D, 0x0A, 0
 prompt db '>>', 0
 cmd_hi db 'cpyright', 0
 cmd_help db 'help', 0
 cmd_star_wars db 'star_wars',0
 cmd_youtube db 'yt',0
 cmd_twitch db 'twitch',0
 t db 'cocco1960' , 0x0D , 0x0A , 0
 yt db 'cocco 1960', 0x0D , 0x0A , 0
 info db 'Kernel: 00001' , 0x0D , 0x0A , 0
 star_wars db 'Check BF3 FRD', 0x0D , 0x0A , 0
 msg_help db 'cpyright, help,star_wars,yt,twitch,', 0x0D, 0x0A, 0
 buffer times 64 db 0
 
 ; =====
 ; calls 
 ; =====
 
 print_string:
   lodsb        ; grab a byte from SI
 
   or al, al  ; logical or AL by itself
   jz .done   ; if the result is zero, get out
 
   mov ah, 0x0E
   int 0x10      ; otherwise, print out the character!
 
   jmp print_string
 
 .done:
   ret
 
 get_string:
   xor cl, cl
 
 .loop:
   mov ah, 0
   int 0x16   ; wait for keypress
 
   cmp al, 0x08    ; backspace pressed?
   je .backspace   ; yes, handle it
 
   cmp al, 0x0D  ; enter pressed?
   je .done      ; yes, we're done
 
   cmp cl, 0x3F  ; 63 chars inputted?
   je .loop      ; yes, only let in backspace and enter
 
   mov ah, 0x0E
   int 0x10      ; print out character
 
   stosb  ; put character in buffer
   inc cl
   jmp .loop
 
 .backspace:
   cmp cl, 0	; beginning of string?
   je .loop	; yes, ignore the key
 
   dec di
   mov byte [di], 0	; delete character
   dec cl		; decrement counter as well
 
   mov ah, 0x0E
   mov al, 0x08
   int 10h		; backspace on the screen
 
   mov al, ' '
   int 10h		; blank character out
 
   mov al, 0x08
   int 10h		; backspace again
 
   jmp .loop	; go to the main loop
 
 .done:
   mov al, 0	; null terminator
   stosb
 
   mov ah, 0x0E
   mov al, 0x0D
   int 0x10
   mov al, 0x0A
   int 0x10		; newline
 
   ret
 
 strcmp:
 .loop:
   mov al, [si]   ; grab a byte from SI
   mov bl, [di]   ; grab a byte from DI
   cmp al, bl     ; are they equal?
   jne .notequal  ; nope, we're done.
 
   cmp al, 0  ; are both bytes (they were equal before) null?
   je .done   ; yes, we're done.
 
   inc di     ; increment DI
   inc si     ; increment SI
   jmp .loop  ; loop!
 
 .notequal:
   clc  ; not equal, clear the carry flag
   ret
 
 .done: 	
   stc  ; equal, set the carry flag
   ret
 
   times 510-($-$$) db 0
   dw 0xaa55 ; some BIOSes require this signature
