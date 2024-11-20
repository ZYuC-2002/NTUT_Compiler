open Ast

exception Error of location * string

let error loc msg = raise (Error (loc, msg))

let new_var =
  let count = ref 0 in
  fun x ->
    incr count;
    { v_name = x; v_ofs = -8 * !count }

let rec expr env = function
  | Ecst c ->
      TEcst c
  | Eident { id = x; loc } as e ->
      begin match List.assoc_opt x env with
        | Some v -> TEvar v
        | None -> error loc ("unbound variable " ^ x)
      end
  | Ebinop (op, e1, e2) ->
      let e1 = expr env e1 in
      let e2 = expr env e2 in
      TEbinop (op, e1, e2)
  | Eunop (op, e1) ->
      let e1 = expr env e1 in
      TEunop (op, e1)
  | Ecall ({ id = "range"; loc }, [e1]) ->
      TErange (expr env e1)
  | Ecall ({ id = f; loc }, el) ->
      let tel = List.map (expr env) el in
      match List.assoc_opt f env with
      | Some _ -> error loc ("variable " ^ f ^ " is not a function")
      | None -> TEcall ({ fn_name = f; fn_params = [] }, tel)
  | Elist el ->
      TElist (List.map (expr env) el)
  | Eget (e1, e2) ->
      TEget (expr env e1, expr env e2)

let rec stmt env = function
  | Sif (e, s1, s2) ->
      let e = expr env e in
      let s1 = stmt env s1 in
      let s2 = stmt env s2 in
      TSif (e, s1, s2)
  | Sreturn e ->
      TSreturn (expr env e)
  | Sassign ({id = x; loc}, e) ->
      let te = expr env e in
      begin match List.assoc_opt x env with
        | Some v -> TSassign (v, te)
        | None -> error loc ("unbound variable " ^ x)
      end
  | Sprint e ->
      TSprint (expr env e)
  | Sblock bl ->
      TSblock (List.map (stmt env) bl)
  | Sfor ({id = x}, e, s) ->
      let v = new_var x in
      let env = (x, v) :: env in
      let e = expr env e in
      let s = stmt env s in
      TSfor (v, e, s)
  | Seval e ->
      TSeval (expr env e)
  | Sset (e1, e2, e3) ->
      TSset (expr env e1, expr env e2, expr env e3)

let def (f, xl, s) =
  let f = { fn_name = f.id; fn_params = [] } in
  let env = List.map (fun {id=x} -> (x, new_var x)) xl in
  let s = stmt env s in
  (f, s)

let file ?debug:_ (dl, s) =
  let s = stmt [] s in
  let dl = List.map def dl in
  dl