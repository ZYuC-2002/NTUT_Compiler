open Ast

let debug = ref false
let dummy_loc = Lexing.dummy_pos, Lexing.dummy_pos
exception Error of Ast.location * string

let error ?(loc=dummy_loc) f =
  Format.kasprintf (fun s -> raise (Error (loc, s))) ("@[" ^^ f ^^ "@]")

(* 建立作用域環境 *)
let build_env params =
  List.map (fun id -> 
    let var = { v_name = id.id; v_ofs = 0 } in
    (id.id, var)
  ) params

(* 檢查函數調用的合法性 *)
let check_fn_call env defined_fns curr_fn id args =
  let fn_name = id.id in
  if List.mem_assoc fn_name defined_fns then
    (List.assoc fn_name defined_fns, args)
  else if fn_name = curr_fn.fn_name then
    (curr_fn, args)
  else if List.mem fn_name ["len"; "list"; "range"] then
    let builtin_fn = { fn_name = fn_name; fn_params = [] } in
    (builtin_fn, args)
  else
    error ~loc:id.loc "undefined function %s" fn_name

(* 型別檢查表達式 *)
let rec check_expr env defined_fns curr_fn = function
  | Ecst c -> TEcst c
  | Eident id -> 
      if not (List.mem_assoc id.id env) then
        error ~loc:id.loc "unbound variable %s" id.id;
      TEvar (List.assoc id.id env)
  | Ebinop (op, e1, e2) -> 
      TEbinop (op, check_expr env defined_fns curr_fn e1, 
                   check_expr env defined_fns curr_fn e2)
  | Eunop (op, e) -> 
      TEunop (op, check_expr env defined_fns curr_fn e)
  | Ecall (id, args) ->
      let fn, checked_args = check_fn_call env defined_fns curr_fn id
        (List.map (check_expr env defined_fns curr_fn) args) in
      TEcall (fn, checked_args)
  | Elist el -> 
      TElist (List.map (check_expr env defined_fns curr_fn) el)
  | Eget (e1, e2) ->
      TEget (check_expr env defined_fns curr_fn e1,
             check_expr env defined_fns curr_fn e2)

(* 型別檢查語句 *)
let rec check_stmt env defined_fns curr_fn = function
  | Sblock sl -> 
      TSblock (List.map (check_stmt env defined_fns curr_fn) sl)
  | Sreturn e ->
      TSreturn (check_expr env defined_fns curr_fn e)
  | Sassign (id, e) ->
      if not (List.mem_assoc id.id env) then
        error ~loc:id.loc "unbound variable %s" id.id;
      TSassign (List.assoc id.id env, check_expr env defined_fns curr_fn e)
  | Sprint e ->
      TSprint (check_expr env defined_fns curr_fn e)
  | Sif (e, s1, s2) ->
      TSif (check_expr env defined_fns curr_fn e,
            check_stmt env defined_fns curr_fn s1,
            check_stmt env defined_fns curr_fn s2)
  | Sfor (id, e, s) ->
      let var = { v_name = id.id; v_ofs = 0 } in
      let new_env = (id.id, var) :: env in
      TSfor (var, check_expr env defined_fns curr_fn e,
             check_stmt new_env defined_fns curr_fn s)
  | Seval e ->
      TSeval (check_expr env defined_fns curr_fn e)
  | Sset (e1, e2, e3) ->
      TSset (check_expr env defined_fns curr_fn e1,
             check_expr env defined_fns curr_fn e2,
             check_expr env defined_fns curr_fn e3)

(* 型別檢查整個檔案 *)
let file ?(debug=false) (p: Ast.file) : Ast.tfile =
  let defs, main = p in
  (* 建立函數定義的映射 *)
  let defined_fns = List.map (fun (id, params, _) ->
    let fn = { fn_name = id.id; fn_params = List.map (fun p -> 
      { v_name = p.id; v_ofs = 0 }) params } in
    (id.id, fn)
  ) defs in
  
  (* 檢查每個函數定義 *)
  let check_def (id, params, body) =
    let fn = List.assoc id.id defined_fns in
    let env = build_env params in
    (fn, check_stmt env defined_fns fn body)
  in
  
  (* 檢查所有函數定義和主程式 *)
  let checked_defs = List.map check_def defs in
  let main_fn = { fn_name = "main"; fn_params = [] } in
  let checked_main = check_stmt [] defined_fns main_fn main in
  (checked_defs, checked_main)