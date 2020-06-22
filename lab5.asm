;.286
.model small
.stack 256h
.data
symbol db "$"
number_of_lines db 6 dup("$") 
input_len db 8 dup("$")    
filename db 255 dup(0)  
message db "The number of rows is less than the specified size:",0Dh,0Ah,'$'
error_message1 db 0Dh,0Ah,"The input positive number has incorrect symbol",0Dh,0Ah,'$'   
error_message2 db 0Dh,0Ah,"There was an overflow in the number",0Dh,0Ah,'$' 
error_message3 db 0Dh,0Ah,"Usage [fileName] [number]",0Dh,0Ah,'$'
error_message4 db 0Dh,0Ah,"File open error!",0Dh,0Ah,'$'
endl db 0Dh,0Ah,'$'
.code

itoa proc
xor si,si
push ax
push bx
push cx
push dx  

cicle2:
mov ax,di
xor dx,dx
mov bx,10
div bx 
add dx,'0'
mov number_of_lines[si],dl 
inc si
mov di,ax
cmp di,0
jne cicle2
je reverse

reverse:
dec si
xor di,di
cicle3:
cmp si,di
jbe end_itoa
ja reverse_symbols

reverse_symbols:
mov bl,number_of_lines[si]
mov bh,number_of_lines[di]
mov number_of_lines[si],bh
mov number_of_lines[di],bl  
inc di
dec si
jmp cicle3

end_itoa:
pop dx
pop cx
pop bx
pop ax    
ret
itoa endp

output macro str
mov dx,offset str
mov ah,9
int 21h    
endm 

input macro  str
mov dx,offset str
mov ah,0ah
int 21h    
endm

atoi proc
xor si,si 
xor bx,bx ;bl-error code bh-init count
;mov si,2 
push ax
push dx 
push cx
xor dx,dx
xor ax,ax

cicle1:
mov al,input_len[si]
inc si
cmp ax,'$'
je end_atoi
jne check_number1

check_number1:
cmp ax,'0'
jae check_number2
jb error1

check_number2:
cmp ax,'9'
jbe this_is_number
ja error1

this_is_number:
cmp dx,0        
je initialize
jne add_in_count

initialize:
sub ax,'0' 
mov bh,1
add dx,ax  
jmp next

add_in_count:
sub ax,'0' 
mov cx,ax
mov ax,10 
mul dx
push dx
mov dx,ax 
add dx,cx
pop di
cmp di,1
je error2 ;overflow
jne compare_for_positive_number  

compare_for_positive_number:
cmp dx,32767
ja error2 ;overflow
jbe not_overflow

not_overflow: 
xor ax,ax
jmp next 
 
error1:
output error_message1 
mov bl,1 
jmp end_atoi
               
error2:
output error_message2 
mov bl,1 
jmp end_atoi 

next:
jmp cicle1 

end_atoi:
mov si,dx
pop cx
pop dx
pop ax
ret
atoi endp


main: 
mov ax,@data
mov ds,ax 

mov bl, es:[80h]        ;size of args
add bx, 80h 
mov si, 82h

cmp si, bx
ja NoArgsExc 
jbe next_step

NoArgsExc:
output error_message3
jmp exit

next_step: 
xor di,di
find_filename:
mov al,es:[si]
inc si
cmp al,' '
jne check_13
je start_find_number

check_13:
cmp al,13
je error_m3
jne add_symbol_in_filename

add_symbol_in_filename:
mov filename[di],al
inc di 
jmp find_filename

error_m3:
output error_message3  
jmp exit

start_find_number:
mov filename[di],0
mov filename[di+1],'$'  
xor di,di
jmp find_number 
  
add_symbol_in_number:
mov input_len[di],al
inc di
jmp find_number
  
find_number:
mov al,es:[si]
inc si
cmp al,13
jne add_symbol_in_number
 
call atoi
cmp bl,1
je exit

xor bp,bp    ; string size
xor di,di    ; number of lines
             ; si input_len
open_file:
mov dx,offset filename
mov ah,3dh
mov al,00h
int 21h
jc file_open_error
mov bx,ax   

read_data:
mov cx,1
mov dx,offset symbol
mov ah,3fh
int 21h
;jcxz output_result
cmp ax,0          ;;;;;;;;;;;;;;
je compare_size
jne string_size  

string_size:
cmp symbol,10
je compare_size
jne next_compare

next_compare:
cmp symbol,13
je read_data
jne usual_symbol  

usual_symbol:
inc bp
jmp read_data

compare_size:
cmp si,bp
ja inc_number_of_lines
jbe free_string_size

inc_number_of_lines:
inc di

free_string_size:
xor bp,bp 
cmp ax,0
jne read_data
je output_result

output_result:
call itoa

output message
output number_of_lines
jmp close_file

file_open_error:  
output error_message4
jmp exit 

close_file:
mov ah,3eh
int 21h

exit:
mov ax,4c00h
int 21h
end main 