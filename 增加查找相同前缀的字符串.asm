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
    
    ;�ر��ļ�?
     
    
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
    
    ;�����������в�����ɾ������
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
    ;�ָ�di��ֵ
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