DATA	SEGMENT
ADDS	DB	'C:\MYSTU.TXT',0
BUFFER	DB	900 DUP (?)
STR1	DB	13,10,'Fail to open the file!$'
STR2	DB	13,10,'Fail to read the file!$'
STR3	DB	13,10,'Fail to close the file!$'
STR4	DB	13,10,'The all numbers are as follows:',13,10,'$'
STR5	DB	13,10,'The number of present students (means N) is $'
STR6	DB	'.',13,10,'The lucky student is the No.$'
STR7	DB	' one to be here.',13,10,'His number is $'
STR8	DB	'.',13,10,'\(^_^)/   Congratulations!$'
FLAG	DB	0
N	DB	0
I	DB	0
J	DB	0
M	DB	0
DATA	ENDS

SSEG	SEGMENT	'STACK'	
DW	200H DUP(0)
SSEG	ENDS

CODE	SEGMENT
	ASSUME	CS:CODE,DS:DATA,SS:SSEG

PRINN	PROC	NEAR			;PRINN函数用于将N以十进制形式输出
	PUSH	AX
	PUSH	BX
	PUSH	CX
	PUSH	DX
	CMP	N,10			;判断N是否只有一位
	JNB	P2
	ADD	N,30H
	MOV	AH,2
	MOV	DL,N
	INT	21H
	JMP	P3
P2:	MOV	AL,N
	MOV	BL,100
	AND	AX,00FFH
	DIV	BL
	MOV	BH,AH
	MOV	DL,AL
	ADD	DL,30H
	CMP	DL,30H
	JZ	P1
	MOV	AH,02H
	INT	21H
P1:	MOV	BL,10
	MOV	AX,0
	MOV	AL,BH
	DIV	BL
	MOV	BH,AH
	MOV	DL,AL
	ADD	DL,30H
	MOV	AH,02H
	INT	21H
	MOV	DL,BH
	ADD	DL,30H
	INT	21H
P3:	POP	DX
	POP	CX
	POP	BX
	POP	AX
	RET
PRINN	ENDP

COUNN	PROC	NEAR			;COUNN函数用于记录总人数
	PUSH	DX
	CMP	DH,30H
	JB	ONE
	CMP	DH,39H
	JA	ONE
	INC	I
ONE:	CMP	I,7
	JNE	COEXIT
	INC	N
	MOV	I,0
COEXIT:	POP	DX
	RET
COUNN	ENDP

OUT1	PROC	NEAR			;OUT1用于输出第一句提示字符串
	PUSH	AX
	PUSH	DX
	MOV	AH,9
	LEA	DX,STR4
	INT	21H
	POP	DX
	POP	AX
	RET
OUT1	ENDP

OUT2	PROC	NEAR			;OUT2用于输出第二句提示字符串
	PUSH	AX
	PUSH	DX
	MOV	AH,9
	LEA	DX,STR5
	INT	21H
	CALL	PRINN			;调用PRINN函数输出与会总人数
	POP	DX
	POP	AX
	RET
OUT2	ENDP

COUT	PROC	NEAR			;COUT函数用于将文件内容打印在显示屏上并计数
	PUSH	AX
	PUSH	CX
	PUSH	DX
	PUSH	SI
	MOV	J,0
	MOV	CX,AX
	LEA	SI,BUFFER
	MOV	AH,2
C1:	MOV	DH,[SI]
	CMP	J,7			;每行显示7个学号，显示完毕转行
	JNE	C2
	MOV	J,0
	MOV	DL,13
	INT	21H
	MOV	DL,10
	INT	21H
C2:	CMP	DH,10
	JNE	C3
	MOV	DL,32
	INT	21H
	INC	J
	JMP	C4
C3:	CMP	DH,13
	JE	C4
	MOV	DL,DH
	INT	21H
C4:	CALL	COUNN			;调用COUNN函数，检查[SI]并计数
	INC	SI
	LOOP	C1
	
	POP	SI
	POP	DX
	POP	CX
	POP	AX
	RET
COUT	ENDP

OPENN	PROC	NEAR			;OPENN函数用于操作文件
	PUSH	SI
	PUSH	AX
	PUSH	DX
	PUSH	CX
	PUSH	BX
	MOV	AH,3DH			;打开文件
	LEA	DX,ADDS
	MOV	AL,2
	INT	21H
	JC	ERROR1
	LEA	DX,BUFFER		;读取文件并将文件内容
	MOV	BX,AX
	MOV	CX,900
	MOV	AH,3FH
	INT	21H
	JC	ERROR2	
	CALL	COUT			;调用COUT函数，显示全部学号并计数
	MOV	AH,3EH			;关闭文件
	INT	21H
	JC	ERROR3
OPEXIT:	POP	BX
	POP	CX
	POP	DX
	POP	AX
	POP	SI
	RET
ERROR1:	MOV	AH,9			;文件未能成功打开反馈
	MOV	FLAG,1
	LEA	DX,STR1
	INT	21H
	JMP	OPEXIT
ERROR2:	MOV	AH,9			;文件未能成功读取反馈
	MOV	FLAG,1
	LEA	DX,STR2
	INT	21H
	JMP	OPEXIT
ERROR3:	MOV	AH,9			;文件未能成功关闭反馈
	MOV	FLAG,1
	LEA	DX,STR3
	INT	21H
	JMP	OPEXIT
OPENN	ENDP

RANDD	PROC	NEAR			;RANDD函数用于生成随机数存入M
	PUSH	CX
	PUSH	DX
	PUSH	AX
	STI
	MOV	AH,0			;读取时钟计数器的值
	INT	1AH
	MOV	AX,DX
	AND	AH,3
	MOV	DL,N
	DIV	DL			;除以N，取得余数再+1作为随机数
	MOV	BL,AH
	INC	BL
	MOV	M,BL
	POP	AX
	POP	DX
	POP	CX
	RET
RANDD	ENDP

OUT3	PROC	NEAR			;OUT3用于输出第三句提示字符串
	PUSH	AX
	PUSH	BX
	PUSH	DX
	MOV	DH,N
	MOV	AH,9
	LEA	DX,STR6
	INT	21H
	MOV	BL,M
	MOV	N,BL
	CALL	PRINN			;调用PRINN函数，将M以十进制输出
	MOV	AH,9
	LEA	DX,STR7
	INT	21H
	MOV	N,DH
	POP	DX
	POP	BX
	POP	AX
	RET
OUT3	ENDP

OUT4	PROC	NEAR			;OUT4函数用于输出第三句提示语与幸运学生序号M
	PUSH	SI
	PUSH	AX
	PUSH	CX
	PUSH	DX
	DEC	M			;计算中奖学生学号在BUFFER数组中的位置
	MOV	AL,M
	MOV	DH,9
	MUL	DH
	MOV	SI,AX
	MOV	CX,7
HAHA:	MOV	AH,2			;输出中奖学生的学号
	MOV	DL,BUFFER[SI]
	INT	21H
	INC	SI
	LOOP	HAHA
	POP	DX
	POP	CX
	POP	AX
	POP	SI
	RET
OUT4	ENDP

OUT5	PROC	NEAR			;OUT1用于输出第四句提示字符串
	PUSH	AX
	PUSH	DX
	MOV	AH,9
	LEA	DX,STR8
	INT	21H
	POP	DX
	POP	AX
	RET
OUT5	ENDP

START:	MOV	AX,DATA
	MOV	DS,AX
	MOV	AX,0
	CALL	OUT1			;调用OUT1函数，输出第一句提示语
	CALL	OPENN			;调用OPENN函数对文件进行打开、读取、存储、关闭，同时计算与会学生总人数N
	CMP	FLAG,1			;如果文件操作错误，直接退出程序
	JE	OVER
	CALL	OUT2			;调用OUT2函数，输出第二句提示语与学生总人数N
	CALL	RANDD			;调用RANDD函数，生成随机数LUCK
	CALL	OUT3			;调用OUT3函数，输出第三句提示语与幸运学生序号M
	CALL	OUT4			;调用OUT4函数，输出幸运学生学号
	CALL	OUT5			;调用OUT5函数，输出第四句提示语
OVER:	MOV	AX,4C00H
	INT	21H
CODE	ENDS
	END	START
