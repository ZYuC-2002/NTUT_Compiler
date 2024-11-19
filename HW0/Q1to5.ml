(* Exercise 1: Number warm-up *)
let rec fact n =
  if n = 0 then 1
  else n * fact (n - 1)
let rec nb_bit_pos n =
  if n = 0 then 0
  else (n land 1) + nb_bit_pos (n lsr 1)

(* Exercise 2: Fibonacci *)
let fibo n =
  let rec aux n a b =
    if n = 0 then a
    else aux (n - 1) b (a + b)
  in
  aux n 0 1

(* Exercise 3: Strings *)
(* (a) palindrome *)
let palindrome m =
  let len = String.length m in
  let rec aux i =
    if i >= len / 2 then true
    else if m.[i] <> m.[len - 1 - i] then false
    else aux (i + 1)
  in
  aux 0
(* (b) compare *)
let compare m1 m2 =
  String.compare m1 m2 < 0
(* (c) factor *)
let factor m1 m2 =
  let len1 = String.length m1 in
  let len2 = String.length m2 in
  let rec aux i =
    if i > len2 - len1 then false
    else if String.sub m2 i len1 = m1 then true
    else aux (i + 1)
  in
aux 0

(* Exercise 4: Merge sort *)
(* (a) split *)
let rec split l =
  match l with
  | [] -> ([], [])  (* 當列表為空時返回兩個空列表 *)
  | [x] -> ([x], [])  (* 當列表只有一個元素時，一個列表有該元素，另一個為空 *)
  | x :: y :: rest ->
      let (l1, l2) = split rest in
      (x :: l1, y :: l2)  (* 將第一個元素分到 l1，第二個元素分到 l2，然後遞歸分配其餘元素 *)
(* (b) merge *)
let rec merge l1 l2 =
  match l1, l2 with
  | [], l -> l  (* 如果 l1 是空列表，直接返回 l2 *)
  | l, [] -> l  (* 如果 l2 是空列表，直接返回 l1 *)
  | x1 :: r1, x2 :: r2 ->
      if x1 <= x2 then
        x1 :: merge r1 l2  (* 如果 l1 的頭元素小於或等於 l2 的頭元素，將其加入結果 *)
      else
        x2 :: merge l1 r2  (* 否則，將 l2 的頭元素加入結果 *)
(* (c) sort *)
let rec sort l =
  match l with
  | [] -> []  (* 如果列表為空，直接返回空列表 *)
  | [x] -> [x]  (* 如果列表只有一個元素，返回該元素 *)
  | _ ->
      let (l1, l2) = split l in  (* 將列表分為兩半 *)
      merge (sort l1) (sort l2)  (* 分別對兩個子列表進行排序，然後合併 *)

(* Exercise 5: Lists *)
(* (a) square_sum *)
let square_sum l =
  List.fold_left (fun acc x -> acc + (x * x)) 0 l
(* (b) find_opt *)
let find_opt x l =
  List.find_opt (fun (_, y) -> y = x) (List.mapi (fun i y -> (i, y)) l)
  |> Option.map fst  (* 使用 Option.map fst 提取索引部分 *)

let () =
  (* Exercise 1 *)
  Printf.printf "Exercise 1:\n";
  let f = fact 5 in
  let b = nb_bit_pos 5 in
  Printf.printf "\tfact 5 = %d\n" f;
  Printf.printf "\tnb_bit_pos 5 = %d\n" b;

  (* Exercise 2 *)
  Printf.printf "\nExercise 2:\n";
  Printf.printf "\tfibo 6 = %d\n" (fibo 6);

  (* Exercise 3 *)
  Printf.printf "\nExercise 3:\n";
  (* (a) *)
  Printf.printf "\t(a):\n";
  Printf.printf "\tIs 'abcba' a palindrome? %s" (if palindrome "abcba" then "true\n" else "false\n");
  Printf.printf "\tIs 'acbaa' a palindrome? %s" (if palindrome "acbaa" then "true\n" else "false\n");
  (* (b) *)
  Printf.printf "\t(b):\n";
  Printf.printf "\tcompare 'abc'&'def': %s\n" (if compare "abc" "def" then "true" else "false");
  Printf.printf "\tcompare 'fde'&'edf': %s\n" (if compare "fde" "edf" then "true" else "false");
  (* (c) *)
  Printf.printf "\t(c):\n";
  Printf.printf "\tfactor 'abc' in 'abcdef': %s\n" (if factor "abc" "abcdef" then "true" else "false");
  Printf.printf "\tfactor 'bca' in 'abcdef': %s\n" (if factor "bca" "abcdef" then "true" else "false");

  (* Exercise 4: Merge sort *)
  Printf.printf "\nExercise 4:\n";
  let l = [4; 3; 1; 5; 2] in
  let sorted_l = sort l in
  Printf.printf "\tSorted list: ";
  List.iter (Printf.printf "%d") sorted_l;
  Printf.printf "\n";

  (* Exercise 5: Lists *)
  Printf.printf "\nExercise 5:\n";
  (* (a) *)
  let l = [1; 2; 3; 4] in
  Printf.printf "\tSquare sum of [1; 2; 3; 4] is: %d\n" (square_sum l);
  (* (b) *)
  let l2 = [5; 6; 7; 8] in
  match find_opt 7 l2 with
  | Some i -> Printf.printf "\tElement 7 found at index: %d\n" i
  | None -> Printf.printf "\tElement 7 not found\n";