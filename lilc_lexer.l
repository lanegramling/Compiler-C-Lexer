%{
#include <string>
#include <limits.h>

/* Provide custom yyFlexScanner subclass and specify the interface */
#include "lilc_scanner.hpp"
#undef  YY_DECL
#define YY_DECL int LILC::LilC_Scanner::yylex( LILC::LilC_Parser::semantic_type * const lval)

/* typedef to make the returns for the tokens shorter */
using TokenTag = LILC::LilC_Parser::token;

/*
Implementations of the non-nullary tokens. These classes are declared
in symbols.hpp and are subclasses of the main Symbol class representing
terminals that contain some value (e.g., a token that contains an integer
value as opposed to a curly brace which always represents exactly 1
literal character string)
 */
namespace LILC{
	IDToken::IDToken(size_t line, size_t col, std::string value)
	: SynSymbol(line,col,TokenTag::ID)
	{
		this->_value = value;
	}
	IntLitToken::IntLitToken(size_t line, size_t col, int value)
	: SynSymbol(line,col,TokenTag::INTLITERAL)
	{
		this->_value = value;
	}
	StringLitToken::StringLitToken(size_t line, size_t col, std::string value)
	: SynSymbol(line,col,TokenTag::STRINGLITERAL)
	{
		this->_value = value;
	}
} // End namespace



/* define yyterminate as this instead of NULL */
#define yyterminate() return( TokenTag::END )

/* Exclude unistd.h for Visual Studio compatability. */
#define YY_NO_UNISTD_H

%}

%option debug
%option nodefault
%option yyclass="LILC::LilC_Scanner"
%option noyywrap
%option c++

DIGIT [0-9]
WHITESPACE   [ \t]
ID [a-zA-Z_][a-zA-Z0-9_]*
STRINGCHAR (\\[nt'"?\\]|[^\n"\\])

%%
%{          /** Code executed at the beginning of yylex **/
            yylval = lval;
%}

{DIGIT}+	{
		//Note: the following computation of the integer value
		// does NOT check for overflow. This must be changed

		double d = std::stod(yytext);
		if (d > INT_MAX) {
			std::string msg = "integer literal too large";
			warn(lineNum, charNum, msg);
			yylval->symbolValue = new IntLitToken(lineNum, charNum, INT_MAX);
			return TokenTag::INTLITERAL;
		}

		int intVal = atoi(yytext);
		charNum += yyleng;
        yylval->symbolValue = new IntLitToken(lineNum, charNum, intVal);
                return TokenTag::INTLITERAL;
		}

\n          {
		// Update line number
		lineNum++;
		charNum = 1;
            }

bool {
	charNum += yyleng;
	return TokenTag::BOOL;
}

int {
	charNum += yyleng;
	return TokenTag::INT;
}

void {
	charNum += yyleng;
	return TokenTag::VOID;
}

true {
	charNum += yyleng;
	return TokenTag::TRUE;
}

false {
	charNum += yyleng;
	return TokenTag::FALSE;
}

struct {
	charNum += yyleng;
	return TokenTag::STRUCT;
}

cin {
	charNum += yyleng;
	return TokenTag::INPUT;
}

cout {
	charNum += yyleng;
	return TokenTag::OUTPUT;
}

if {
	charNum += yyleng;
	return TokenTag::IF;
}

else {
	charNum += yyleng;
	return TokenTag::ELSE;
}

while {
	charNum += yyleng;
	return TokenTag::WHILE;
}

return	{
	charNum += yyleng;
	return TokenTag::RETURN;
}

"{" {
	yylval->symbolValue = new NullaryToken(lineNum, charNum, TokenTag::LCURLY);
 charNum += yyleng;
 return TokenTag::LCURLY;
}
"}" {
	yylval->symbolValue = new NullaryToken(lineNum, charNum, TokenTag::RCURLY);
 charNum += yyleng;
 return TokenTag::RCURLY;
}
"(" {
	yylval->symbolValue = new NullaryToken(lineNum, charNum, TokenTag::LPAREN);
 charNum += yyleng;
 return TokenTag::LPAREN;
}
")" {
	yylval->symbolValue = new NullaryToken(lineNum, charNum, TokenTag::RPAREN);
 charNum += yyleng;
 return TokenTag::RPAREN;
}
";" {
	yylval->symbolValue = new NullaryToken(lineNum, charNum, TokenTag::SEMICOLON);
 charNum += yyleng;
 return TokenTag::SEMICOLON;
}
"," {
	yylval->symbolValue = new NullaryToken(lineNum, charNum, TokenTag::COMMA);
 charNum += yyleng;
 return TokenTag::COMMA;
}
"." {
	yylval->symbolValue = new NullaryToken(lineNum, charNum, TokenTag::DOT);
 charNum += yyleng;
 return TokenTag::DOT;
}
"++" {
	yylval->symbolValue = new NullaryToken(lineNum, charNum, TokenTag::PLUSPLUS);
 charNum += yyleng;
 return TokenTag::PLUSPLUS;
}
"--" {
	yylval->symbolValue = new NullaryToken(lineNum, charNum, TokenTag::MINUSMINUS);
 charNum += yyleng;
 return TokenTag::MINUSMINUS;
}
"+" {
	yylval->symbolValue = new NullaryToken(lineNum, charNum, TokenTag::PLUS);
 charNum += yyleng;
 return TokenTag::PLUS;
}
"-" {
	yylval->symbolValue = new NullaryToken(lineNum, charNum, TokenTag::MINUS);
 charNum += yyleng;
 return TokenTag::MINUS;
}
"*" {
	yylval->symbolValue = new NullaryToken(lineNum, charNum, TokenTag::TIMES);
 charNum += yyleng;
 return TokenTag::TIMES;
}
"/" {
	yylval->symbolValue = new NullaryToken(lineNum, charNum, TokenTag::DIVIDE);
 charNum += yyleng;
 return TokenTag::DIVIDE;
}
"!" {
	yylval->symbolValue = new NullaryToken(lineNum, charNum, TokenTag::NOT);
 charNum += yyleng;
 return TokenTag::NOT;
}
"&&" {
	yylval->symbolValue = new NullaryToken(lineNum, charNum, TokenTag::AND);
 charNum += yyleng;
 return TokenTag::AND;
}
"||" {
	yylval->symbolValue = new NullaryToken(lineNum, charNum, TokenTag::OR);
 charNum += yyleng;
 return TokenTag::OR;
}
"==" {
	yylval->symbolValue = new NullaryToken(lineNum, charNum, TokenTag::EQUALS);
 charNum += yyleng;
 return TokenTag::EQUALS;
}
"!=" {
	yylval->symbolValue = new NullaryToken(lineNum, charNum, TokenTag::NOTEQUALS);
 charNum += yyleng;
 return TokenTag::NOTEQUALS;
}
"<" {
	yylval->symbolValue = new NullaryToken(lineNum, charNum, TokenTag::LESS);
 charNum += yyleng;
 return TokenTag::LESS;
}
">" {
	yylval->symbolValue = new NullaryToken(lineNum, charNum, TokenTag::GREATER);
 charNum += yyleng;
 return TokenTag::GREATER;
}
"<=" {
	yylval->symbolValue = new NullaryToken(lineNum, charNum, TokenTag::LESSEQ);
 charNum += yyleng;
 return TokenTag::LESSEQ;
}
">=" {
	yylval->symbolValue = new NullaryToken(lineNum, charNum, TokenTag::GREATEREQ);
 charNum += yyleng;
 return TokenTag::GREATEREQ;
}
"=" {
	yylval->symbolValue = new NullaryToken(lineNum, charNum, TokenTag::ASSIGN);
	charNum += yyleng;
  return TokenTag::ASSIGN;
}
">>"	{
	yylval->symbolValue = new NullaryToken(lineNum, charNum, TokenTag::READ);
	charNum += yyleng;
	return TokenTag::READ;
}

"<<"	{
	yylval->symbolValue = new NullaryToken(lineNum, charNum, TokenTag::WRITE);
	charNum += yyleng;
	return TokenTag::WRITE;
}

\"{STRINGCHAR}*\"	{
	charNum += yyleng;
	yylval->symbolValue = new StringLitToken(lineNum, charNum, yytext);
	return TokenTag::STRINGLITERAL;
}


{ID}	{
	charNum += yyleng;
	yylval->symbolValue = new IDToken(lineNum, charNum, yytext);
	return TokenTag::ID;
}

{WHITESPACE}+	{
		charNum += yyleng;
}

\"[^"\n]*	{
	// Handle unterminated string literals
	std::string msg = "unterminated string literal ignored";
	charNum += yyleng;
	error(lineNum, charNum, msg);
}

\".*\"	{
	// Handle errors for unmatched (invalid) strings
	std::string msg = "unterminated string literal with bad escaped character ignored";
	charNum += yyleng;
	error(lineNum, charNum, msg);
}




.   {
			std::string msg = "Ignoring illegal character: ";
			msg += yytext;
			charNum += yyleng;
			error(lineNum, charNum, msg);
    }
%%
