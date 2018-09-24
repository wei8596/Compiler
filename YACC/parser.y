/* Definition */
%{
#include <stdio.h>
#include <string.h>

#define YYERROR_VERBOSE 1 //使yyerror()產生更詳細的訊息
/* printf() color */
#define NONE "\033[m"
#define LIGHT_RED "\033[1;31m"
#define L 200 //陣列最大長度

void replace_str(char *str, char *token, char *find); //更改輸出格式
int yylex(void);
void yyerror(const char *str); //syntax error時自動呼叫

/* 使用外部Lex宣告變數 */
extern unsigned int lineCount, lineChar;
extern char *current;
%}

/* 利用%union定義token的type及yylval的值 */
%union{
int ival;
double dval;
char *str;
};

/* terminal */
%token <str> PROGRAM VAR BEGIN1 END INTEGER REALTYPE FLOAT STRING ARRAY OF IF THEN DIV READ WRITE FOR DO TO
%token <str> DOTDOT
%token <str> ID
%token <str> ASSIGNOP COMOP
%token <dval> REAL
%token <ival> INT

/* 優先序的定義 */
%left  COMOP //Comparison operators
%left  '+' '-'
%left  '*' '/' //比+-還要高一級

%nonassoc UPLUS
%nonassoc UMINUS //負號(最高優先)

%start prog  //指定起始規則

/* Grammars -- 依據 表一:A Simplified Pascal Grammar (基本上大寫為terminal)*/
%%
/* error可以match任何數量的token, 當符合該錯誤文法時, 可以使用內建的yyclearin,
 * 清除stack中所有目前已讀到的token, 做recovery
 */

prog:PROGRAM prog_name ';' VAR dec_list ';' BEGIN1 stmt_list ';' END '.'
	| PROGRAM prog_name ';' VAR dec_list ';' BEGIN1 stmt_list error END '.'{yyclearin;}
	| PROGRAM error ';' VAR dec_list ';' BEGIN1 stmt_list ';' END '.'{yyclearin;}
	| PROGRAM prog_name ';' VAR dec_list ';' BEGIN1 stmt_list ';' END error{yyclearin;}
	| error{yyclearin;}
;
prog_name:ID
;
dec_list:dec
		| dec_list ';' dec
;
dec:id_list ':' type
	| id_list error type{yyclearin;}
	| error ':' type{yyclearin;}
	| id_list ':' error{yyclearin;}
;
type:standtype
	| arraytype
;
standtype:INTEGER
		| REALTYPE
		| FLOAT
		| STRING
;
arraytype:ARRAY '[' INT DOTDOT INT ']' OF standtype
		| ARRAY '[' INT DOTDOT INT ']' error standtype{yyclearin;}
		| ARRAY '[' INT error INT ']' OF standtype{yyclearin;}
		| error '[' INT DOTDOT INT ']' OF standtype{yyclearin;}
;
id_list:ID
		| id_list ',' ID
		| id_list error ID{yyclearin;}
;
stmt_list:stmt
		| stmt_list ';' stmt
		| stmt_list error stmt{yyclearin;}
;
stmt:assign
	| read
	| write
	| for
	| ifstmt
;
assign:varid ASSIGNOP simpexp
	| varid error simpexp{yyclearin;}
;
ifstmt:IF '(' exp ')' THEN body
	| IF error exp ')' THEN body{yyclearin;}
;
exp:simpexp
	| exp relop simpexp
;
relop:COMOP
;
simpexp:term
		| simpexp '+' term
		| simpexp '-' term
;
term:factor
	| term '*' factor
	| term '/' factor
;
factor:varid
	| '-' factor %prec UMINUS
	| '+' factor %prec UPLUS
	| INT
	| REAL
	| '(' simpexp ')'
;
read:READ '(' id_list ')'
	| READ '(' error ')'{yyclearin;}
;
write:WRITE '(' id_list ')'
	| WRITE '(' error ')'{yyclearin;}
;
for:FOR index_exp DO body
	| FOR error DO body{yyclearin;}
;
index_exp:varid ASSIGNOP simpexp TO exp
		| varid error simpexp TO exp{yyclearin;}
;
varid:ID
	| ID '[' simpexp ']'
;
body:stmt
	| BEGIN1 stmt_list ';' END
	| error stmt_list ';' END{yyclearin;}
	| BEGIN1 stmt_list ';' error{yyclearin;}
;

%%
/* User code */
int main(void){
	yyparse(); //YACC透過yyparse()呼叫yylex()，並開始做parsing
	return 0;
}

/* 更改輸出格式 */
void replace_str(char *str, char *token, char *find){
	char temp[L], *p;

	/* strstr(str, find) - 從字串str中找尋字串find */
	if(p = strstr(str, find)){
		strncpy(temp, str, p-str);
		temp[p-str] = '\0';
		if(strcmp(find, "ASSIGNOP") == 0)
			strcat(temp, "':='");
		else if(strcmp(find, ", unexpected") == 0)
			strcat(temp, " at");
		else if(strcmp(find, ", expecting") == 0)
			strcat(temp, ".\nExpect");
		else if(strcmp(find, "$undefined") == 0)
			strcat(temp, token);
		else if(strcmp(find, "':' or ','") == 0)
			strcat(temp, "':'");
		else if(strcmp(find, "\nExpect") == 0){
			int i, quote = 0;
			strcat(temp, "\nExpect");
			for(i = 7; i < strlen(p); ++i){
				if(p[i] == '\''){
					quote = 1;
					--i;
					strcat(temp, p+i);
					break;
				}
			}
			if(!quote){
				strcat(temp, p+7);
			}
			strcat(temp, " not '");
			strcat(temp, token);
			strcat(temp, "'");
			strcpy(str, temp);
			return;
		}
		else if(strcmp(find, "at END") == 0){
			strcat(temp, "at '");
			strcat(temp, token);
			strcat(temp, "'");
		}
		strcat(temp, p+strlen(find));
		strcpy(str, temp);
	}
}

/* syntax error時自動呼叫 */
void yyerror(const char *str){
	char new_str[L];
	int place = lineChar - strlen(current); //錯誤token位置

	/* 更改輸出格式 */
	strcpy(new_str, str);
	replace_str(new_str, current, "ASSIGNOP");
	replace_str(new_str, current, ", unexpected");
	replace_str(new_str, current, ", expecting");
	replace_str(new_str, current, "$undefined");
	replace_str(new_str, current, "':' or ','");
	replace_str(new_str, current, "\nExpect");
	replace_str(new_str, current, "at END");
	/* 印出錯誤訊息 */
	printf(LIGHT_RED"Line %d, 1st char: %d, %s\n"NONE,
				lineCount, place, new_str);
}

