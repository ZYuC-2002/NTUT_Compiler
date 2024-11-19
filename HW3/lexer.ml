(* lexer.ml *)
exception End_of_file
exception Lexical_error of string

type buffer = {
  text: string;
  mutable current: int;
  mutable last: int;
}

let next_char b =
  if b.current = String.length b.text then raise End_of_file;
  let c = b.text.[b.current] in
  b.current <- b.current + 1;
  c

let analyze_string input =
  let buffer = { text = input; current = 0; last = -1 } in
  try
    while true do
      buffer.last <- -1;
      (try
        start buffer;
        if buffer.last = -1 then
          raise (Lexical_error "No token recognized")
        else begin
          let token = String.sub buffer.text buffer.current (buffer.last - buffer.current) in
          Printf.printf "--> \"%s\"\n" token;
          buffer.current <- buffer.last
        end
      with
        | End_of_file -> 
            if buffer.last <> -1 then begin
              let token = String.sub buffer.text buffer.current (buffer.last - buffer.current) in
              Printf.printf "--> \"%s\"\n" token
            end;
            raise End_of_file
        | Lexical_error msg -> raise (Failure msg))
    done
  with
    | End_of_file -> Printf.printf "End of input reached\n"
    | Failure msg -> Printf.printf "Lexical error: %s\n" msg

let () =
  Printf.printf "\nTesting 'abbaaab':\n";
  analyze_string "abbaaab";
  
  Printf.printf "\nTesting 'aba':\n";
  analyze_string "aba";
  
  Printf.printf "\nTesting 'aac':\n";
  analyze_string "aac";
  
  Printf.printf "\nTesting 'abbac':\n";
  analyze_string "abbac"