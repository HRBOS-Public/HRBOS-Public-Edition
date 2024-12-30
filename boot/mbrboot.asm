; MBR引导代码: 寻找活动分区并执行PBR | MBR Boot Code: Find Active Partition and Execute PBR
[BITS 16]       ; 16位实模式 | 16-bit Real Mode
[ORG 0x7C00]    ; 代码起始地址 | Code Start Address

start:
    cli         ; 关闭中断 | Disable Interrupts

    ; 清除寄存器 | Clear Registers
    xor ax, ax  ; 清零AX寄存器 | Zero out AX Register
    xor bx, bx  ; 清零BX寄存器 | Zero out BX Register
    xor cx, cx  ; 清零CX寄存器 | Zero out CX Register
    xor dx, dx  ; 清零DX寄存器 | Zero out DX Register
    xor si, si  ; 清零SI寄存器 | Zero out SI Register
    xor di, di  ; 清零DI寄存器 | Zero out DI Register

    ; 设置段寄存器 | Set Segment Registers
    mov ds, ax  ; 数据段设为0 | Set Data Segment to 0
    mov es, ax  ; 附加段设为0 | Set Extra Segment to 0
    mov ss, ax  ; 堆栈段设为0 | Set Stack Segment to 0
    mov sp, 0x7C00  ; 设置栈顶指针 | Set Stack Pointer

    ; 初始化显示 | Initialize Display
    mov ah, 0x00    ; 设置视频模式 | Set Video Mode
    mov al, 0x03    ; 文本模式 80x25 | Text Mode 80x25
    int 0x10        ; 调用BIOS中断 | Call BIOS Interrupt

    ; 清屏 | Clear Screen
    mov ah, 0x06    ; 上卷窗口 | Scroll Window Up
    mov al, 0x00    ; 整个窗口 | Entire Window
    mov bh, 0x07    ; 白底黑字 | White on Black
    mov cx, 0x00    ; 左上角(0,0) | Top-Left Corner (0,0)
    mov dx, 0x184F  ; 右下角(24,79) | Bottom-Right Corner (24,79)
    int 0x10        ; 调用BIOS中断 | Call BIOS Interrupt

    ; 设置光标位置 | Set Cursor Position
    mov ah, 0x02    ; 设置光标位置功能 | Set Cursor Position Function
    mov bh, 0x00    ; 页号 | Page Number
    mov dh, 0x00    ; 第0行 | Row 0
    mov dl, 0x00    ; 第0列 | Column 0
    int 0x10        ; 调用BIOS中断 | Call BIOS Interrupt

    sti             ; 开启中断 | Enable Interrupts

    ; 寻找活动分区 | Find Active Partition
    mov cx, 4       ; 最多搜索4个分区 | Search up to 4 partitions
    mov bx, 0x7DBE  ; 分区表起始地址 | Partition Table Start Address

find_active_partition:
    mov al, [bx]    ; 读取分区状态 | Read Partition Status
    cmp al, 0x80    ; 检查是否为活动分区 | Check if Active Partition
    je load_pbr     ; 找到活动分区则加载PBR | Load PBR if Active Partition Found

    add bx, 16      ; 移动到下一个分区表项 | Move to Next Partition Entry
    loop find_active_partition  ; 循环搜索 | Loop Search

    ; 没找到活动分区，显示错误信息 | No Active Partition Found, Show Error Message
    mov si, no_active_partition  ; 设置错误消息 | Set Error Message
    call print_string            ; 打印错误消息 | Print Error Message
    jmp error                    ; 跳转到错误处理 | Jump to Error Handling

load_pbr:
    xor ax, ax      ; 清零AX寄存器 | Zero out AX Register
    xor cx, cx      ; 清零CX寄存器 | Zero out CX Register
    xor dx, dx      ; 清零DX寄存器 | Zero out DX Register

    mov ax, [bx + 8]    ; 获取分区起始扇区低16位 | Get Partition Start Sector Low 16 bits
    mov cx, [bx + 10]   ; 获取分区起始扇区高16位 | Get Partition Start Sector High 16 bits

    mov dl, 0x80    ; 驱动器号（第一个硬盘） | Drive Number (First Hard Disk)
    mov dh, 0       ; 磁头号 | Head Number
    mov ch, 0       ; 柱面号 | Cylinder Number
    mov cl, 1       ; 扇区号 | Sector Number

    mov bx, 0x7E00  ; 目标缓冲区地址 | Target Buffer Address
    mov ah, 0x02    ; 读取扇区功能 | Read Sector Function
    mov al, 1       ; 读取1个扇区 | Read 1 Sector
    int 0x13        ; 调用BIOS中断 | Call BIOS Interrupt

    jc error        ; 如果读取失败则跳转到错误处理 | Jump to Error Handling if Read Failed

    jmp 0:0x7E00    ; 跳转到PBR | Jump to PBR

; 打印字符串函数 | Print String Function
print_string:
    mov ah, 0x0E    ; BIOS teletype输出 | BIOS Teletype Output
.repeat:
    lodsb           ; 加载 DS:SI 到 AL | Load DS:SI to AL
    or al, al       ; 检查是否为 0 | Check if Zero
    jz .done        ; 如果是 0 则结束 | If Zero, End
    int 0x10        ; 显示字符 | Display Character
    jmp .repeat     ; 继续循环 | Continue Loop
.done:
    ret             ; 返回 | Return

error:
    cli             ; 关闭中断 | Disable Interrupts
    hlt             ; 停止 | Halt

; 数据区 | Data Section
no_active_partition db 'No active partition found', 0  ; 未找到活动分区消息 | No Active Partition Message

; 填充并添加启动签名 | Padding and Boot Signature
times 510 - ($ - $$) db 0   ; 填充到510字节 | Pad to 510 bytes
dw 0xAA55                   ; 添加启动签名 | Add Boot Signature
