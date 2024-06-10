; multi-segment executable file template.

;scroll
SCROLL    MACRO     N,ULR,ULC,LRR,LRC,ATT    ;宏定义
    
          push ax
          push bx
          push cx
          push dx
          MOV       AH,6            ;清屏或上卷
          MOV       AL,N            ;N=上卷行数；N=0时，整个窗口空白
          MOV       CH,ULR          ;左上角行号
          MOV       CL,ULC          ;左上角列号
          MOV       DH,LRR          ;右下角行号
          MOV       DL,LRC          ;右下角列号
          MOV       BH,ATT          ;卷入行属性
          INT       10H 
          
          pop dx
          pop cx
          pop bx
          pop ax
ENDM

;curse 是置光标的作用
CURSE     MACRO     CURY,CURX
          
          push AX
          push bx
          push dx    
          MOV       AH,2                ;置光标位置
          MOV       DH,CURY             ;行号                ;Y 是行号，X 是列号
          MOV       DL,CURX             ;列号
          MOV       BH,0                ;当前页
          INT       10H
          
          pop dx
          pop bx
          pop ax
          ENDM

GAP macro 
    SCROLL 1,8,20,18,50,2FH        ;开内窗口，绿底白字
    CURSE 18,20 
    
    endm
;实现找到是否有需要的单词单词的定位

PRINT macro  printcontent ;专注于输出，接受输出区间的开始，以及要输出的长度（充分考虑整体的换行的要求）
    
    local next_char,printend
    push cx
    push si
    push dx
    push bx
    push ax
    
    ;获取单词的开头
    lea si,printcontent
    mov cx,1
    
    mov bl,31
next_char:
    
    mov al,[si]
    cmp al,'$'
    jz printend
    
    mov dl,[si]
    mov ah,02h
    int 21h
    
    inc cx
    inc si
    mov ax,cx
    div bl
    cmp ah,0
    jnz next_char
    gap  
    
    jmp next_char
printend:
    gap
   
    pop ax
    pop bx
    pop dx
    pop si
    pop cx 
    
    endm

data segment
            
    ; add your data here!
    F1 db "Y:\emu8086\emu8086\vdrive\D\file2.txt",0
    ;暂时的输入都在temp存储
    temp db 100 dup($) 
    wordstart dw 0
    wordsnum db 3
    findword db 20 dup(0)
    filecontent db 200 dup(0)
    findflag db 0
    cu@num db 0
    all@num db 0
    currentnum db 0
    printstart dw 0
    wordexpla db 100 dup(0)
    ;wordan db 20 dup(0)
    wordsy db 20 dup(0)
    wordan db 20 dup(0)
    strmatch db 10 dup(0)
    strlen dw 0
    matchstr db 50 dup(0)
    matchstrend dw 0
    str0 db "please enter the word you find$"
    look db 0
    
    
    str1 db "Please enter your choice!$"
    str2 db "1:explain 2:en 3:sy$"
    str3 db "enter the strlen$"
    str4 db "enter the matchstr$"
    pkey db "press any key...$"


stack segment
    dw   128  dup(0)
ends

code segment
    buffer db 100 dup(0)
start:
    ; set segment registers:
    mov ax, data
    mov ds, ax
    mov es, ax
    
    
    SCROLL 0 ,0, 0,24,79,02           ;清屏  (黑底绿色字)
    SCROLL 13,7,19,19,51,50H        ;开外窗口，品红底
    SCROLL 11,8,20,18,50,2FH        ;开内窗口，绿底白字
    CURSE 18,20 
    ; 创建文件
    ;lea dx, F1
    ;mov cx, 0
    ;mov ah, 3Ch
    ;int 21h
    ;jc error    ; 检验是否有问题
    

;只需存入单词即可
;用于执行单词英文解释的修改，英文解释的删除
    lea si,findword    
    mov cx,5
loopgetword:
    mov ah,01
    int 21h
    mov [si],al
    inc si
    
    loop loopgetword
    
          
    ;打开文件
    
    lea dx,F1
    mov al,02
    
    mov ah,3DH
    int 21h
    
    ;读取文件
    mov bx,ax
    mov cx,200
    lea dx,filecontent
    mov ah,3FH
    int 21h
    
    ;关闭文件?
     
    
    ;此时的信息在dx 中
    call FIND
    ; Call MAIN procedure
    
    mov al,findflag
    cmp al,1
    jnz nextfunction
    
    lea dx,str1
    mov ah,09h
    int 21h
    
    gap 
    
    lea dx,str2
    mov ah,09h
    int 21h
    
    gap
    ;输出单词的解释
    
    mov ah,01
    int 21h
    
    sub al,30h
    gap
    cmp al,1
    jnz sy
    PRINT wordexpla
sy:
    cmp al,2
    jnz an
    PRINT wordsy
an: 
    cmp al,3
    jnz maincontinue1
    PRINT wordan
    
    gap

maincontinue1:    
    ;输出匹配的字符串
    ;首先先获取strmatch和strlen
    lea dx,str3
    mov ah,09h
    int 21h
    gap
    xor bx,bx
    mov ah,01h
    int 21h
    sub al,30h
    mov bl,al
    mov strlen,bx
    gap
    
    lea dx,str4
    mov ah,09h
    int 21h
    gap
    
    mov cx,bx
    lea si,strmatch
getstrmatch:
    mov ah,01
    int 21h
    mov [si],al
    inc si
    loop getstrmatch
     
    gap
    call MATCH   
    PRINT matchstr    
    
    
    ;上面的代码已经完成了查找的部分
    
    ;接下来将进行插入与删除操作
nextfunction:
    
    ; Exit to operating system
    mov ax, 4C00h
    int 21h

error:
    mov dl, '1'
    mov ah, 02h
    int 21h
        
    lea dx, pkey
    mov ah, 9
    int 21h        ; output string at ds:dx
    
    ; wait for any key    
    mov ah, 1
    int 21h
    
    mov ax, 4C00h ; exit to operating system
    int 21h
           
FIND proc  
    
    ;作用：将dx中的内容直接输出，每一行30个字符，实现屏幕的上滑
    ;要找的单词存储在findword,文件的内容内容将存储在filecontent,现在的任务就是找到，单词的匹配的位置，假设在调用宏之前已经打开文件    
    push ax
    push bx
    push cx
    push dx
    push di
    push si    
    xor bx,bx
     
    mov cl,wordsnum 
    add cl,wordsnum
    add cl,wordsnum
    add cl,wordsnum
    mov all@num,cl
    
     ;当含有n个单词的时候，就会有4*n个@
    
    
    lea di,filecontent
    
    ;mov al,'@'
    mov cx,200  ;这个cx 十分重要!
search@:    
    
    mov al,'@'
    repne scasb ;此时的话，di已经跳过了原本的@
    ;找到@
    mov bl,cu@num
    inc bl
    mov cu@num,bl
    
    cmp bl,all@num
    jz notfind@
   
    ;push al
    ;接下来是除法操作
    mov ax,bx
    mov dl,4
    div dl    ;除法的余数在ah
    cmp ah, 1  ;说明找到单词的位置
     
    jnz search@
     push di
; 任务：判断findword 与 filecontent接下来的单词是否一样？    
    lea si, findword
loop1:    
    mov ah,[di]
    cmp ah,[si]
    jz continue1

    pop di           ;不相等才pop出去
    jmp search@
    
continue1:    
    inc si
    inc di
    
    cmp [di],'@'
    
    jnz  loop1
    
    mov findflag,1
    jmp yesfind
        
notfind@:
    ;输出notfind@
    mov dl,'N'
    mov ah,02h
    int 21h     
    
    jmp end1
    
yesfind:
    mov al,01
    mov [findflag],al
    ;由于单词存在，那么就可以进行单词的解释，近义词，反义词的输出
    pop di
    mov wordstart,di
    ;输出一个换行
    ;屏幕上移
    ;光标归位
    
    SCROLL 1,8,20,18,50,2FH        ;开内窗口，绿底白字
    CURSE 18,20 
    
    
    ;还应该找到后面的@
    mov al,'@'
    repne scasb 
    
    ;获取解释，近义词，反义词
    
    lea si,[wordexpla] 
getexpla:    
    mov al,[di] 
    cmp al,'@'
    jz getsy0 
    mov [si],al                   ;wordexpla,wordsy,wordan都分别存储了相对应的内容，并且是以$结尾
    inc si
    inc di
    jmp getexpla
    
getsy0:    
    ;inc si
    mov [si],'$'
    
    inc di
    lea si ,[wordsy]
    
getsy1:    
    mov al,[di] 
    cmp al,'@'
    jz getan0 
    mov [si],al
    inc si
    inc di
    jmp getsy1

getan0:
    ;inc si
    mov [si],'$'
    
    inc di
    lea si ,[wordan] 
    
getan1:    
    mov al,[di] 
    cmp al,'$'
    jz  getfinal
    mov [si],al
    inc si
    inc di
    jmp getan1
getfinal:
    ;inc si
    mov [si],'$'    
    
end1:

    pop si
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    
ret
    


MATCH proc
        push ax
    push bx
    push cx
    push dx
    push di
    push si    
    xor bx,bx
    ;cu@num，all@num在上面的函数的话已经计算过了，不必要重新计算
    
    
    lea di,filecontent
    
    mov cx,300  ;这个cx 十分重要!
    mov al,0
    mov cu@num,al 
    
    lea si,matchstr
    mov matchstrend,si
matchsearch@:    
    
    mov al,'@'
    mov dl,[di]
    repne scasb ;此时的话，di已经跳过了原本的@
    ;找到@                                                  ;还是要设置一个标志？如果没有匹配？但是目前的话，也可以不用考虑那么多
    mov bl,cu@num
    inc bl
    mov cu@num,bl
                                                            ;strmatch 是要匹配的字符串
                                                            ;文件中读出的内容存储在filecontent里面
                                                            ;每一次都在filecontent的单词的部分进行strmatch的匹配问题
                                                            ;由于strmatch的长度存储在strlen,所以我们一直匹配当匹配的长度等于strle                                                            ;就可以从我们的pop di进行将单词存储在matchstr中
    cmp bl,all@num
    jz matchend
   
    ;push al
    ;接下来是除法操作
    mov ax,bx
    mov dl,4
    div dl    ;除法的余数在ah
    cmp ah, 1  ;说明找到单词的位置
     
    jnz matchsearch@
     push di           ;此时的di 已经存储了单词的开头 
; 任务：判断    
     lea si,strmatch     
     push cx
     mov cx,strlen
matchloop1:
    mov al,[di]
    cmp al,[si]
    jnz matchcontinue
    
    inc si
    inc di
    loop matchloop1
    ;匹配成功？将单词存储在matchstr中  
    pop cx  ;很大的问题！
    pop di
    push di
    ;lea si,matchstr
    mov si,matchstrend
tran:
    mov al,[di]
    cmp al,'@'
    jz matchcontinue0
    mov [si],al
    inc si
    inc di
    ;mov matchstrend,si   ;这里是si,因为你要记录的是matchstr 的下一个空余的位置
    jmp tran:

matchcontinue0:
    mov [si],','
    inc si
    mov matchstrend,si
          
matchcontinue: ;无法匹配成功？或者存储单词完
    ;恢复di的值
    pop di
    jmp matchsearch@
    
matchend:
    mov di,matchstrend
    mov [di],'$'
    
    pop si
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    
    ret  
    
    end start
ends