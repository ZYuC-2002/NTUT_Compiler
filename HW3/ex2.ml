(* Define the type for indexed characters *)
type ichar = char * int

(* Define the type for regular expressions *)
type regexp =
  | Empty                 (* Empty language *)
  | Epsilon               (* Empty string *)
  | Character of ichar     (* A character with an index *)
  | Concat of regexp * regexp  (* Concatenation of two regexps *)
  | Union of regexp * regexp   (* Union (alternation) of two regexps *)
  | Star of regexp            (* Kleene star (zero or more repetitions) *)

module Cset = Set.Make(struct 
  type t = ichar 
  let compare = Stdlib.compare 
end)

let rec null = function
  | Empty -> false
  | Epsilon -> true
  | Character _ -> false
  | Concat (r1, r2) -> null r1 && null r2
  | Union (r1, r2) -> null r1 || null r2
  | Star _ -> true

  let rec first = function
  | Empty -> Cset.empty
  | Epsilon -> Cset.empty
  | Character c -> Cset.singleton c
  | Concat (r1, r2) ->
      if null r1 then Cset.union (first r1) (first r2)
      else first r1
  | Union (r1, r2) -> Cset.union (first r1) (first r2)
  | Star r -> first r

  let rec last = function
  | Empty -> Cset.empty
  | Epsilon -> Cset.empty
  | Character c -> Cset.singleton c
  | Concat (r1, r2) ->
      if null r2 then Cset.union (last r1) (last r2)
      else last r2
  | Union (r1, r2) -> Cset.union (last r1) (last r2)
  | Star r -> last r

  let () =
  let ca = ('a', 0) and cb = ('b', 0) in
  let a = Character ca and b = Character cb in
  let ab = Concat (a, b) in
  let eq = Cset.equal in
  assert (eq (first a) (Cset.singleton ca));
  assert (eq (first ab) (Cset.singleton ca));
  assert (eq (first (Star ab)) (Cset.singleton ca));
  assert (eq (last b) (Cset.singleton cb));
  assert (eq (last ab) (Cset.singleton cb));
  assert (Cset.cardinal (first (Union (a, b))) = 2);
  assert (Cset.cardinal (first (Concat (Star a, b))) = 2);
  assert (Cset.cardinal (last (Concat (a, Star b))) = 2)
