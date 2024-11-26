
open Format
open X86_64
open Ast

let debug = ref false

(* let file ?debug:(b=false) (p: Ast.tfile) : X86_64.program =
  debug := b;
  { text = globl "main" ++ label "main" ++ ret;   (* TODO *)
    data = nop; }                                (* TODO *)
*)

let compile_expr = function
  | TEcst (Cint i) -> movq (imm (Int64.to_int i)) (reg rax)
  | TEvar v -> movq (ind ~ofs:v.v_ofs rbp) (reg rax)
  | _ -> failwith "expression not supported"

let rec compile_stmt = function
  | TSblock stmts -> List.fold_left (++) nop (List.map compile_stmt stmts)
  | TSassign (v, e) -> compile_expr e ++ movq (reg rax) (ind ~ofs:v.v_ofs rbp)
  | TSprint e -> compile_expr e ++ call "print_int"
  | TSreturn e -> compile_expr e ++ ret
  | TSset (e1, e2, e3) -> compile_expr e1 ++ compile_expr e2 ++ compile_expr e3
  | _ -> failwith "statement not supported"

let compile_def (fn, stmt) =
  label fn.fn_name ++
  compile_stmt stmt

let file ?(debug_flag=false) (p: Ast.tfile) : X86_64.program =
  debug := debug_flag;
  let text = List.fold_left (++) nop (List.map compile_def p) in
  { text = globl "main" ++ label "main" ++ text;
    data = nop }