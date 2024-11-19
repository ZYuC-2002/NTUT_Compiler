(* Step 1: Define the Regular Expression Type *)
type regex =
  | Empty
  | Epsilon
  | Character of char * int
  | Concat of regex * regex
  | Union of regex * regex
  | Star of regex

(* Step 2: Define NFA Types *)
type nfa_state = {
  id: int;
  mutable transitions: (char * nfa_state list) list;  (* character -> list of states *)
  mutable is_accepting: bool;
}

type nfa = {
  start_state: nfa_state;
  accept_states: nfa_state list;
}

(* Step 3: NFA Construction from Regular Expressions *)
let rec nfa_of_regex (regex: regex) : nfa =
  match regex with
  | Empty -> failwith "Cannot create NFA from Empty"
  | Epsilon ->
      let start = { id = 0; transitions = []; is_accepting = true } in
      { start_state = start; accept_states = [start] }
  | Character (c, _) ->
      let start = { id = 0; transitions = []; is_accepting = false } in
      let accept = { id = 1; transitions = []; is_accepting = true } in
      start.transitions <- [(c, [accept])];
      { start_state = start; accept_states = [accept] }
  | Concat (r1, r2) ->
      let nfa1 = nfa_of_regex r1 in
      let nfa2 = nfa_of_regex r2 in
      List.iter (fun state ->
        state.is_accepting <- false;
        (* Use '\000' or another character to represent epsilon transition *)
        state.transitions <- state.transitions @ [('\000', [nfa2.start_state])]
      ) nfa1.accept_states;
      { start_state = nfa1.start_state; accept_states = nfa2.accept_states }
  | Union (r1, r2) ->
      let nfa1 = nfa_of_regex r1 in
      let nfa2 = nfa_of_regex r2 in
      let start = { id = 2; transitions = []; is_accepting = false } in
      start.transitions <- [('\000', [nfa1.start_state; nfa2.start_state])];
      { start_state = start; accept_states = nfa1.accept_states @ nfa2.accept_states }
  | Star r ->
      let nfa = nfa_of_regex r in
      let start = { id = 2; transitions = []; is_accepting = true } in
      start.transitions <- [('\000', [nfa.start_state; start])];
      List.iter (fun state ->
        state.is_accepting <- false;
        state.transitions <- state.transitions @ [('\000', [start])]
      ) nfa.accept_states;
      { start_state = start; accept_states = nfa.accept_states }

(* Step 4: Define DFA Types *)
type dfa_state = {
  id: int;
  transitions: (char * dfa_state) list;
  is_accepting: bool;
}

(* Step 5: Convert NFA to DFA (Simplified Example) *)
let convert_nfa_to_dfa (nfa: nfa) : dfa_state =
  (* This function needs to implement the subset construction. Placeholder for now. *)
  failwith "NFA to DFA conversion not implemented"

(* Step 6: Make DFA from Regular Expression *)
let make_dfa (regex: regex) : dfa_state =
  let nfa = nfa_of_regex regex in
  convert_nfa_to_dfa nfa

(* Step 7: Define Buffer and Lexer Functions *)
type buffer = {
  text: string;
  mutable current: int;
  mutable last: int;
}

exception End_of_file
exception Lexical_error of string

let next_char b =
  if b.current = String.length b.text then raise End_of_file;
  let c = b.text.[b.current] in
  b.current <- b.current + 1;
  c

(* Step 8: Define Lexer State Functions for a*b *)
let rec state0 b =
  b.last <- b.current;  (* Accepting state for ε *)
  try
    let c = next_char b in
    match c with
    | 'a' -> state1 b  (* Transition to state1 on 'a' *)
    | 'b' -> raise (Lexical_error "Invalid character after a")  (* Invalid transition *)
    | _ -> raise (Lexical_error "Invalid character")
  with End_of_file -> ()

and state1 b =
  b.last <- b.current;  (* Accepting state for 'a' *)
  try
    let c = next_char b in
    match c with
    | 'a' -> state1 b  (* Stay in state1 on 'a' *)
    | 'b' -> state2 b  (* Transition to state2 on 'b' *)
    | _ -> raise (Lexical_error "Invalid character")
  with End_of_file -> ()

and state2 b =
  b.last <- b.current;  (* Accepting state for 'b' *)
  try
    let c = next_char b in
    match c with
    | 'a' -> state1 b  (* Transition to state1 on 'a' *)
    | _ -> raise (Lexical_error "Invalid character")
  with End_of_file -> ()

let start = state0  (* Set the start state for the lexer *)

(* Step 9: Generate the OCaml Code for the Lexer *)
let generate filename autom =
  let oc = open_out filename in
  let print_line line = output_string oc (line ^ "\n") in
  print_line "type buffer = { text: string; mutable current: int; mutable last: int }";
  print_line "exception End_of_file";
  print_line "exception Lexical_error of string";
  print_line "let next_char b = ...";  (* Include the definition here *)
  print_line "let rec state0 b = ...";  (* Implement based on the automaton *)
  print_line "and state1 b = ...";      (* Continue for other states *)
  print_line "and state2 b = ...";
  print_line "let start = state0";  (* Replace with the initial state *)
  close_out oc

(* Step 10: Test the Lexer *)
let () =
  let r3 = Concat (Star (Character ('a', 1)), Character ('b', 1)) in
  let a = make_dfa r3 in
  generate "a.ml" a;  (* Generates the lexer code for a*b *)

  (* You can then compile and run the lexer with your test cases. *)
