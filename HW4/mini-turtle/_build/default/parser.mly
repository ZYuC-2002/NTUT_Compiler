/* Parsing for mini-Turtle */

%{
  open Ast
  open Turtle
%}

/* Declaration of tokens */

%token EOF
%token FORWARD
%token <int> INT
%token PLUS MINUS TIMES DIV
%token PENUP PENDOWN TURNLEFT TURNRIGHT COLOR
%token BLACK WHITE RED GREEN BLUE
%token IF ELSE REPEAT LBRACE RBRACE
%token DEF LPAREN RPAREN COMMA
%token <string> IDENT

/* Priorities and associativity of tokens */
%left PLUS MINUS
%left TIMES DIV
%nonassoc IFX
%nonassoc ELSE

/* Axiom of the grammar */
%start prog

/* Type of values returned by the parser */
%type <Ast.program> prog

%%

/* Production rules of the grammar */

prog:
  def_list stmt_list EOF
    { { defs = $1; main = Sblock $2 } }
;

def_list:
  | /* empty */
    { [] }
  | def_list def
    { $1 @ [$2] }
;

def:
  | DEF IDENT LPAREN formals RPAREN stmt
    { { name = $2; formals = $4; body = $6 } }
  | DEF IDENT LPAREN formals RPAREN expr
    { { name = $2; formals = $4; body = Sforward $6 } }
;

formals:
  | /* empty */
    { [] }
  | IDENT
    { [$1] }
  | formals COMMA IDENT
    { $1 @ [$3] }
;

stmt_list:
  | stmt
    { [$1] }
  | stmt_list stmt
    { $1 @ [$2] }
;

stmt:
  | FORWARD expr
    { Sforward $2 }
  | PENUP
    { Spenup }
  | PENDOWN
    { Spendown }
  | TURNLEFT expr
    { Sturn $2 }
  | TURNRIGHT expr
    { Sturn (Ebinop (Sub, Econst 360, $2)) }
  | COLOR color
    { Scolor $2 }
  | IF expr LBRACE stmt_list RBRACE
    { Sif ($2, Sblock $4, Sblock []) }
  | IF expr LBRACE stmt_list RBRACE ELSE LBRACE stmt_list RBRACE
    { Sif ($2, Sblock $4, Sblock $8) }
  | IF expr LBRACE stmt_list RBRACE ELSE stmt
    { Sif ($2, Sblock $4, $7) }
  | REPEAT expr LBRACE stmt_list RBRACE
    { Srepeat ($2, Sblock $4) }
  | LBRACE stmt_list RBRACE
    { Sblock $2 }
  | IDENT LPAREN actuals RPAREN
    { Scall ($1, $3) }
;

actuals:
  | /* empty */
    { [] }
  | expr
    { [$1] }
  | actuals COMMA expr
    { $1 @ [$3] }
;

color:
  | BLACK
    { Turtle.black }
  | WHITE
    { Turtle.white }
  | RED
    { Turtle.red }
  | GREEN
    { Turtle.green }
  | BLUE
    { Turtle.blue }
;

expr:
  | INT
    { Econst $1 }
  | IDENT
    { Evar $1 }
  | expr PLUS expr
    { Ebinop (Add, $1, $3) }
  | expr MINUS expr
    { Ebinop (Sub, $1, $3) }
  | expr TIMES expr
    { Ebinop (Mul, $1, $3) }
  | expr DIV expr
    { Ebinop (Div, $1, $3) }
  | LPAREN expr RPAREN
    { $2 }
  | MINUS expr
    { Ebinop (Sub, Econst 0, $2) }
;