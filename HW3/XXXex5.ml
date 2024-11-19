(* 定義自動機的類型 *)
type state = int
type transition = state * char * state
type autom = {
  states : state list;
  alphabet : char list;
  transitions : transition list;
  start_state : state;
  accept_states : state list;
}

(* 找到下一個狀態 *)
let find_next_state (transitions : transition list) (current_state : state) (input_char : char) : state option =
  let rec aux = function
    | [] -> None
    | (from_state, ch, to_state) :: rest ->
        if from_state = current_state && ch = input_char then
          Some to_state
        else 
          aux rest
  in
  aux transitions

(* 主要識別函數 *)
let recognize (a : autom) (input : string) : bool =
  let rec run current_state pos =
    let current_char = if pos < String.length input then input.[pos] else ' ' in
    if pos = String.length input then
      List.mem current_state a.accept_states
    else
      match find_next_state a.transitions current_state current_char with
      | Some next_state -> run next_state (pos + 1)
      | None -> false
  in
  run a.start_state 0

(* 自動機定義 - 修改後 *)
let a = {
  states = [0; 1; 2];
  alphabet = ['a'; 'b'];
  transitions = [
    (0, 'a', 1);  (* 從 0 接受 'a' 進入狀態 1 *)
    (1, 'b', 2);  (* 從 1 接受 'b' 進入狀態 2 *)
    (0, 'b', 2);  (* 從 0 接受 'b' 直接進入狀態 2 *)
    (2, 'a', 1);  (* 從 2 接受 'a' 回到狀態 1 *)
    (2, 'b', 2)   (* 從 2 接受 'b' 仍在狀態 2 *)
  ];
  start_state = 0;
  accept_states = [2];  (* 只有狀態 2 為接受狀態 *)
}

(* 測試 *)
let () = assert (recognize a "ab")               (* true: ends in state 2 *)
let () = assert (recognize a "babababab")         (* true: ends in state 2 *)
let () = assert (recognize a (String.make 1000 'b' ^ "ab")) (* true: ends in state 2 *)

let () = assert (not (recognize a ""))            (* false *)
let () = assert (not (recognize a "a"))           (* false *)
let () = assert (not (recognize a "b"))           (* false *)
let () = assert (not (recognize a "ba"))          (* false *)
let () = assert (not (recognize a "aba"))         (* false *)
let () = assert (not (recognize a "aa"))          (* false *)
let () = assert (not (recognize a "abababaaba"))  (* false *)
