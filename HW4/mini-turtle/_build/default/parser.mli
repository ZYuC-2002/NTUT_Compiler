
(* The type of tokens. *)

type token = 
  | WHITE
  | TURNRIGHT
  | TURNLEFT
  | TIMES
  | RPAREN
  | REPEAT
  | RED
  | RBRACE
  | PLUS
  | PENUP
  | PENDOWN
  | MINUS
  | LPAREN
  | LBRACE
  | INT of (int)
  | IF
  | IDENT of (string)
  | GREEN
  | FORWARD
  | EOF
  | ELSE
  | DIV
  | DEF
  | COMMA
  | COLOR
  | BLUE
  | BLACK

(* This exception is raised by the monolithic API functions. *)

exception Error

(* The monolithic API. *)

val prog: (Lexing.lexbuf -> token) -> Lexing.lexbuf -> (Ast.program)
