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
    filecontentlen dw 0
    findflag db 0
    filestart dw 0
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
    deleteword db 20 dup(20)
    deletewordlen dw 0
    deletewordstart dw 0
    deletewordend dw 0
    deletelen0 dw 0
    deleteexplastart dw 0
    deleteexplaend dw 0
    deletelen2 dw 0
    newexpla db 50 dup(0)
    fileflag dw 0
    newwordlen dw 0
    newword db 20 dup(0)
    newwordinsertplace dw 0
    morelen dw 0
    more db 50 dup(0)
    insertexplalen dw 0
    insertexpla db 50 dup(0)
    tempstore db 100 dup(0)
    str0 db "please enter the word you find$"
    str1 db "Please enter your choice!$"
    str2 db "1:explain 2:en 3:sy$"
    str3 db "enter the strlen$"
    str4 db "enter the matchstr$"
    str5 db "enter deletewordlen$"
    str6 db "enter the deleteword$"
    str7 db "enter the newwordlen$"
    str8 db "enter the newword$"
    str9 db "enter the morelen$"
    str10 db "enter the more$"
    str11 db "enter insertexpalen$"
    str12 db "enter insertexpla$"


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
    
    ;此时的ax存储实际读入的字节
    mov filecontentlen,ax
    
    ;先关闭文件
    mov ah,3EH
    int 21h 
                                                                  ;已经关闭文件
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
    ;打开文件
    
    lea dx,F1
    mov al,02
    
    mov ah,3DH
    int 21h
    mov fileflag,ax
    jc error1
    
    
    ;读取文件
    mov bx,ax
    mov cx,200
    lea dx,filecontent
    mov ah,3FH
    int 21h                                                                                            ;记录文件标记应该在打开文件！
    jc error2
                                              ;存储文件标记
    ;接下来将进行插入与删除操作
    ;更新解释
    lea si,filecontent
    mov filestart,si
    ;获取要删除的单词与单词的长度
    lea dx,str5
    mov ah,09h
    int 21h
    gap
    xor bx,bx
    mov ah,01h
    int 21h
    sub al,30h
    mov bl,al
    mov deletewordlen,bx
    gap
    
    lea dx,str6
    mov ah,09h
    int 21h
    gap
    
    mov cx,deletewordlen
    lea si,deleteword
getdeleteword:
    mov ah,01h
    int 21h
    mov [si],al
    inc si
    loop getdeleteword
     
    ;删除单词操作                                                                      ;还应该注意wordsum要减一
    call DELETE
    
    
    mov bx,fileflag
    mov al,00h
    mov cx,0                  ;偏移量计算的话就是1                                   ;移动文件指针
    mov dx,deletewordstart
    sub dx,filestart
    
    mov ah,42h
    
    int 21h
    
    ;写文件
    ;mov cx,filecontentlen-deletewordend  ;要拿一个变量来存储最后一个字符的位置！
    ;mov dx,deletewordend
    mov bx,fileflag
    mov cx,filecontentlen
    add cx,filestart             ;filecontentlen - (deletewordend-filestart)
    sub cx,deletewordend
    
    lea dx,filecontent
    add dx,deletewordend        ;剩下的字符串的长度？
    sub dx,filestart
     
    mov ah,40h
    int 21h                       ;写文件
    jc error3
    

    ;删除完毕
    
    mov bx,filecontentlen      ;filecontentlen-(deletewordend-deletewordstart)
    add bx,deletewordstart                                                                    ;对于解释的更新操作？
    sub bx,deletewordend
    mov filecontentlen,bx
    
    ; Exit to operating system
    
    
    
    ;删除完毕，关闭文件
    mov bx,fileflag
    mov ah,3EH
    int 21h                         ;接下来将进行单词的插入
    jc error4
    
    
    mov cl,wordsnum
    sub cl,1
    mov wordsnum,cl
    
    gap
    
    ;新一轮打开文件
    
    lea dx,F1
    mov al,02
    
    mov ah,3DH
    int 21h
    
    mov fileflag,ax
    
    ;读取文件
    mov bx,ax
    mov cx,filecontentlen         ;及时只读出上面的有用的内容
    lea dx,filecontent
    mov ah,3FH
    int 21h
    
    
    lea dx,str7
    mov ah,09h
    int 21h
    
    gap
    xor bx,bx
    
    mov ah,01h
    int 21h
                                                                                         ;还是这个大问题，获取字符串的长度，要减去30h
    mov bl,al
    sub bl,30h
    mov newwordlen,bx
    
    
    gap
    lea dx,str8
    mov ah,09h
    int 21h                    ;
    
    gap 

    mov cx, bx
    lea si,newword
getnewword:
    mov ah,01h
    int 21h
    
    mov [si],al
    inc si
    
    loop getnewword
    
  ;获取解释近义词反义词等
    gap
  lea dx,str9
    mov ah,09h
    int 21h
    
    gap
    xor bx,bx
    
    mov ah,01h                                                                    ;这里也要先减去30h
    int 21h
    
    mov bl,al
    sub bl,30h
    mov morelen,bx
    
    
    gap
    lea dx,str10
    mov ah,09h
    int 21h
    
    gap

    mov cx, bx
    lea si,more
getmore:
    mov ah,01h
    int 21h
    
    mov [si],al
    inc si
    
    loop getmore
    ;获取更多的解释以及近义词反义词
      
    gap
    
    call FINDINSERT                ;通过调用该子程序，可以知道新的单词应该插入的位置
    
    ;建议手动拼接
    mov si,newwordinsertplace
    mov di,si
    add di,newwordlen
    add di,morelen
    
    mov cx,newwordlen
    add cx,morelen
    
    repe movsb
    mov di,newwordinsertplace
    lea si,newword
    mov cx,newwordlen
    
    repe movsb
    
    ;上一个di的值即可
    lea si,more
    mov cx,morelen
    
    repe movsb
    
    ;此时的filecontent包含了完整的单词表
    mov cx,filecontentlen
    add cx,newwordlen
    add cx,morelen
    mov filecontentlen,cx
    
    mov al,wordsnum
    add al,1
    mov wordsnum,al
    
    ;调整文件指针以及写入文件
    mov bx,fileflag
    mov al,00h
    mov cx,0                  ;偏移量计算的话就是1                                   ;移动文件指针
    mov dx,0
    
    mov ah,42h
    
    int 21h
    
    lea dx,filecontent
    mov cx,filecontentlen
     
    mov ah,40h
    int 21h                       ;写文件
    
    ;关闭文件
    mov bx,fileflag                                                                                ;对于解释的更新操作？
                                                                                                   ;deleteexplastart deleteexplaend
    mov ah,3EH                                                                                     ;输入的话 ABC@ 要以@结尾，同时
    int 21h                                                                                        ;在deleexplastart处插入，同时deleexplaend处
 
 
  
 ;开始进行解释的修改                                                                                                   ;一直前移，注意更新相对应的filecontentlen
 ;其实大部分的代码和删除单词的操作相似
     ;新一轮打开文件
    
    lea dx,F1
    mov al,02
    
    mov ah,3DH
    int 21h
    
    mov fileflag,ax
    
    ;读取文件
    mov bx,ax
    mov cx,filecontentlen         ;及时只读出上面的有用的内容
    lea dx,filecontent
    mov ah,3FH
    int 21h
    
    
    gap    
    
    lea dx,str5
    mov ah,09h
    int 21h
    gap
    xor bx,bx
    mov ah,01h
    int 21h
    sub al,30h
    mov bl,al
    mov deletewordlen,bx
    gap
    
    lea dx,str6
    mov ah,09h
    int 21h
    gap
    
    mov cx,deletewordlen
    lea si,deleteword
getdeleteword1:
    mov ah,01h
    int 21h
    mov [si],al
    inc si
    loop getdeleteword1
    gap
    xor bx,bx
    
    lea dx,str11
    mov ah,09h
    int 21h
    gap
    mov ah,01h
    int 21h
                                                                                         ;还是这个大问题，获取字符串的长度，要减去30h
    mov bl,al
    sub bl,30h
    mov insertexplalen,bx
    
    
    gap
    lea dx,str12
    mov ah,09h
    int 21h                    ;
    
    gap 

    mov cx, bx
    lea si,insertexpla
getinsertexpla:
    mov ah,01h
    int 21h
    
    mov [si],al
    inc si
    
    loop getinsertexpla
    
 
      
    
    call DELETE               ;通过调用该子程序，可以知道新的解释应该插入的位置

;其实还要比较长度的问题，我们这里先考虑插入的解释长度大于原来的解释    
    ;建议手动拼接
    
    ;                                           ;由于是插入，所以应该让后面的向后移动
    
    ;先将后面的部分存储到tempstore
    
    mov cx,filecontentlen
    add cx,filestart                                 ;后移操作不能使用repe movsb操作，因为我们是从后面往前面操作的
    sub cx,deleteexplaend
    mov si,deleteexplaend
    lea di,tempstore
    repe movsb
    
    
    
    mov di,deleteexplastart
    lea si,insertexpla                       ;插入新的解释
    mov cx,insertexplalen
    
    repe movsb
    
    ;从tempstore读取
    lea si,tempstore
    ;此时的di已经存储好了
    mov cx,filecontentlen
    add cx,filestart                                 ;后移操作不能使用repe movsb操作，因为我们是从后面往前面操作的
    sub cx,deleteexplaend
    
    repe movsb
    ;此时的filecontent包含了完整的单词表
    mov cx,filecontentlen
    add cx,insertexplalen
    add cx,deleteexplastart
    sub cx,deleteexplaend
    mov filecontentlen,cx
    

    
    ;调整文件指针以及写入文件
    mov bx,fileflag
    mov al,00h
    mov cx,0                  ;偏移量计算的话就是1                                   ;移动文件指针
    mov dx,0
    
    mov ah,42h
    
    int 21h
    
    lea dx,filecontent
    mov cx,filecontentlen
     
    mov ah,40h
    int 21h                       ;写文件
    
    ;关闭文件
    mov bx,fileflag                                                                                ;对于解释的更新操作？
                                                                                                   ;deleteexplastart deleteexplaend
    mov ah,3EH                                                                                     ;输入的话 ABC@ 要以@结尾，同时
    int 21h  
    
    
    mov ax, 4C00h
    int 21h

error1:
    mov dl, '1'
    mov ah, 02h
    int 21h
error2:
    mov dl, '2'
    mov ah, 02h
    int 21h

error3:
    mov dl, '3'
    mov ah, 02h
    int 21h
error4:
    mov dl, '4'
    mov ah, 02h
    int 21h
        
    ;lea dx, pkey
   ; mov ah, 9
    ;int 21h        ; output string at ds:dx
    
    ; wait for any key    
    mov ah, 1
    int 21h
nextfunction:    
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
    ;恢复di的值                                                ;栈还是一个大问题
    ;pop cx           ;这一句竟然不要
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
               
 
DELETE proc
    push ax
    push bx
    push cx
    push dx
    push di
    push si
    
    ;我已经读取文件的内容在filecontent,要删除的单词在deleteword中,那么deletewordlen记录deleteword的长度
    ;我只要一直匹配，当匹配成功的时候，还要一直读取下去
    ;同时记录好deletewordstart和deletewordend的位置    (用于删除整个单词总体）
    ;deleteexplastart 和 deleteexplaend 用来更新解释
    
    ;个人觉得好像不用创建新的文件，你拿一个区域存起来还是可以的
        
    lea di,filecontent
    
    ;mov al,'@'
    mov cx,200  ;这个cx 十分重要!
    mov bl,0
    mov cu@num,bl ;初始化
deletesearch@:    
    
    mov al,'@'
    repne scasb ;此时的话，di已经跳过了原本的@
    ;找到@
    mov bl,cu@num
    inc bl
    mov cu@num,bl
    
    cmp bl,all@num
    jz deleteend
   
    ;push al
    ;接下来是除法操作
    mov ax,bx
    mov dl,4
    div dl    ;除法的余数在ah
    cmp ah, 1  ;说明找到单词的位置
     
    jnz deletesearch@
     push di
; 任务：判断findword 与 filecontent接下来的单词是否一样？    
    lea si, deleteword
     
    mov deletewordstart,di ;先将开始的地址存起来
    
    ;普通控制循环即可
    
deleteloop1:    
    mov ah,[di]
    cmp ah,[si]
    jz deletecontinue1
    
    pop di           ;不相等才pop出去
    jmp deletesearch@
    
deletecontinue1:    
    inc si
    inc di
    
    cmp [di],'@'
    
    jnz  deleteloop1
                                                            ;个人觉得结束都不用存储
    inc di
    mov deleteexplastart ,di   ;存解释的开始
    
        
deleteend:
    ;mov di,deletewordstart
    pop di          ;及时拿出栈里面的内容
    
    mov cx,200
    mov bx,4
findwordend:
    mov al,'@'
    repne scasb
    
    sub bx,1
    cmp bx,0
    jnz  findwordend
    
    
    mov deletewordend,di
    
    mov bx,1
    mov di,deleteexplastart
findwordexplaend:
    mov al,'@'
    repne scasb
            
    mov deleteexplaend,di    
    
    pop si                  
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    ret 
    
    

;还是要写子程序

FINDINSERT proc 
    push ax
    push bx
    push cx
    push dx
    push di
    push si
    ;个人的建议是直接在filecontent里面进行操作
    
    ;找到每一次的单词的开头进行匹配，当比后面的单词小，比当前的单词大的话
    xor cx,cx
    xor bx,bx
    mov cl,wordsnum 
    add cl,wordsnum                    ;及时更新？
    add cl,wordsnum
    add cl,wordsnum
    mov all@num,cl
    
    lea di,filecontent
    mov bl,0
    mov cu@num,bl
    
    ;mov al,'@'
    mov cx,200  ;这个cx 十分重要!
insertsearch@:    
    
    mov al,'@'
    repne scasb ;此时的话，di已经跳过了原本的@
    ;找到@
    mov bl,cu@num
    inc bl
    mov cu@num,bl
    
    cmp bl,all@num
    jz insertend                                ;如过没有提前退出，那么就在末尾插入
    
   
    ;push al
    ;接下来是除法操作
    mov ax,bx
    mov dl,4
    div dl    ;除法的余数在ah
    cmp ah, 1  ;说明找到单词的位置
     
    jnz insertsearch@
    push di             ;此时的di指向单词的第一个字母
    
    push cx
    mov cx,200
    lea si,newword
    
    repe cmpsb
    ;相等的话就一直比较
    sub si,1
    sub di,1
    
    mov al,[di]
    cmp al,[si]
    ja  nextinsert
                       ;如果原本的di指向的字母大于[si]指向的字母，说明新的单词插在栈存储的di处
    pop cx
    pop di
    jmp insertsearch@
    
nextinsert:
    
    
    ;不找了
    pop cx
    pop di
    mov newwordinsertplace,di
    jmp realinsertend
    
    
insertend:
    ;如果没有找到比插入单词小的单词，就很简单后面直接在单词的末尾插入即可
    lea si,filecontent
    add si,filecontentlen
    mov newwordinsertplace,si
    ;add newwordinsertplace,filecontentlen
     
realinsertend:

    pop si                  
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    
    ret
        
    end start
ends