/*Rupanshoo Saxena 2019096*/
bits 16     ; 16 bit mode
org 0x7c00  ;when BIOS finds a bootable sector, it loads it into memory at this address

bootMain:
	mov ax, 0x2401   ;set-up
	int 0x15
	mov ax, 0x3
	int 0x10  ;to set text mode
	cli                    ;clear/disable interrupts
	lgdt [gdt_pointer]
	mov eax, cr0   ;enabling 32-bit instructions by entering protected mode
	or eax,0x1     ;set protected mode bit to 1
	mov cr0, eax
	jmp CODE_SEG:boot_HelloWorld

;global descriptor table
gdt_start:
	dq 0x0
gdt_code:
	dw 0xFFFF
	dw 0x0
	db 0x0
	db 10011010b
	db 11001111b
	db 0x0
gdt_data:
	dw 0xFFFF
	dw 0x0
	db 0x0
	db 10010010b
	db 11001111b
	db 0x0
gdt_end:
gdt_pointer:  ;gdt pointer structure to load the table 
	dw gdt_end - gdt_start
	dd gdt_start

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

bits 32                ;switching to 32 bit mode
boot_HelloWorld:
	mov ax, DATA_SEG   ;setup
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	mov ss, ax
	mov esi,output     
	mov ebx,0xb8000    ;starting address of ebx

.loop_HW:
	lodsb       ;load single byte in acucumulator(al)
	or al,al    ;check if al is empty or not
	jz boot_CR0    ; if al=0 then go to halt
	or eax,0x0100  
	mov word [ebx], ax   ;ax is 32 bit al --> ax contents moved to word 
	add ebx,2            ; incrementing by 2 - for memory location and storing ax's contents
	jmp .loop_HW

boot_CR0:
    mov edx, cr0
    mov ecx, 32          
    mov ebx, 000B8100h   ;starting address where CR0 will start getting stored

.loop_CR0:
    mov eax, 00000130h  
    shl edx, 1           
    adc eax, 0           
    mov [ebx], ax
    add ebx, 2
    dec ecx
    jnz .loop_CR0

halt_CR0:
    cli     ;clear interrupts/ disable interrupts
    hlt
    jmp halt_complete

halt_complete:
	cli  ;clearing all interrupts
	hlt  ;hault
output: db "Hello world!",0   ;message to be printed

times 510 - ($-$$) db 0   ;to ensure that 0x55 and 0xAA (no.s which are markers for BIOS to help identify bootable devices from other devices) get stored in 511 & 512 bytes in our boot sector
dw 0xaa55    ; dw- data write