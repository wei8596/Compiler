%option case-insensitive

/* Definition */
%{
#include <stdio.h>
#define MAX_SIZE 31 /* ID, string最長30個字元 */

unsigned int lineCount = 1, lineChar = 1; /* 行數, 字數 */
char *prev; /* 記錄前一個token的型態 */
char string_buf[MAX_SIZE]; /* 字串buffer(30個字元+'\0') */

/* 計算行數, 字數 */
void count(void);
/* 輸出token */
void print(char *token);
%}

whitespace	[ \t]
newline		[\r\n]
letter		[A-Za-z]

/* number */
digit		[0-9]
digits		{digit}+
sign		[\+\-]
intnum		{sign}?(0|([1-9]{digit}*))
dotdigits	\.(0|({digit}*[1-9]))
exponent	[E|e]{sign}?{digits}
real		{intnum}({dotdigits}|{exponent}|{dotdigits}{exponent})
/* 0開頭, 結尾多個0, 小數點前後有缺 */
/* 03.0, 12.100, .1, 1. */
real_error	((0*|\.){real}0*)|({digit}*\.{digit}*)

id				(_|{letter})({letter}|{digit}|_)*
/* id前有其他符號, 數字 */
id_error		[^ ():;=+\-,\n\r_A-Za-z]{id}
string			\'([^\'\r\n]|\'\')*\'
/* 缺結尾的' */
string_error1	\'([^\'\r\n]|\'\')*
/* 缺結尾或中間有多的' */
string_error2	\'([^\'\r\n]|([^\'\r\n]\')|(\'[^\'\r\n]))*[^ \r\n;]
commentL		\(\*
commentR		\*\)
/* 註解內容 1.(無限制 2.沒有*) 3.沒有* 4.沒有) */
comment			{commentL}"("*([^*)]|([^*]")")|("*"[^)]?))*"*"*{commentR}
/* 有配對不到的右括號 */
comment_error1	{commentL}.*{commentR}.*{commentR}
/* 只有單邊括號 */
comment_error2	{commentL}|{commentR}
not_found		.
/*
comment_error3	{commentL}(.)*(("*"[^)\r\n])|([^*]")")|([^*\r\n][^)\r\n]))
comment_error4	(([^ (\r\n][^*\r\n])|("("[^*])|([^( \r\n]"*"))(.)*{commentR}
*/

/* Rules */
%%
and				{print("reserved"); count();}
array			{print("reserved"); count();}
asm				{print("reserved"); count();}
begin			{print("reserved"); count();}
break			{print("reserved"); count();}
case			{print("reserved"); count();}
const			{print("reserved"); count();}
constructor		{print("reserved"); count();}
continue		{print("reserved"); count();}
destructor		{print("reserved"); count();}
div				{print("reserved"); count();}
do				{print("reserved"); count();}
downto			{print("reserved"); count();}
else			{print("reserved"); count();}
end				{print("reserved"); count();}
false			{print("reserved"); count();}
file			{print("reserved"); count();}
float			{print("reserved"); count();}
for				{print("reserved"); count();}
function		{print("reserved"); count();}
goto			{print("reserved"); count();}
if				{print("reserved"); count();}
implementation	{print("reserved"); count();}
in				{print("reserved"); count();}
inline			{print("reserved"); count();}
integer			{print("reserved"); count();}
interface		{print("reserved"); count();}
label			{print("reserved"); count();}
mod				{print("reserved"); count();}
nil				{print("reserved"); count();}
not				{print("reserved"); count();}
object			{print("reserved"); count();}
of				{print("reserved"); count();}
on				{print("reserved"); count();}
operator		{print("reserved"); count();}
or				{print("reserved"); count();}
packed			{print("reserved"); count();}
procedure		{print("reserved"); count();}
program			{print("reserved"); count();}
read			{print("reserved"); count();}
record			{print("reserved"); count();}
repeat			{print("reserved"); count();}
set				{print("reserved"); count();}
shl				{print("reserved"); count();}
shr				{print("reserved"); count();}
string			{print("reserved"); count();}
then			{print("reserved"); count();}
to				{print("reserved"); count();}
true			{print("reserved"); count();}
type			{print("reserved"); count();}
unit			{print("reserved"); count();}
until			{print("reserved"); count();}
uses			{print("reserved"); count();}
var				{print("reserved"); count();}
while			{print("reserved"); count();}
with			{print("reserved"); count();}
write			{print("reserved"); count();}
xor				{print("reserved"); count();}

":="		{print("symbol"); count();}
"<="		{print("symbol"); count();}
">="		{print("symbol"); count();}
"<>"		{print("symbol"); count();}
"<<"		{print("symbol"); count();}
">>"		{print("symbol"); count();}
"<"			{print("symbol"); count();}
">"			{print("symbol"); count();}
"="			{print("symbol"); count();}
"*"			{print("symbol"); count();}
"/"			{print("symbol"); count();}
"%"			{print("symbol"); count();}
"&"			{print("symbol"); count();}
"|"			{print("symbol"); count();}
"~"			{print("symbol"); count();}
"!"			{print("symbol"); count();}
","			{print("symbol"); count();}
"^"			{print("symbol"); count();}
"."			{print("symbol"); count();}
";"			{print("symbol"); count();}
":"			{print("symbol"); count();}
"("			{print("symbol"); count();}
")"			{print("symbol"); count();}
"["			{print("symbol"); count();}
"]"			{print("symbol"); count();}
"+"/{whitespace}*({intnum}|{real})	{print("symbol"); count();}
"-"/{whitespace}*({intnum}|{real})	{print("symbol"); count();}

{id}				{print("ID"); count();}
{id_error}			{print("ID_error"); count();}
{real}/[^0-9]		{print("real"); count(); /* {real} but only if followed by [^0-9] */}
{real_error}		{print("real_error"); count();}
{intnum}/[^0-9]		{print("integer"); count();}
{string}			{print("string"); count();}
{string_error1}		{print("string_error"); count();}
{string_error2}		{print("string_error"); count();}
{comment}			{print("comment"); count();}
{comment_error1}	{print("comment_error"); count();}
{comment_error2}	{print("comment_error"); count();}

{whitespace}	{++lineChar;}
{newline}		{if(yytext[0]!='\r'){++lineCount;lineChar=1;prev=yytext;}/*'\r' --- Windows文件 */}

{not_found}		{print("undefined"); count();}

%%
/* User code */
int main(void) {
	yylex(); /* 字彙分析 */
	return 0;
}

/* 計算行數, 字數 */
void count(void) {
	int i;

	/* yyleng --- yytext長度 */
	for(i = 0; i < yyleng; ++i) {
		if(yytext[i] == '\n') { /* 換行 */
			++lineCount;
			lineChar = 1;
		}
		else
			++lineChar;
	}
}

/*
 * 列出每個token以及此token的型態(integer, real, ID, reserved word, string, symbol, comment), 
 * 此token所在的line no., 第一個字元所在的位置。
 *
 */
void print(char *token) {
	int i, j;

	if(token!="integer" && token!="real")
		prev = token; /* 記錄前一個token的型態 */

	/* 整數 */
	if(token == "integer") {
		/* 加減法運算 */
		if((prev=="integer" || prev=="real") && (yytext[0]=='+' || yytext[0]=='-')) {
			printf("Line: %d, 1st char: %d, \"%c\" is a \"symbol\".\n",
				lineCount, lineChar, yytext[0]);
			printf("Line: %d, 1st char: %d, \"%s\" is an \"integer\".\n",
				lineCount, lineChar+1, yytext+1);
		}
		/* 正負整數 */
		else {
			printf("Line: %d, 1st char: %d, \"%s\" is an \"integer\".\n",
				lineCount, lineChar, yytext);
		}
		prev = token;
	}
	/* 實數 */
	else if(token == "real") {
		/* 加減法運算 */
		if((prev=="integer" || prev=="real") && (yytext[0]=='+' || yytext[0]=='-')) {
			printf("Line: %d, 1st char: %d, \"%c\" is a \"symbol\".\n",
				lineCount, lineChar, yytext[0]);
			printf("Line: %d, 1st char: %d, \"%s\" is a \"real\".\n",
				lineCount, lineChar+1, yytext+1);
		}
		/* 正負實數 */
		else {
			printf("Line: %d, 1st char: %d, \"%s\" is a \"real\".\n",
				lineCount, lineChar, yytext);
		}
		prev = token;
	}
	else if(token == "real_error") {
		printf("Line: %d, 1st char: %d, \"%s\" is an invalid \"real\".\n",
				lineCount, lineChar, yytext);
	}
	/* 識別字 */
	else if(token == "ID") {
		/* ID最長30個字元 */
		if(yyleng < MAX_SIZE) {
			printf("Line: %d, 1st char: %d, \"%s\" is an \"ID\".\n",
				lineCount, lineChar, yytext);
			/*table---*/
		}
		/* ID字元過多 */
		else {
			printf("Line: %d, 1st char: %d, \"%s\" is an invalid \"ID\".\n",
				lineCount, lineChar, yytext);
		}
	}
	else if(token == "ID_error") {
		printf("Line: %d, 1st char: %d, \"%s\" is an invalid \"ID\".\n",
			lineCount, lineChar, yytext);
	}
	/* 保留字 */
	else if(token == "reserved") {
		printf("Line: %d, 1st char: %d, \"%s\" is a \"reserved word\".\n",
			lineCount, lineChar, yytext);
	}
	/* 字串 */
	else if(token == "string") {
		/* 字串最長30個字元 */
		memset(string_buf, 0, MAX_SIZE);
		for(i=1,j=0; i<yyleng-1 && j<MAX_SIZE-1; ++i) {
			if(yytext[i] != '\'' )
				string_buf[j++] = yytext[i];
			else {
				/* '''' 代表字串 ' */
				if(yytext[i+1] == '\'') {
					string_buf[j++] = yytext[++i]; /* 忽略一個 ' */
				}
			}
		}
		if(i == yyleng-1) {
			printf("Line: %d, 1st char: %d, \"%s\" is a \"string\".\n",
				lineCount, lineChar, string_buf);
		}
		/* 字串字元過多 */
		else {
			printf("Line: %d, 1st char: %d, \"%s\" is an invalid \"string\".\n",
				lineCount, lineChar, yytext);
		}
	}
	else if(token == "string_error") {
		printf("Line: %d, 1st char: %d, \"%s\" is an invalid \"string\".\n",
			lineCount, lineChar, yytext);
	}
	/* 符號 */
	else if(token == "symbol") {
		printf("Line: %d, 1st char: %d, \"%s\" is a \"symbol\".\n",
			lineCount, lineChar, yytext);
	}
	/* 註解 */
	else if(token == "comment") {
		printf("Line: %d, 1st char: %d, \"%s\" is a \"comment\".\n",
			lineCount, lineChar, yytext);
	}
	else if(token == "comment_error") {
		printf("Line: %d, 1st char: %d, \"%s\" is an invalid \"comment\".\n",
			lineCount, lineChar, yytext);
	}
	/* undefined */
	else {
		printf("Line: %d, 1st char: %d, \"%s\" is undefined.\n",
			lineCount, lineChar, yytext);
	}
}

