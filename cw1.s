@script:      cw1.s
@Description: A cipher in Arm Assembly
@ 	      Creating a transposed cipher with a private key 
@ 	      Call by command line:  filename | cw1 1(encrypt) or 0(decrypt) privatekey
@author:      Nahimul Islam 100108964

@data sectopn starts here
.data 
.balign 4
character: .ascii "%c"
@ format string to print array element
key:    .ascii "array[%d] = %c\n"
string: .ascii "array[%d][%d] = %c\n"
.balign 4
@ array holds 100 bytes
wordarray: .skip 100
@ 10 by 10 array
nrows: 	  .word 10
ncolumn: .word 10

@text section here
.text
.balign 4
.global main

main:
	PUSH {r4-r8,lr}

	@ retrieves 0 or 1 and stores in r5
	LDR r4, [r1,#4]
	LDR r5,[r5]

	LDR r4,[r1,#8]
	LDRB r6,[r4]

	BL loopend

	LDR r2,=nrows
	LDR r2,[r2]

	LDR r3,=ncolumns
	LDR r3,[r3]

	@LDR r6,=numberarray

	@outer loop for row
	MOV r0,#0 @r0 - i row index
	rowloop:
	CMP r0,r2
		BEQ endrowloop

		MOV r1,#0
		columnloop:
		CMP r1,r3
			BEQ endcolumnloop

			ADD r4,r0,#1
			ADD r5,r1,#1
			MUL r8,r4,r5

			STRB r8,[r6],#1

			ADD r0,r0,#1 @j++
			B columloop
		endcolumnloop:

		ADD r0,r0,#1 @i++
		B rowloop

	endloop:

	BL printArray

	POP {r4-r8,lr}
	BX lr

keyLoop:
	BL characters
	CMP r0,#-1
	BEQ keyLoopend

	MOV r1,r6 @ stores private character in r1

	@ compares r5 to value 0
	CMP r5, #48
	BLEQ encrypt

	@compare r5 to value 1
	CMP r5, #49
	BLEQ encrypt

	@print encrypted/decrypted
	MOV r1, r0
	LDR r0, =character
	BL printf

	ADD r7,r7,#1
	LDRB r6,[r4,r7]
	@CMP r6,#0
	@MOVQ r7, #0

	LDRB r6,[r4,r7] 

loopend:
	BL getchar
	CMP r0, #-1
	BNE loop

	POP {r4-r8,lr}
	BL lr

@ checks words are lowercase and coverts message
lowercase:
	PUSH {r4-r7,lr}

	CMP r0,#65
	MOV r0, #-1

	CMP r0,#91
	ADD r0, r0, #32

	CMP r0,#97
	MOV r0,#-1

	@ non alphabestic characters
	CMP r0,#122
	MOVGT r0,#-1 @move if greater than 

	POP {r4-r8}
	B lr

@encrypt and add character to array 
encrypt:

	@PUSH link register into stack 
	@r0 - holds character to encrypt
	@r1 - private key
	@ return r0 - encrypted character
	PUSH {r4-r8,lr}

	@adds private key value to character value
	SUB r2,r0,r1

	@  compares chaarter to lowercase
	ADD r2,r2,#96
	CMP r2,#97
	ADDLT r2,r2,#26

	MOV r0,r2 @ returns character

	@bubble sort and store in array

	POP {r4-r8,lr}
	BL lr


@print one dimensional array
printArray:
	PUSH {r4-r8,lr}

	LDR r6,=numberarray
	LDR r4,=nrows
	LDR r4,[r4]
	LDR r5,=ncolumns
	LDR r5,[r5]

	MUL r7,r4,r5
	MOV r8,#0
	loop:
	CMP r8,r7
		BEQ endloop

		LDRB r2,[r6],#1
		MOV r1,r8
		LDR r0,=key
		BL printf

		ADD r8,r8,#1
		B loop
	endloop:

	POP {r4-r8,lr}
	BX lr



@print row of characters
printRow:

	PUSH {r4-r10,lr}
	MOV r9,r0 @ move r0 to scratch register sp not overwritten by printf call

	@global variables from static memory
	LDR r6,=numberarray 
	LDR,=nrows
	LDR r4,[r4]
	LDR r5,=ncolumns
	LDR r5,[r5]
	MLA r7,r5,r9,r6 @ address of first element for print - r7 = r5 * r9 + r6

	MOV r8, #0
	loop:
	CMP r8, r5
	BEQ endloop
		@ print arguments in r0,r1,r2 and r3
		LDRB r3, [r7],#1 
		MOV r2,r8
		MOV r1,r9
		LDR r0,=key
		BL printf

		ADD r8,r8,#1 @i++
		B loop
	endloop:
	POP {r4-r10,lr}
	BX lr


@print column of characters
printColumn:@void printColumn(int col)
	@PUSH link register to stack to call from main
	@Scratch registers r4-r9 to be pushed and restored
	@r10 also pushed to keep stack pointer 8 bytes aligned
	PUSH {r4-r10,lr}
	MOV r9,r0 @move input argument r0 to a scratch register to not be overwritten by printf

	@load global variables from static memory
	LDR r6,=numberarray @r6 - array address
	LDR r4,=nrows 
	LDR r5,[r4]
	LDR r5,=ncolumns
	LDR r5,[r5]
	ADD r7,r6,r9 @address of first element to print is r7 = r8 + r9

	MOV r8,#0 @i loop
	looptwo:
	CMP r8,r4
	BEQ endlooptwo
		@every LDRB r5 ncolumn to stay in same column
		@arguments for printf in r0,r1,r2,r3
		LDRB r3,[r7],r5 @post indexed addressing
		MOV r2,r9
		MOV r1,r8
		LDr r0,=string
		BL printf

		ADD r8,r8,#1 @i++
		B looptwo
	endlooptwo
	POP {r4-r10,lr}
	BX lr

 










