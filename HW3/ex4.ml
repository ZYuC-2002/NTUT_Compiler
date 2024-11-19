(* Types for regular expressions *)
type regexp =
  | Character of (char * int)
  | Concat of regexp * regexp
  | Union of regexp * regexp
  | Star of regexp

(* Set module for characters with indices *)
module Cset = Set.Make(struct
  type t = char * int
  let compare = compare
end)

type state = Cset.t

module Cmap = Map.Make(Char)
module Smap = Map.Make(Cset)

type autom = {
  start : state;
  trans : state Cmap.t Smap.t;
}

(* Helper function to check if regexp is nullable *)
let rec nullable = function
  | Character _ -> false
  | Union (r1, r2) -> nullable r1 || nullable r2
  | Concat (r1, r2) -> nullable r1 && nullable r2
  | Star _ -> true

(* Implementation of first function *)
let rec first (r : regexp) : Cset.t =
  match r with
  | Character c -> Cset.singleton c
  | Union (r1, r2) -> Cset.union (first r1) (first r2)
  | Concat (r1, r2) ->
      if nullable r1
      then Cset.union (first r1) (first r2)
      else first r1
  | Star r -> first r

(* Implementation of follow function *)
let rec follow (ci : char * int) (r : regexp) : Cset.t =
  match r with
  | Character _ -> Cset.empty
  | Union (r1, r2) ->
      Cset.union (follow ci r1) (follow ci r2)
  | Concat (r1, r2) ->
      let f1 = follow ci r1 in
      let f2 = follow ci r2 in
      if Cset.mem ci (first r1) && nullable r1
      then Cset.union (Cset.union f1 f2) (first r2)
      else if Cset.mem ci (first r2)
      then Cset.union f1 f2
      else f1
  | Star r1 ->
      if Cset.mem ci (first r1)
      then Cset.union (follow ci r1) (first r1)
      else follow ci r1

(* Define next_state function *)
let next_state (r : regexp) (q : state) (c : char) : state =
  Cset.fold (fun ci acc ->
    if fst ci = c then
      Cset.union acc (follow ci r)
    else
      acc
  ) q Cset.empty

let eof = ('#', -1)

(* DFA construction function *)
let make_dfa (r : regexp) : autom =
  let r = Concat (r, Character eof) in
  let trans = ref Smap.empty in
  
  let rec transitions (q : state) =
    if not (Smap.mem q !trans) then begin
      let cmap = ref Cmap.empty in
      Cset.iter (fun ci ->
        let c = fst ci in
        let q' = next_state r q c in
        if not (Cset.is_empty q') then
          cmap := Cmap.add c q' !cmap
      ) q;
      trans := Smap.add q !cmap !trans;
      Cmap.iter (fun _ q' -> transitions q') !cmap
    end
  in
  
  let q0 = first r in
  transitions q0;
  { start = q0; trans = !trans }

(* Helper function to convert state to string *)
let state_to_string q =
  let buf = Buffer.create 16 in
  Cset.iter (fun (c, i) ->
    Buffer.add_string buf (
      if c = '#' then "# "
      else Printf.sprintf "%c%d " c i
    )
  ) q;
  Buffer.contents buf

(* Updated printing functions *)
let fprint_state fmt q =
  Format.fprintf fmt "%s" (state_to_string q)

let fprint_transition fmt q c q' =
  Format.fprintf fmt "  \"%a\" -> \"%a\" [label=\"%c\"];\n"
    fprint_state q
    fprint_state q'
    c

let fprint_autom fmt a =
  Format.fprintf fmt "digraph A {\n";
  (* Add initial state *)
  Format.fprintf fmt "  \"%a\" [shape=rect];\n" fprint_state a.start;
  
  (* Add all states and make accepting states double circles *)
  Smap.iter (fun q _ ->
    let shape = if Cset.exists (fun (c, _) -> c = '#') q 
                then "doublecircle" 
                else "circle" in
    Format.fprintf fmt "  \"%a\" [shape=%s];\n" fprint_state q shape
  ) a.trans;
  
  (* Add all transitions *)
  Smap.iter (fun q t ->
    Cmap.iter (fun c q' ->
      fprint_transition fmt q c q'
    ) t
  ) a.trans;
  
  Format.fprintf fmt "}\n"

let save_autom file a =
  let ch = open_out file in
  let fmt = Format.formatter_of_out_channel ch in
  fprint_autom fmt a;
  Format.pp_print_flush fmt ();
  close_out ch

(* (a|b)*a(a|b) *)
let r = Concat (
  Star (
    Union (Character ('a', 1), Character ('b', 1))
  ),
  Concat (
    Character ('a', 2),
    Union (Character ('a', 3), Character ('b', 2))
  )
)

let a = make_dfa r
let () = save_autom "autom.dot" a