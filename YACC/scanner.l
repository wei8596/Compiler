%option case-insensitive

/* Definition */
%{
#include <stdio.h>
#include <string.h>
#include "y.tab.h"

#define CH_MAX 100 /* 每行最大長度 */
#define LINE_MAX 1000 /* 最大行數 */
/* printf() color */
#define NONE "\033[m"
#define LIGHT_GREEN "\033[1;32m"

/* 計算行數, 字數 */
void count(char *str);

unsigned int lineCount = 1, lineChar = 1; /* 行數, 字數, 印出內容 */
char *current; /* 記錄token */
char ch[LINE_MAX][CH_MAX]; /* 檔案內容 */
%}

COMOP		<=|>=|<>|<|>|=
whitespace	[ \t]
newline		[\r\n]
letter		[A-Za-z]
DOTDOT		\.\.

/* number */
sign		[\+\-]
digit		[0-9]
digits		{digit}+
INT			(0|([1-9]{digit}*))
dotdigits	\.(0|({digit}*[1-9]0?))
exponent	[Ee]{sign}?{digits}
real		{INT}({dotdigits}|{exponent}|{dotdigits}{exponent})

ID			(_|{letter})({letter}|{digit}|_)*

not_found	.

/* Rules */
%%
{whitespace}	{count("");}
{newline}		{if(yytext[0]!='\r'){count("newline");}/*'\r' --- Windows文件 */}
{COMOP}			{count("");return(COMOP);}

array			{count("");return(ARRAY);}
begin			{count("");return(BEGIN1);}
do				{count("");return(DO);}
end				{count("");return(END);}
float			{count("");return(FLOAT);}
for				{count("");return(FOR);}
if				{count("");return(IF);}
integer			{count("");return(INTEGER);}
of				{count("");return(OF);}
program			{count("");return(PROGRAM);}
read			{count("");return(READ);}
realtype		{count("");return(REALTYPE);}
string			{count("");return(STRING);}
then			{count("");return(THEN);}
to				{count("");return(TO);}
var				{count("");return(VAR);}
write			{count("");return(WRITE);}

":="		{count("");return(ASSIGNOP);}
"<<"		{count("");return(*yytext);}
">>"		{count("");return(*yytext);}
"*"			{count("");return(*yytext);}
"/"			{count("");return(*yytext);}
"%"			{count("");return(*yytext);}
"&"			{count("");return(*yytext);}
"|"			{count("");return(*yytext);}
"~"			{count("");return(*yytext);}
"!"			{count("");return(*yytext);}
","			{count("");return(*yytext);}
"^"			{count("");return(*yytext);}
"."			{count("");return(*yytext);}
";"			{count("");return(*yytext);}
":"			{count("");return(*yytext);}
"("			{count("");return(*yytext);}
")"			{count("");return(*yytext);}
"["			{count("");return(*yytext);}
"]"			{count("");return(*yytext);}
"+"			{count("");return(*yytext);}
"-"			{count("");return(*yytext);}

{ID}			{count("");return(ID);}
{real}/[^0-9]	{count("");yylval.dval=atof(yytext);return(REAL); /* {real} but only if followed by [^0-9] */}
{INT}/[^0-9]	{count("");yylval.ival=atoi(yytext);return(INT);}
{DOTDOT}		{count("");return(DOTDOT);}
<<EOF>>			{count("EOF");return(0);}
{not_found}		{count("");return(*yytext);}

%%
/* User code */
/* 計算行數, 字數, 印出內容 */
void count(char *str) {
	int i;

	current = yytext;

	if(str == "newline") {
		strcat(ch[lineCount], yytext);
		printf(LIGHT_GREEN"Line %d: %s"NONE, lineCount, ch[lineCount]);
		++lineCount;
		lineChar = 1;
		return;
	}
	else {
		strcat(ch[lineCount], yytext);
	}

	/* yyleng --- yytext長度 */
	lineChar += yyleng;
}

