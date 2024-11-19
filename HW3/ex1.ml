type ichar = char * int

type regexp =
  | Epsilon
  | Character of ichar
  | Union of regexp * regexp
  | Concat of regexp * regexp
  | Star of regexp

let rec null = function
  | Epsilon -> true (* Epsilon matches the empty string *)
  | Character _ -> false (* A character cannot match the empty string *)
  | Union (r1, r2) -> null r1 || null r2 (* If either of the expressions matches the empty string *)
  | Concat (r1, r2) -> null r1 && null r2 (* Both expressions must match the empty string *)
  | Star _ -> true (* The Kleene star of any expression can match the empty string *)

(* Test cases *)
let () =
  let a = Character ('a', 0) in
  assert (not (null a));
  assert (null (Star a));
  assert (null (Concat (Epsilon, Star Epsilon)));
  assert (null (Union (Epsilon, a)));
  assert (not (null (Concat (a, Star a))))
