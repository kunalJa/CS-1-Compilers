/*
 *  The scanner definition for COOL.
 */

/*
 *  Stuff enclosed in %{ %} in the first section is copied verbatim to the
 *  output, so headers and global definitions are placed here to be visible
 * to the code in the file.  Don't remove anything that was here initially
 */

%{
/* ---------------------Declarations----------------------- */
#include <cool-parse.h>
#include <stringtab.h>
#include <utilities.h>

/* The compiler assumes these identifiers. */
#define yylval cool_yylval
#define yylex  cool_yylex

/* Max size of string constants */
#define MAX_STR_CONST 1025
#define YY_NO_UNPUT   /* keep g++ happy */

extern FILE *fin; /* we read from this file */

/* define YY_INPUT so we read from the FILE fin:
 * This change makes it possible to use this scanner in
 * the Cool compiler.
 */
#undef YY_INPUT
#define YY_INPUT(buf,result,max_size) \
	if ( (result = fread( (char*)buf, sizeof(char), max_size, fin)) < 0) \
		YY_FATAL_ERROR( "read() in flex scanner failed");

char string_buf[MAX_STR_CONST]; /* to assemble string constants */
char *string_buf_ptr;

extern int curr_lineno;
extern int verbose_flag;

extern YYSTYPE cool_yylval;

/*
 *  Add Your own declarations here
 */

%}
/* ---------------------Definitions------------------------ */

SINGLECHAR  [+\-*/<@~.(){}=:;,]
INTEGERS     [0-9]+

LE         <=
ASSIGN      <-
DARROW      =>

WSPACE      [ \n\f\r\t\v]

%x str

%%
/* ----------------------Rules----------------------------- */

 /*
  *  Nested comments
  */

\" {
  string_buf_ptr = string_buf;
  BEGIN(str);
}

<str>{
  \" {
    BEGIN(INITIAL);
    *string_buf_ptr = '\0';
    cool_yylval.symbol = stringtable.add_string(string_buf);
    return STR_CONST;
  }

  \n {
    /* ERROR */
  }

  \0 {
    /* ERROR */
  }

  <<EOF>> {
    /* ERROR */
  }

  \\n {
    *string_buf_ptr++ = '\n';
  }

  \\t {
    *string_buf_ptr++ = '\t';
  }

  \\b {
    *string_buf_ptr++ = '\b';
  }

  \\f {
    *string_buf_ptr++ = '\f';
  }

  \\(.|\n) {
    *string_buf_ptr++ = yytext[1];
  }

  [^\\\n\"]+ {
    char *yptr = yytext;
    while (*yptr)
      *string_buf_ptr++ = *yptr++;
    }
  }
}

{INTEGERS} {
  cool_yylex.symbol = inttable.add_string(yytext);
  return INT_CONST;
}

/* Single character symbols, for example: "+" */
{SINGLECHAR} {
  return (int) yylval[0];
}

/* Assignment, for example: "ID <- expr" */
{ASSIGN} {
  return ASSIGN;
}

/* Option in a case, for example: "case expr of [[ID:TYPE=>expr;]]+ esac" */
{DARROW} {
  return DARROW;
}

/* Less than or equal to, for example: "expr <= expr" */
{LE} {
  return LE;
}

/* The "true" keyword. The first letter must be lowercase */
t(?i:rue) {
  cool_yylex.boolean = true;
  return BOOL_CONST;
}

/* The "false" keyword. The first letter must be lowercase */
f(?i:alse) {
  cool_yylex.boolean = false;
  return BOOL_CONST;
}

/* Keywords, all of which are case-insensitive */
(?i:CLASS) {
  return CLASS;
}

(?i:ELSE) {
  return ELSE;
}

(?i:FI) {
  return FI;
}

(?i:IF) {
  return IF;
}

(?i:IN) {
  return IN;
}

(?i:INHERITS) {
  return INHERITS;
}

(?i:LET) {
  return LET;
}

(?i:LOOP) {
  return LOOP;
}

(?i:POOL) {
  return POOL;
}

(?i:THEN) {
  return THEN;
}

(?i:WHILE) {
  return WHILE;
}

(?i:CASE) {
  return CASE;
}

(?i:ESAC) {
  return ESAC;
}

(?i:OF) {
  return OF;
}

(?i:NEW) {
  return NEW;
}

(?i:ISVOID) {
  return ISVOID;
}

(?i:NOT) {
  return NOT;
}

/* White space characters in the Cool language include " ", "\n", "\f", "\r", "\t", and "\v" */
{WSPACE}+ {
  /* Do nothing */
}

 /*
  *  String constants (C syntax)
  *  Escape sequence \c is accepted for all characters c. Except for
  *  \n \t \b \f, the result is c.
  *
  */


%%
/* -------------------User Subroutines--------------------- */
