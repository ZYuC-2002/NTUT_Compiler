type ichar = char * int  (* character with an identifier *)
type regexp =
  | Character of ichar
  | Concat of regexp * regexp
  | Union of regexp * regexp
  | Star of regexp

module Cset = Set.Make(struct
  type t = ichar
  let compare = compare
end)

(* last function: computes the set of last characters in a regular expression *)
let rec last = function
  | Character c -> Cset.singleton c
  | Concat (r1, r2) ->
      if Cset.is_empty (last r2) then last r1 else Cset.union (last r1) (last r2)
  | Union (r1, r2) -> Cset.union (last r1) (last r2)
  | Star r -> last r

(* first function: computes the set of first characters in a regular expression *)
let rec first = function
  | Character c -> Cset.singleton c
  | Concat (r1, r2) ->
      if Cset.is_empty (first r1) then first r2 else Cset.union (first r1) (first r2)
  | Union (r1, r2) -> Cset.union (first r1) (first r2)
  | Star r -> first r

(* follow function: calculates the set of letters that can follow a given letter in the regex *)
let rec follow c r =
  match r with
  | Character _ -> Cset.empty
  | Concat (r1, r2) ->
      let follow_in_concat =
        if Cset.mem c (last r1) then first r2 else Cset.empty
      in
      Cset.union follow_in_concat (Cset.union (follow c r1) (follow c r2))
  | Union (r1, r2) ->
      Cset.union (follow c r1) (follow c r2)
  | Star r1 ->
      let follow_in_star =
        if Cset.mem c (last r1) then first r1 else Cset.empty
      in
      Cset.union follow_in_star (follow c r1)

let () =
  let ca = ('a', 0) and cb = ('b', 0) in
  let a = Character ca and b = Character cb in
  let ab = Concat (a, b) in
  assert (Cset.equal (follow ca ab) (Cset.singleton cb));
  assert (Cset.is_empty (follow cb ab));
  
  let r = Star (Union (a, b)) in
  assert (Cset.cardinal (follow ca r) = 2);
  assert (Cset.cardinal (follow cb r) = 2);
  
  let r2 = Star (Concat (a, Star b)) in
  assert (Cset.cardinal (follow cb r2) = 2);
  
  let r3 = Concat (Star a, b) in
  assert (Cset.cardinal (follow ca r3) = 2)
    