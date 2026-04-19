[org 0x1000]
bits 16

start15:
    mov ax, 0x1000
    mov ds, ax
    mov es, ax

    mov ah, 0x00
    mov dl, 0x80
    int 0x13

    mov ax, 0x2000
    mov es, ax
    xor bx, bx
    mov ah, 0x02
    mov al, 14
    mov ch, 0
    mov cl, 19
    mov dh, 0
    mov dl, 0x80
    int 0x13
    jc error15

    mov di, bx
    mov cx, 224
    mov si, filename

search_loop:
    push di
    push cx
    mov cx, 11
    repe cmpsb
    pop cx
    pop di
    je found
    add di, 32
    loop search_loop

    mov si, not_found_msg
    jmp error15

found:
    mov ax, [di + 26]
    mov [cluster], ax

    mov ax, 0x3000
    mov es, ax
    xor bx, bx
    mov ah, 0x02
    mov al, 9
    mov ch, 0
    mov cl, 1
    mov dh, 0
    mov dl, 0x80
    int 0x13
    jc error15

    mov ax, 0x4000
    mov es, ax
    xor bx, bx

load_loop:
    mov ax, [cluster]
    sub ax, 2
    mov cx, 1
    mul cx
    add ax, 33
    mov [sector], ax

    mov ah, 0x02
    mov al, 1
    mov ch, 0
    mov cl, [sector]
    mov dh, 0
    mov dl, 0x80
    int 0x13
    jc error15

    mov ax, [cluster]
    mov cx, ax
    shr ax, 1
    add ax, cx
    mov si, ax
    mov ax, [0x3000 + si]
    test cx, 1
    jz even
    shr ax, 4
even:
    and ax, 0x0FFF
    mov [cluster], ax

    add bx, 512
    cmp bx, 65536 - 512
    jb .same_seg
    mov ax, es
    add ax, 0x1000
    mov es, ax
    xor bx, bx
.same_seg:

    cmp word [cluster], 0xFF8
    jb load_loop

    jmp 0x4000:0x0000

error15:
    mov si, err_msg15
    call print15
    cli
    hlt

print15:
    lodsb
    or al, al
    jz .done
    mov ah, 0x0e
    int 0x10
    jmp print15
.done:
    ret

filename      db 'PAWBOOT SYS'
cluster       dw 0
sector        dw 0
not_found_msg db 'PAWBOOT.SYS not found', 0x0d, 0x0a, 0
err_msg15     db 'Stage1.5: Disk error', 0x0d, 0x0a, 0

times 4096-($-$$) db 0
