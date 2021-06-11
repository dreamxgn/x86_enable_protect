%define CODESEG 0x7c00 ;代码段地址

         mov word bx,ds:[gdt_table+CODESEG]

         ;描述符1 代码段描述符
         mov word [bx+8],0x0 ;段长度
         mov word [bx+10],0x7c00 ;段基址
         mov word [bx+12],0x9a00 
         mov word [bx+14],0xc0 ;段颗粒度 4KB

         ;创建#3描述符，保护模式下的堆栈段描述符
         mov dword [bx+0x18],0x00007a00
         mov dword [bx+0x1c],0x00409600

         ;GDTR表长度
         mov word [cs: gdt_addr+CODESEG],31  
                                 
         lgdt [cs: gdt_addr+CODESEG] ;加载GDTR地址到寄存器
      
         cli ;禁止中断

         ;开启保护模式
         mov eax,cr0
         or eax,1
         mov cr0,eax

        ;跳转至保护模式下代码 16段选择子:32位偏移
        jmp dword 0x0008:protect_start

    bits 32
    protect_start:
         mov cx,0x10 ;加载数据段
         mov ds,cx
         call clear_console
        
        ;向显示缓冲区写入 LoadProtect 以显示到屏幕上
        mov byte ds:[0],'L'
        mov word ds:[1],0x7
        mov byte ds:[2],'o'
        mov word ds:[3],0x7
        mov byte ds:[4],'a'
        mov word ds:[5],0x7
        mov byte ds:[6],'d'
        mov word ds:[7],0x7
        mov byte ds:[8],'P'
        mov word ds:[9],0x7
        mov byte ds:[10],'r'
        mov word ds:[11],0x7
        mov byte ds:[12],'o'
        mov word ds:[13],0x7
        mov byte ds:[14],'t'
        mov word ds:[15],0x7
        mov byte ds:[16],'e'
        mov word ds:[17],0x7
        mov byte ds:[18],'c'
        mov word ds:[19],0x7
        mov byte ds:[20],'t'
        mov word ds:[21],0x7
         jmp end
end:
    jmp end
;清空输出缓冲区
clear_console:
    push eax
    push edi

    xor eax,eax
    mov al,0x0
    mov ecx,0x500
    mov edi,0xb8000
    cld
    rep stosb

    pop edi
    pop eax
    ret

gdt_addr    dw 0x0;段限长度
gdt_table  dd (gdt+CODESEG);GDT的物理地址     
gdt:
    ;描述符0 空描述符
	dd 0x0,0x0
    
    ;代码段描述符
	dd 0x0,0x0

;显示缓冲区段描述符
view_seg:
    dw 0xffff ;段限长
    dw 0x8000 ;段基址 00-15
    db 0x0b ;段基地 16-23
    db 0x92;段属性 P-1 DPL-2 S-1 TYPE-4
    db 0x40;Segment Limit-4 AVL-1 L-1 DB-1 G-1
    db 0x0 ;段基址

times 510-($-$$) db 0
db 0x55,0xaa
