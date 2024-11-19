(* Exercise 6: Tail recursion *)
let rev_list l =
  let rec aux acc l =
    match l with
    | [] -> acc
    | x :: xs -> aux (x :: acc) xs
  in
  aux [] l

let map_list f l =
  let rec aux acc l =
    match l with
    | [] -> rev_list acc  (* 累加完後需要反轉累加的結果 *)
    | x :: xs -> aux (f x :: acc) xs
  in
  aux [] l
  
(* Exercise 7: Concatenation *)
(* (a) basic *)
type 'a seq =
  | Elt of 'a
  | Seq of int * 'a seq * 'a seq  (* Store length as an integer *)

(* Redefine @@ to keep track of lengths *)
let rec (@@) s1 s2 =
  let len1 = length s1 and len2 = length s2 in
  Seq (len1 + len2, s1, s2)

(* Helper function to get the length of a sequence *)
and length = function
  | Elt _ -> 1
  | Seq (len, _, _) -> len

(* Returns the head of the sequence *)
let rec hd = function
  | Elt x -> x
  | Seq (_, s1, _) -> hd s1

(* Returns the tail of the sequence *)
let rec tl = function
  | Elt _ -> failwith "Empty sequence"  (* No tail in a single element *)
  | Seq (_, Elt _, s2) -> s2
  | Seq (len, s1, s2) -> Seq (len - 1, tl s1, s2)

(* Checks if an element exists in the sequence *)
let rec mem x = function
  | Elt y -> x = y
  | Seq (_, s1, s2) -> mem x s1 || mem x s2

(* Reverses the sequence *)
let rec rev = function
  | Elt x -> Elt x
  | Seq (len, s1, s2) -> Seq (len, rev s2, rev s1)

(* Applies a function f to all elements of the sequence *)
let rec map f = function
  | Elt x -> Elt (f x)
  | Seq (len, s1, s2) -> Seq (len, map f s1, map f s2)

(* Left fold: iterating from left to right *)
let rec fold_left f acc = function
  | Elt x -> f acc x
  | Seq (_, s1, s2) -> fold_left f (fold_left f acc s1) s2

(* Right fold: iterating from right to left *)
let rec fold_right f seq acc =
  match seq with
  | Elt x -> f x acc
  | Seq (_, s1, s2) -> fold_right f s1 (fold_right f s2 acc)

(* (b) seq2list *)
let rec seq2list seq =
  let rec aux acc = function
    | Elt x -> x :: acc
    | Seq (_, s1, s2) -> aux (aux acc s2) s1
  in
  aux [] seq

(* (c) find_opt *)
let find_opt x seq =
  let rec aux i = function
    | Elt y -> if x = y then Some i else None
    | Seq (_, s1, s2) ->
      match aux i s1 with
      | Some _ as result -> result
      | None -> aux (i + length s1) s2
  in
  aux 0 seq

(* (d) nth *)
let nth seq n =
  let rec aux i = function
    | Elt x -> if i = 0 then x else failwith "Index out of bounds"
    | Seq (_, s1, s2) ->
      let len1 = length s1 in
      if n < len1 then aux n s1 else aux (n - len1) s2
  in
  aux n seq

let () =
  (* Exercise 6: Tail recursion *)
  Printf.printf "\nExercise 6:\n";
  (* 創建 0 到 1,000,000 的列表 *)
  let l = List.init 1_000_001 (fun x -> x) in
  (* 測試 rev_list 函數 *)
  let rev_l = rev_list l in
  Printf.printf "\tFirst element of reversed list: %d\n" (List.hd rev_l);
  (* 測試 map_list 函數，將每個元素加 1 *)
  let mapped_l = map_list (fun x -> x + 1) l in
  Printf.printf "\tFirst element of mapped list: %d\n" (List.hd mapped_l);

  (* Exercise 7: Concatenation *)
  Printf.printf "\nExercise 7:\n";

  (* Create some sequences *)
  let s1 = Elt 1 in
  let s2 = Elt 2 in
  let s3 = Elt 3 in
  let s4 = Elt 4 in
  let seq = s1 @@ s2 @@ s3 @@ s4 in  (* Equivalent to [1; 2; 3; 4] *)

  (* Test hd *)
  Printf.printf "Testing hd:\n";
  let h = hd seq in
  Printf.printf "Head of the sequence is: %d\n" h; (* Expected: 1 *)

  (* Test tl *)
  Printf.printf "\nTesting tl:\n";
  let tl_seq = tl seq in
  Printf.printf "Head of the tail sequence is: %d\n" (hd tl_seq); (* Expected: 2 *)

  (* Test mem *)
  Printf.printf "\nTesting mem:\n";
  let is_in_seq = mem 3 seq in
  Printf.printf "Is 3 in the sequence? %s\n" (if is_in_seq then "true" else "false"); (* Expected: true *)

  let is_in_seq = mem 5 seq in
  Printf.printf "Is 5 in the sequence? %s\n" (if is_in_seq then "true" else "false"); (* Expected: false *)

  (* Test rev *)
  Printf.printf "\nTesting rev:\n";
  let rev_seq = rev seq in
  Printf.printf "Head of the reversed sequence is: %d\n" (hd rev_seq); (* Expected: 4 *)

  (* Test map *)
  Printf.printf "\nTesting map:\n";
  let mapped_seq = map (fun x -> x * 2) seq in
  Printf.printf "First element of the mapped sequence is: %d\n" (hd mapped_seq); (* Expected: 2 *)

  (* Test fold_left *)
  Printf.printf "\nTesting fold_left:\n";
  let sum = fold_left (fun acc x -> acc + x) 0 seq in
  Printf.printf "Sum of elements in the sequence: %d\n" sum; (* Expected: 10 *)

  (* Test fold_right *)
  Printf.printf "\nTesting fold_right:\n";
  let sum_right = fold_right (fun x acc -> acc + x) seq 0 in
  Printf.printf "Sum of elements in the sequence (right fold): %d\n" sum_right; (* Expected: 10 *)

  (* Test seq2list *)
  Printf.printf "\nTesting seq2list:\n";
  let list_rep = seq2list seq in
  Printf.printf "Sequence as a list: [%s]\n" (String.concat "; " (List.map string_of_int list_rep)); (* Expected: [1; 2; 3; 4] *)

  (* Test find_opt *)
  Printf.printf "\nTesting find_opt:\n";
  match find_opt 3 seq with
  | Some i -> Printf.printf "Element 3 found at index: %d\n" i  (* Expected: 2 *)
  | None -> Printf.printf "Element 3 not found\n";