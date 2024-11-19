(* Lexical analyser for mini-Turtle *)

{
  open Lexing
  open Parser

  (* raise exception to report a lexical error *)
  exception Lexing_error of string
}

rule token = parse
  | [' ' '\t' '\r' '\n'] { token lexbuf }
  | "//" [^ '\n']* '\n' { token lexbuf }
  | "(*" [^ '*']* "*)" { token lexbuf }
  | eof { EOF }
  | "forward" { FORWARD }
  | ['0'-'9']+ as lxm { INT (int_of_string lxm) }
  | '+' { PLUS }
  | '-' { MINUS }
  | '*' { TIMES }
  | '/' { DIV }
  | "penup" { PENUP }
  | "pendown" { PENDOWN }
  | "turnleft" { TURNLEFT }
  | "turnright" { TURNRIGHT }
  | "color" { COLOR }
  | "black" { BLACK }
  | "white" { WHITE }
  | "red" { RED }
  | "green" { GREEN }
  | "blue" { BLUE }
  | "if" { IF }
  | "else" { ELSE }
  | "repeat" { REPEAT }
  | '{' { LBRACE }
  | '}' { RBRACE }
  | "def" { DEF }
  | ['a'-'z' 'A'-'Z' '_']['a'-'z' 'A'-'Z' '0'-'9' '_']* as lxm { IDENT lxm }
  | '(' { LPAREN }
  | ')' { RPAREN }
  | ',' { COMMA }
  | _ { raise (Lexing_error "Unexpected character") }