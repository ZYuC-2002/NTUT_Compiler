open Format
open X86_64
open Ast

let debug = ref false

(* Generate unique labels *)
let new_label =
  let count = ref 0 in
  fun prefix ->
    incr count;
    prefix ^ "_" ^ string_of_int !count

(* Compile an expression *)
let rec expr (e: texpr) : text =
  match e with
  | TEcst (Cstring s) ->
      let label = new_label "str" in
      movq (ilab label) (reg rax)  (* 字串處理先簡化為返回0 *)
  | TEcst (Cint n) ->
      movq (imm (Int64.to_int n)) (reg rax)
  | TEcst (Cbool true) ->
      movq (imm 1) (reg rax)
  | TEcst (Cbool false) ->
      movq (imm 0) (reg rax)
  | TEcst Cnone ->
      movq (imm 0) (reg rax)
  | _ -> 
      nop  (* Other expressions to be implemented *)

(* Print function implementation *)
let print_function = 
  label "print_int" ++
  pushq (reg rbp) ++
  movq (reg rsp) (reg rbp) ++
  pushq (reg rdi) ++
  movq (reg rax) (reg rsi) ++
  movq (ilab "format_int") (reg rdi) ++
  movq (imm 0) (reg rax) ++
  call "printf" ++
  popq rdi ++
  popq rbp ++
  ret

(* Compile a statement *)
let rec stmt = function
  | TSprint e ->
      expr e ++
      call "print_int"  (* Basic print implementation *)
  | TSblock sl ->
      List.fold_left (fun code s -> code ++ stmt s) nop sl
  | _ -> 
      nop  (* Other statements to be implemented *)

(* Main compiler function *)
let file ?debug:(b=false) (p: Ast.tfile) : X86_64.program =
  debug := b;
  let code = List.fold_left 
    (fun code (fn, body) ->
      code ++
      label fn.fn_name ++
      stmt body)
    nop
    p
  in
  { text = 
      globl "main" ++
      label "main" ++
      code ++
      print_function ++
      ret;
    data = 
      label "format_int" ++ 
      string "%d\n" ++
      label "format_str" ++
      string "%s\n"
  }