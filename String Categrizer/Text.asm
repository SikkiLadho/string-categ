
;||		there should be categorties folder and input folder, all files should be included there								||;
;||		comma should not be printed at the last word, a flag should be created to know if this is a last word, 
;||SOLUTION--		 it could be done using GoToXY and delete/replace previously printed comma								||;															||
;||		write prototypes of functions that are not even taking any argumnets to make clear what funciton arer being used 	||;
;||            check if input is in right format, i.e ends with .
;||DONE---     tells if a file doesn't exist																				||;
;||Done--		take care of a bug explained in bug.txt file																||;




TITLE MY First Program
INCLUDE Irvine32.inc

wordFind PROTO, sourceText: ptr byte, tragetText: ptr byte, sourceSize: dword, targetSize: dword
printCategName PROTO, categName:PTR BYTE, categNameSize:DWORD
printFoundWord PROTO, foundWord:PTR BYTE
clearString PROTO, textString:PTR BYTE, StringLength:DWORD
extractWord PROTO
writeFileNotExist PROTO, fileName:PTR BYTE


.data


categStringSize DWORD 10000
categString BYTE 10000 dup(0)
foundWords BYTE 10000 dup(0)
foundWordsSize DWORD 10000 
foundWordOffset DWORD 0


FileNames	  byte  "categories\Pronouns.txt",0,0,0,0,0,0,0,0,0
			  byte   "categories\Adjectives.txt",0,0,0,0,0,0,0
			  byte   "categories\Conjunction.txt",0,0,0,0,0,0
			  byte    "categories\Helping verbs.txt",0,0,0,0
			  byte    "categories\Nouns(names).txt",0,0,0,0,0
			  byte    "categories\Nouns(academic).txt",0,0
			  byte   "categories\Nouns(countries).txt",0
			  byte    "categories\Articles.txt",0,0,0,0,0,0,0,0,0
			  byte    "categories\Adverbs.txt",0,0,0,0,0,0,0,0,0,0
			  byte    "categories\Interjections.txt",0,0,0,0
			  byte    "categories\Prepositions.txt",0,0,0,0,0
					
NoOfCategs DWORD 11
CategNameLength DWORD 40
TempFileNames DWORD  ?


Categfilehandler DWORD 0

inputFile BYTE "input\input.txt",0
inputString BYTE 10000 dup(0)
inputFileHandler DWORD 0
currentInputIndex DWORD offset inputString  ;//this might create a problem
extractedWord BYTE 40 dup(0)
extractedWordSize DWORD 0
sepChar BYTE ' '           ; //seprating character
fwDisp DWORD 0
wordTheCount DWORD 0
;//loop counters
mainLoopCounter DWORD 20000


;//flags
inputFileEnded DWORD 0
fileCategWritten DWORD 0
noWordFound DWORD 0


;//Strings to be used
semiColon BYTE ":",0
comma BYTE ", ", 0
dot BYTE "."
bigSpace BYTE "       ",0
stars1 BYTE      "*******************************************************************************",0
projectName BYTE "		                String Categrizer			       		  ",0
stars2 BYTE      "*******************************************************************************",0
smallSpace BYTE "  ",0
		

;//prompts
promptFile1 BYTE "File '",0
promptFile2 BYTE "' does not exist or cannot be opened.",0
promptNoDot1 BYTE "The is no '.' terminator in the input.",0
promptWrong BYTE "Wrong choice",0
promptNoDot2 BYTE "'.' determines the end of input. Exiting the program.",0
promptSep1 BYTE "  Words in your input and categories are seprated by:",0
promptSep2 BYTE "   1. Comma ",0
promptSep3 BYTE "   2. Space ",0
promptCount BYTE "Following words were included more than one times in the input.",0
promptNoCateg BYTE "Following words were not found in any of the categories.",0
.code

main PROC
mov eax, offset foundWords
mov foundWordOffset, eax
call clrScr
call crlf

mov edx, offset stars1
call writeString
call crlf
mov edx, offset projectName
call writeString
call crlf
mov edx, offset stars2
call writeString
call crlf
call crlf


;////////////////////////
;read from file "input.txt" to inputString 

mov edx, offset inputFile
call openInputFile
mov inputFilehandler, eax

cmp eax, INVALID_HANDLE_VALUE
je InputFileNotExist


mov ecx, 20000
mov edx, offset inputString
mov eax, inputfilehandler
call readFromFile
;call writeString


; reading completed from input file, file text moved to inputString
;///////////////////////////



;checking if the file has the right format
;wordFind PROTO, sourceText: ptr byte, tragetText: ptr byte, sourceSize: dword, targetSize: dword

INVOKE wordFind, addr inputString, addr dot, lengthof inputString, lengthof dot

cmp ebx,-1
je noInputFormat

call inputLowerCase

;//////////////////////////

mov TempFileNames, offset FileNames
mov ecx,NoOfCategs
OuterLoop:

			mov NoOfCategs, ecx

			;//setting flags to zero
			mov eax, 0
			mov fileCategWritten, eax
			mov inputFileEnded, eax

			;//resetting currentInputIndex
			mov esi, offset inputString
			mov currentInputIndex, esi 

 
			INVOKE clearString, offset categString, categStringSize
			;//////////////////////////
			;reading from category food.txt to cagetString

			mov edx, TempFileNames
			call openInputFile
			mov Categfilehandler, eax

			cmp eax, INVALID_HANDLE_VALUE
			je FileNotExist


			mov ecx, 20000
			mov edx, offset categString
			mov eax, Categfilehandler
			call readFromFile
			;reading completed, text moved to categoryString
			;///////////////////////////


			mov ecx, mainLoopCounter
			innerLoop:
					mov mainLoopCounter, ecx
					mov eax, inputFileEnded
					cmp eax, 0
					jne breakLoopCateg2

					call extractWord

					INVOKE wordFind, addr categString, addr extractedWord, categStringSize, extractedWordSize
	
					cmp ebx, -1
					je loopEnd
					
					mov eax, fileCategWritten
					cmp eax, 0
					jne alreadyPrintedCateg2
					INVOKE printCategName, TempFileNames, CategNameLength	
			alreadyPrintedCateg2:
					 INVOKE printFoundWord, offset extractedWord
	
			jmp loopEnd
					
loopEnd:
					;//restoring ecx after a function call
					mov ecx, mainLoopCounter
	
			loop Innerloop

			breakLoopCateg2:
			
			mov eax,0
			cmp eax, -1
			jne skipThis

			call crlf
			
	

			
			jmp skipThis
FileNotExist:
			INVOKE writeFileNotExist, tempFileNames
skipThis:

			add TempFileNames,32
			mov ecx,NoOfCategs
			dec ecx
			cmp ecx, 0
jnz outerLoop




jmp skipDownStatement
noInputFormat:
	call crlf
	mov edx, offset promptNoDot1
	call writeString
	call crlf
	mov edx, offset promptNoDot2
	call writeString
	call crlf
jmp skipDownStatement

InputFileNotExist:
	INVOKE writeFileNotExist, addr inputFile

skipDownStatement:


call crlf
call crlf
mov edx, offset smallSpace
call writeString
;//setting flags to zero
			mov eax, 0
			mov fileCategWritten, eax
			mov inputFileEnded, eax

			;//resetting currentInputIndex
			mov esi, offset inputString
			mov currentInputIndex, esi 


loopNoCateg:
 			mov mainLoopCounter, ecx
			mov eax, inputFileEnded
			cmp eax, 0
			jne breakLoopNoCateg

			call extractWord

			INVOKE wordFind, addr foundWords, addr extractedWord, foundWordsSize, extractedWordSize
	
			cmp ebx, -1
			jne loopNoCateg
			
			mov eax, fileCategWritten
			cmp eax, 0
			jne alreadyPrintedNoCateg
			mov edx, offset promptNoCateg
			call writeString
			call crlf
		
			mov fileCategWritten, -1
alreadyPrintedNoCateg:
			mov edx, offset bigSpace
			call writeString
			call writeString
			INVOKE printFoundWord, offset extractedWord
			
			call crlf
	loop LoopNoCateg

breakLoopNoCateg:

call crlf
call crlf
call crlf
mov edx, offset stars1
call writeString
call crlf
mov edx, offset projectName
call writeString
call crlf
mov edx, offset stars2
call writeString
call crlf
call crlf





exit
main ENDP 


inputLowerCase PROC
mov eax, 0
mov ecx, 10000
mov esi, offset inputString
loopInputLowerCase:
	
	mov al, [esi]
	cmp al, '.'
	je breakInputLowerCase
	cmp al, sepChar
	je NextInputLowerCase
	cmp al, 097d
	jae NextInputLowerCase
	add al, 32
	mov [esi], al
	

NextInputLowerCase:
	inc esi
loop loopInputLowerCase

breakInputLowerCase:

ret
inputLowerCase ENDP

writeFileNotExist PROC, fileName:PTR BYTE

call crlf
call crlf
mov edx, offset promptFile1
call writeString
mov edx, fileName
call writeString
mov edx, offset promptFile2
call writeString
call crlf
call crlf

ret
writeFileNotExist ENDP



clearString PROC, textString:PTR BYTE, StringLength:DWORD

mov edi, textString
mov eax, 0
mov ecx, stringLength
rep stosb

ret
clearString ENDP


printFoundWord PROC, foundWord:PTR BYTE

INVOKE wordFind, addr foundWords, addr extractedWord, lengthof foundWords, extractedWordSize

cmp ebx, -1
jne returnPrintFoundWord

mov ecx, extractedWordSize
mov edi, foundWordOffset
mov esi, offset extractedWord 
rep movsb
mov foundWordOffset, edi


inc foundword
mov edx, foundword
call writeString

mov eax,-1
mov NoWordFound,eax


returnPrintFoundWord:
mov esi,0
mov edi,0
mov ecx, 0
ret
printFoundWord ENDP



printCategName PROC, categName:PTR BYTE, categNameSize:DWORD

call crlf
mov edx, offset smallSpace
call writeString
mov esi, categName
add esi, 11
mov ecx, categNameSize
mov eax,0
mov fileCategWritten, eax

loopPrintCategName:
				mov al, [esi]
				cmp al, '.'
				je breakPrintCategName
				mov al, [esi]
				call writeChar
				inc esi
loop loopPrintCategName

breakPrintCategName:
mov edx, offset semiColon
call writeString
call crlf

mov eax, 0fh
mov fileCategWritten, eax


mov edx, offset bigSpace
call writeString

ret
printCategName ENDP




extractWord PROC

INVOKE clearString, addr extractedWord, extractedWordSize 
mov ecx, 200

mov eax, 0
mov ebx, 0
mov extractedWordSize, eax

mov esi, currentInputIndex
mov edi, offset extractedWord

mov al, sepChar
stosb
inc extractedWordSize


cmp al, '.'
je return

noComma:
copy:
		 mov al, [esi]
		 cmp al, sepChar
		 je addComma
		 				 
		 mov bl, [esi]
		 cmp bl, '.'
		 je FileEnded

		 movsb
		 inc extractedWordSize
loop copy

FileEnded:
mov eax, 0fh
mov inputFileEnded, eax

addComma:
mov al, sepChar
stosb
inc esi
inc extractedWordSize



return:		  ;///you need to find size of the word here	
mov currentInputIndex, esi 		        ;///preserve esi for next use, if there's a problem 

ret
extractWord ENDP

wordFind proc uses ecx esi edi eax, sourceText: ptr byte, tragetText: ptr byte, sourceSize: dword, targetSize: dword

  mov ecx, sourceSize
  mov esi, sourceText
  mov edi, tragetText
  mov eax, 0
 
  L2:
  
    cmp eax, targetSize
    jz L5

    cmpsb
    jz L3
    mov edi, tragetText
    cmp eax, 1
    jb L4
    dec esi
    mov eax, 0
    jmp L4

    L3: 
    inc eax
   
  L4: 
  loop L2
 
  ;not found
  mov ebx, -1
  ret

  L5: ;found
      mov ebx, esi
      sub ebx, sourceText
      sub ebx, eax
  ret
wordFind endp

END main