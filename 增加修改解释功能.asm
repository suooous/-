; multi-segment executable file template.

;scroll
SCROLL    MACRO     N,ULR,ULC,LRR,LRC,ATT    ;�궨��
    
          push ax
          push bx
          push cx
          push dx
          MOV       AH,6            ;�������Ͼ�
          MOV       AL,N            ;N=�Ͼ�������N=0ʱ���������ڿհ�
          MOV       CH,ULR          ;���Ͻ��к�
          MOV       CL,ULC          ;���Ͻ��к�
          MOV       DH,LRR          ;���½��к�
          MOV       DL,LRC          ;���½��к�
          MOV       BH,ATT          ;����������
          INT       10H 
          
          pop dx
          pop cx
          pop bx
          pop ax
ENDM

;curse ���ù�������
CURSE     MACRO     CURY,CURX
          
          push AX
          push bx
          push dx    
          MOV       AH,2                ;�ù��λ��
          MOV       DH,CURY             ;�к�                ;Y ���кţ�X ���к�
          MOV       DL,CURX             ;�к�
          MOV       BH,0                ;��ǰҳ
          INT       10H
          
          pop dx
          pop bx
          pop ax
          ENDM

GAP macro 
    SCROLL 1,8,20,18,50,2FH        ;���ڴ��ڣ��̵װ���
    CURSE 18,20 
    
    endm
;ʵ���ҵ��Ƿ�����Ҫ�ĵ��ʵ��ʵĶ�λ

PRINT macro  printcontent ;רע������������������Ŀ�ʼ���Լ�Ҫ����ĳ��ȣ���ֿ�������Ļ��е�Ҫ��
    
    local next_char,printend
    push cx
    push si
    push dx
    push bx
    push ax
    
    ;��ȡ���ʵĿ�ͷ
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
    ;��ʱ�����붼��temp�洢
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
    
    
    SCROLL 0 ,0, 0,24,79,02           ;����  (�ڵ���ɫ��)
    SCROLL 13,7,19,19,51,50H        ;���ⴰ�ڣ�Ʒ���
    SCROLL 11,8,20,18,50,2FH        ;���ڴ��ڣ��̵װ���
    CURSE 18,20 
    ; �����ļ�
    ;lea dx, F1
    ;mov cx, 0
    ;mov ah, 3Ch
    ;int 21h
    ;jc error    ; �����Ƿ�������
    

;ֻ����뵥�ʼ���
;����ִ�е���Ӣ�Ľ��͵��޸ģ�Ӣ�Ľ��͵�ɾ��
    lea si,findword    
    mov cx,5
loopgetword:
    mov ah,01
    int 21h
    mov [si],al
    inc si
    
    loop loopgetword
    
          
    ;���ļ�
    
    lea dx,F1
    mov al,02
    
    mov ah,3DH
    int 21h
    
    
    
    ;��ȡ�ļ�
    mov bx,ax
    mov cx,200
    lea dx,filecontent
    mov ah,3FH
    int 21h
    
    ;��ʱ��ax�洢ʵ�ʶ�����ֽ�
    mov filecontentlen,ax
    
    ;�ȹر��ļ�
    mov ah,3EH
    int 21h 
                                                                  ;�Ѿ��ر��ļ�
    ;��ʱ����Ϣ��dx ��
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
    ;������ʵĽ���
    
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
    ;���ƥ����ַ���
    ;�����Ȼ�ȡstrmatch��strlen
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
    
    
    ;����Ĵ����Ѿ�����˲��ҵĲ���
    ;���ļ�
    
    lea dx,F1
    mov al,02
    
    mov ah,3DH
    int 21h
    mov fileflag,ax
    jc error1
    
    
    ;��ȡ�ļ�
    mov bx,ax
    mov cx,200
    lea dx,filecontent
    mov ah,3FH
    int 21h                                                                                            ;��¼�ļ����Ӧ���ڴ��ļ���
    jc error2
                                              ;�洢�ļ����
    ;�����������в�����ɾ������
    ;���½���
    lea si,filecontent
    mov filestart,si
    ;��ȡҪɾ���ĵ����뵥�ʵĳ���
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
     
    ;ɾ�����ʲ���                                                                      ;��Ӧ��ע��wordsumҪ��һ
    call DELETE
    
    
    mov bx,fileflag
    mov al,00h
    mov cx,0                  ;ƫ��������Ļ�����1                                   ;�ƶ��ļ�ָ��
    mov dx,deletewordstart
    sub dx,filestart
    
    mov ah,42h
    
    int 21h
    
    ;д�ļ�
    ;mov cx,filecontentlen-deletewordend  ;Ҫ��һ���������洢���һ���ַ���λ�ã�
    ;mov dx,deletewordend
    mov bx,fileflag
    mov cx,filecontentlen
    add cx,filestart             ;filecontentlen - (deletewordend-filestart)
    sub cx,deletewordend
    
    lea dx,filecontent
    add dx,deletewordend        ;ʣ�µ��ַ����ĳ��ȣ�
    sub dx,filestart
     
    mov ah,40h
    int 21h                       ;д�ļ�
    jc error3
    

    ;ɾ�����
    
    mov bx,filecontentlen      ;filecontentlen-(deletewordend-deletewordstart)
    add bx,deletewordstart                                                                    ;���ڽ��͵ĸ��²�����
    sub bx,deletewordend
    mov filecontentlen,bx
    
    ; Exit to operating system
    
    
    
    ;ɾ����ϣ��ر��ļ�
    mov bx,fileflag
    mov ah,3EH
    int 21h                         ;�����������е��ʵĲ���
    jc error4
    
    
    mov cl,wordsnum
    sub cl,1
    mov wordsnum,cl
    
    gap
    
    ;��һ�ִ��ļ�
    
    lea dx,F1
    mov al,02
    
    mov ah,3DH
    int 21h
    
    mov fileflag,ax
    
    ;��ȡ�ļ�
    mov bx,ax
    mov cx,filecontentlen         ;��ʱֻ������������õ�����
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
                                                                                         ;������������⣬��ȡ�ַ����ĳ��ȣ�Ҫ��ȥ30h
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
    
  ;��ȡ���ͽ���ʷ���ʵ�
    gap
  lea dx,str9
    mov ah,09h
    int 21h
    
    gap
    xor bx,bx
    
    mov ah,01h                                                                    ;����ҲҪ�ȼ�ȥ30h
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
    ;��ȡ����Ľ����Լ�����ʷ����
      
    gap
    
    call FINDINSERT                ;ͨ�����ø��ӳ��򣬿���֪���µĵ���Ӧ�ò����λ��
    
    ;�����ֶ�ƴ��
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
    
    ;��һ��di��ֵ����
    lea si,more
    mov cx,morelen
    
    repe movsb
    
    ;��ʱ��filecontent�����������ĵ��ʱ�
    mov cx,filecontentlen
    add cx,newwordlen
    add cx,morelen
    mov filecontentlen,cx
    
    mov al,wordsnum
    add al,1
    mov wordsnum,al
    
    ;�����ļ�ָ���Լ�д���ļ�
    mov bx,fileflag
    mov al,00h
    mov cx,0                  ;ƫ��������Ļ�����1                                   ;�ƶ��ļ�ָ��
    mov dx,0
    
    mov ah,42h
    
    int 21h
    
    lea dx,filecontent
    mov cx,filecontentlen
     
    mov ah,40h
    int 21h                       ;д�ļ�
    
    ;�ر��ļ�
    mov bx,fileflag                                                                                ;���ڽ��͵ĸ��²�����
                                                                                                   ;deleteexplastart deleteexplaend
    mov ah,3EH                                                                                     ;����Ļ� ABC@ Ҫ��@��β��ͬʱ
    int 21h                                                                                        ;��deleexplastart�����룬ͬʱdeleexplaend��
 
 
  
 ;��ʼ���н��͵��޸�                                                                                                   ;һֱǰ�ƣ�ע��������Ӧ��filecontentlen
 ;��ʵ�󲿷ֵĴ����ɾ�����ʵĲ�������
     ;��һ�ִ��ļ�
    
    lea dx,F1
    mov al,02
    
    mov ah,3DH
    int 21h
    
    mov fileflag,ax
    
    ;��ȡ�ļ�
    mov bx,ax
    mov cx,filecontentlen         ;��ʱֻ������������õ�����
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
                                                                                         ;������������⣬��ȡ�ַ����ĳ��ȣ�Ҫ��ȥ30h
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
    
 
      
    
    call DELETE               ;ͨ�����ø��ӳ��򣬿���֪���µĽ���Ӧ�ò����λ��

;��ʵ��Ҫ�Ƚϳ��ȵ����⣬���������ȿ��ǲ���Ľ��ͳ��ȴ���ԭ���Ľ���    
    ;�����ֶ�ƴ��
    
    ;                                           ;�����ǲ��룬����Ӧ���ú��������ƶ�
    
    ;�Ƚ�����Ĳ��ִ洢��tempstore
    
    mov cx,filecontentlen
    add cx,filestart                                 ;���Ʋ�������ʹ��repe movsb��������Ϊ�����ǴӺ�����ǰ�������
    sub cx,deleteexplaend
    mov si,deleteexplaend
    lea di,tempstore
    repe movsb
    
    
    
    mov di,deleteexplastart
    lea si,insertexpla                       ;�����µĽ���
    mov cx,insertexplalen
    
    repe movsb
    
    ;��tempstore��ȡ
    lea si,tempstore
    ;��ʱ��di�Ѿ��洢����
    mov cx,filecontentlen
    add cx,filestart                                 ;���Ʋ�������ʹ��repe movsb��������Ϊ�����ǴӺ�����ǰ�������
    sub cx,deleteexplaend
    
    repe movsb
    ;��ʱ��filecontent�����������ĵ��ʱ�
    mov cx,filecontentlen
    add cx,insertexplalen
    add cx,deleteexplastart
    sub cx,deleteexplaend
    mov filecontentlen,cx
    

    
    ;�����ļ�ָ���Լ�д���ļ�
    mov bx,fileflag
    mov al,00h
    mov cx,0                  ;ƫ��������Ļ�����1                                   ;�ƶ��ļ�ָ��
    mov dx,0
    
    mov ah,42h
    
    int 21h
    
    lea dx,filecontent
    mov cx,filecontentlen
     
    mov ah,40h
    int 21h                       ;д�ļ�
    
    ;�ر��ļ�
    mov bx,fileflag                                                                                ;���ڽ��͵ĸ��²�����
                                                                                                   ;deleteexplastart deleteexplaend
    mov ah,3EH                                                                                     ;����Ļ� ABC@ Ҫ��@��β��ͬʱ
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
    
    ;���ã���dx�е�����ֱ�������ÿһ��30���ַ���ʵ����Ļ���ϻ�
    ;Ҫ�ҵĵ��ʴ洢��findword,�ļ����������ݽ��洢��filecontent,���ڵ���������ҵ������ʵ�ƥ���λ�ã������ڵ��ú�֮ǰ�Ѿ����ļ�    
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
    
     ;������n�����ʵ�ʱ�򣬾ͻ���4*n��@
    
    
    lea di,filecontent
    
    ;mov al,'@'
    mov cx,200  ;���cx ʮ����Ҫ!
search@:    
    
    mov al,'@'
    repne scasb ;��ʱ�Ļ���di�Ѿ�������ԭ����@
    ;�ҵ�@
    mov bl,cu@num
    inc bl
    mov cu@num,bl
    
    cmp bl,all@num
    jz notfind@
   
    ;push al
    ;�������ǳ�������
    mov ax,bx
    mov dl,4
    div dl    ;������������ah
    cmp ah, 1  ;˵���ҵ����ʵ�λ��
     
    jnz search@
     push di
; �����ж�findword �� filecontent�������ĵ����Ƿ�һ����    
    lea si, findword
loop1:    
    mov ah,[di]
    cmp ah,[si]
    jz continue1

    pop di           ;����Ȳ�pop��ȥ
    jmp search@
    
continue1:    
    inc si
    inc di
    
    cmp [di],'@'
    
    jnz  loop1
    
    mov findflag,1
    jmp yesfind
        
notfind@:
    ;���notfind@
    mov dl,'N'
    mov ah,02h
    int 21h     
    
    jmp end1
    
yesfind:
    mov al,01
    mov [findflag],al
    ;���ڵ��ʴ��ڣ���ô�Ϳ��Խ��е��ʵĽ��ͣ�����ʣ�����ʵ����
    pop di
    mov wordstart,di
    ;���һ������
    ;��Ļ����
    ;����λ
    
    SCROLL 1,8,20,18,50,2FH        ;���ڴ��ڣ��̵װ���
    CURSE 18,20 
    
    
    ;��Ӧ���ҵ������@
    mov al,'@'
    repne scasb 
    
    ;��ȡ���ͣ�����ʣ������
    
    lea si,[wordexpla] 
getexpla:    
    mov al,[di] 
    cmp al,'@'
    jz getsy0 
    mov [si],al                   ;wordexpla,wordsy,wordan���ֱ�洢�����Ӧ�����ݣ���������$��β
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
    ;cu@num��all@num������ĺ����Ļ��Ѿ�������ˣ�����Ҫ���¼���
    
    
    lea di,filecontent
    
    mov cx,300  ;���cx ʮ����Ҫ!
    mov al,0
    mov cu@num,al 
    
    lea si,matchstr
    mov matchstrend,si
matchsearch@:    
    
    mov al,'@'
    mov dl,[di]
    repne scasb ;��ʱ�Ļ���di�Ѿ�������ԭ����@
    ;�ҵ�@                                                  ;����Ҫ����һ����־�����û��ƥ�䣿����Ŀǰ�Ļ���Ҳ���Բ��ÿ�����ô��
    mov bl,cu@num
    inc bl
    mov cu@num,bl
                                                            ;strmatch ��Ҫƥ����ַ���
                                                            ;�ļ��ж��������ݴ洢��filecontent����
                                                            ;ÿһ�ζ���filecontent�ĵ��ʵĲ��ֽ���strmatch��ƥ������
                                                            ;����strmatch�ĳ��ȴ洢��strlen,��������һֱƥ�䵱ƥ��ĳ��ȵ���strle                                                            ;�Ϳ��Դ����ǵ�pop di���н����ʴ洢��matchstr��
    cmp bl,all@num
    jz matchend
   
    ;push al
    ;�������ǳ�������
    mov ax,bx
    mov dl,4
    div dl    ;������������ah
    cmp ah, 1  ;˵���ҵ����ʵ�λ��
     
    jnz matchsearch@
     push di           ;��ʱ��di �Ѿ��洢�˵��ʵĿ�ͷ 
; �����ж�    
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
    ;ƥ��ɹ��������ʴ洢��matchstr��  
    pop cx  ;�ܴ�����⣡
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
    ;mov matchstrend,si   ;������si,��Ϊ��Ҫ��¼����matchstr ����һ�������λ��
    jmp tran:

matchcontinue0:
    mov [si],','
    inc si
    mov matchstrend,si
          
matchcontinue: ;�޷�ƥ��ɹ������ߴ洢������
    ;�ָ�di��ֵ                                                ;ջ����һ��������
    ;pop cx           ;��һ�侹Ȼ��Ҫ
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
    
    ;���Ѿ���ȡ�ļ���������filecontent,Ҫɾ���ĵ�����deleteword��,��ôdeletewordlen��¼deleteword�ĳ���
    ;��ֻҪһֱƥ�䣬��ƥ��ɹ���ʱ�򣬻�Ҫһֱ��ȡ��ȥ
    ;ͬʱ��¼��deletewordstart��deletewordend��λ��    (����ɾ�������������壩
    ;deleteexplastart �� deleteexplaend �������½���
    
    ;���˾��ú����ô����µ��ļ�������һ��������������ǿ��Ե�
        
    lea di,filecontent
    
    ;mov al,'@'
    mov cx,200  ;���cx ʮ����Ҫ!
    mov bl,0
    mov cu@num,bl ;��ʼ��
deletesearch@:    
    
    mov al,'@'
    repne scasb ;��ʱ�Ļ���di�Ѿ�������ԭ����@
    ;�ҵ�@
    mov bl,cu@num
    inc bl
    mov cu@num,bl
    
    cmp bl,all@num
    jz deleteend
   
    ;push al
    ;�������ǳ�������
    mov ax,bx
    mov dl,4
    div dl    ;������������ah
    cmp ah, 1  ;˵���ҵ����ʵ�λ��
     
    jnz deletesearch@
     push di
; �����ж�findword �� filecontent�������ĵ����Ƿ�һ����    
    lea si, deleteword
     
    mov deletewordstart,di ;�Ƚ���ʼ�ĵ�ַ������
    
    ;��ͨ����ѭ������
    
deleteloop1:    
    mov ah,[di]
    cmp ah,[si]
    jz deletecontinue1
    
    pop di           ;����Ȳ�pop��ȥ
    jmp deletesearch@
    
deletecontinue1:    
    inc si
    inc di
    
    cmp [di],'@'
    
    jnz  deleteloop1
                                                            ;���˾��ý��������ô洢
    inc di
    mov deleteexplastart ,di   ;����͵Ŀ�ʼ
    
        
deleteend:
    ;mov di,deletewordstart
    pop di          ;��ʱ�ó�ջ���������
    
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
    
    

;����Ҫд�ӳ���

FINDINSERT proc 
    push ax
    push bx
    push cx
    push dx
    push di
    push si
    ;���˵Ľ�����ֱ����filecontent������в���
    
    ;�ҵ�ÿһ�εĵ��ʵĿ�ͷ����ƥ�䣬���Ⱥ���ĵ���С���ȵ�ǰ�ĵ��ʴ�Ļ�
    xor cx,cx
    xor bx,bx
    mov cl,wordsnum 
    add cl,wordsnum                    ;��ʱ���£�
    add cl,wordsnum
    add cl,wordsnum
    mov all@num,cl
    
    lea di,filecontent
    mov bl,0
    mov cu@num,bl
    
    ;mov al,'@'
    mov cx,200  ;���cx ʮ����Ҫ!
insertsearch@:    
    
    mov al,'@'
    repne scasb ;��ʱ�Ļ���di�Ѿ�������ԭ����@
    ;�ҵ�@
    mov bl,cu@num
    inc bl
    mov cu@num,bl
    
    cmp bl,all@num
    jz insertend                                ;���û����ǰ�˳�����ô����ĩβ����
    
   
    ;push al
    ;�������ǳ�������
    mov ax,bx
    mov dl,4
    div dl    ;������������ah
    cmp ah, 1  ;˵���ҵ����ʵ�λ��
     
    jnz insertsearch@
    push di             ;��ʱ��diָ�򵥴ʵĵ�һ����ĸ
    
    push cx
    mov cx,200
    lea si,newword
    
    repe cmpsb
    ;��ȵĻ���һֱ�Ƚ�
    sub si,1
    sub di,1
    
    mov al,[di]
    cmp al,[si]
    ja  nextinsert
                       ;���ԭ����diָ�����ĸ����[si]ָ�����ĸ��˵���µĵ��ʲ���ջ�洢��di��
    pop cx
    pop di
    jmp insertsearch@
    
nextinsert:
    
    
    ;������
    pop cx
    pop di
    mov newwordinsertplace,di
    jmp realinsertend
    
    
insertend:
    ;���û���ҵ��Ȳ��뵥��С�ĵ��ʣ��ͺܼ򵥺���ֱ���ڵ��ʵ�ĩβ���뼴��
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