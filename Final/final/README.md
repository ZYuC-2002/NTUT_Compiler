# 有 TODO ㄉ檔案
## compile.ml

# lexer.mll (same as HW2)

这个 lexer.mll 文件是为一个简化的 Python 编译器编写的词法分析器。它使用 OCaml 的 ocamllex 工具来将源码转换成词法符号。下面我们逐步解释代码的各个部分。

**导入和异常定义**
```
{
  open Lexing
  open Ast
  open Parser

  exception Lexing_error of string
```
- open Lexing: 导入 OCaml 的词法分析库。
- open Ast: 导入抽象语法树模块。
- open Parser: 导入解析器模块。
- exception Lexing_error of string: 定义一个名为 Lexing_error 的异常，用于报告词法分析过程中的错误。

**关键字和标识符处理**
```
 let id_or_kwd =
    let h = Hashtbl.create 32 in
    List.iter (fun (s, tok) -> Hashtbl.add h s tok)
      ["def", DEF; "if", IF; "else", ELSE;
       "return", RETURN; "print", PRINT;
       "for", FOR; "in", IN;
       "and", AND; "or", OR; "not", NOT;
       "True", CST (Cbool true);
       "False", CST (Cbool false);
       "None", CST Cnone;];
   fun s -> try Hashtbl.find h s with Not_found -> IDENT s
```
- id_or_kwd 是一个函数，用于区分关键字和标识符。
  - 创建一个哈希表 h，其中存储了所有的关键字及其对应的词法符号（token）。
  - 使用 List.iter 将关键字添加到哈希表中。
  - 函数接收一个字符串 s，如果在哈希表 h 中找到对应的词法符号，则返回该词法符号；否则，将其视为标识符 IDENT s。

**字符串缓存和缩进处理**
```
 let string_buffer = Buffer.create 1024

  let stack = ref [0]  (* indentation stack *)

  let rec unindent n = match !stack with
    | m :: _ when m = n -> []
    | m :: st when m > n -> stack := st; END :: unindent n
    | _ -> raise (Lexing_error "bad indentation")

  let update_stack n =
    match !stack with
    | m :: _ when m < n ->
      stack := n :: !stack;
      [NEWLINE; BEGIN]
    | _ ->
      NEWLINE :: unindent n
}
```
- string_buffer: 一个字符缓存，用于暂存字符串字面量。
- stack: 一个引用的列表，表示缩进堆栈，初始值为 [0]。
- unindent n: 递归函数，用于处理缩进减少的情况。
  - 比较当前缩进 n 与堆栈顶部的值 m。
    - 如果相等，返回空列表，表示缩进未变化。
    - 如果 m > n，表示需要减少缩进，从堆栈中弹出并返回 END 标记，继续递归检查。
    - 其他情况，抛出 Lexing_error 异常，表示缩进出错。
- update_stack n: 更新缩进堆栈的函数。
  - 如果新的缩进 n 大于堆栈顶部的值 m，表示进入新的代码块：
    - 将新缩进值压入堆栈。 
    - 返回 [NEWLINE; BEGIN]，表示新的一行和代码块的开始。
  - 否则，调用 unindent n 来处理缩进减少的情况。
  
**词法规则定义**
```
let letter = ['a'-'z' 'A'-'Z']
let digit = ['0'-'9']
let ident = (letter | '_') (letter | digit | '_')*
let integer = '0' | ['1'-'9'] digit*
let space = ' ' | '\t'
let comment = "#" [^'\n']*
```
- letter: 定义字母字符集合，即大小写字母。
- digit: 定义数字字符集合，即 0-9。
- ident: 定义标识符，以字母或下划线开头，后接任意数量的字母、数字或下划线。
- integer: 定义整数，可以是单个 0 或非零数字开头后跟随数字。
- space: 定义空白字符，空格或制表符。
- comment: 定义注释，以 # 开头，后接任意非换行符的字符。

**词法解析规则**
```
rule next_tokens = parse
  | '\n'    { new_line lexbuf; update_stack (indentation lexbuf) }
  | (space | comment)+
            { next_tokens lexbuf }
  | ident as id { [id_or_kwd id] }
  | '+'     { [PLUS] }
  | '-'     { [MINUS] }
  | '*'     { [TIMES] }
  | "//"    { [DIV] }
  | '%'     { [MOD] }
  | '='     { [EQUAL] }
  | "=="    { [CMP Beq] }
  | "!="    { [CMP Bneq] }
  | "<"     { [CMP Blt] }
  | "<="    { [CMP Ble] }
  | ">"     { [CMP Bgt] }
  | ">="    { [CMP Bge] }
  | '('     { [LP] }
  | ')'     { [RP] }
  | '['     { [LSQ] }
  | ']'     { [RSQ] }
  | ','     { [COMMA] }
  | ':'     { [COLON] }
  | integer as s
            { try [CST (Cint (Int64.of_string s))]
              with _ -> raise (Lexing_error ("constant too large: " ^ s)) }
  | '"'     { [CST (Cstring (string lexbuf))] }
  | eof     { NEWLINE :: unindent 0 @ [EOF] }
  | _ as c  { raise (Lexing_error ("illegal character: " ^ String.make 1 c)) }
```
- \n: 遇到换行符，调用 new_line lexbuf 更新行号，读取缩进并更新堆栈。
- (space | comment)+: 空白或注释，忽略并继续解析下一个符号。
- ident as id: 匹配标识符或关键字，通过 id_or_kwd 函数区分，返回相应的词法符号。
- 后续匹配特定的符号，如 +、-、*、 等，返回相应的词法符号。
- integer as s: 匹配整数字符串 s，尝试转换为 Int64 类型，如果溢出则抛出异常。
- '"': 开始解析字符串字面量，调用 string lexbuf 函数。
- eof: 文件结束，返回 NEWLINE，调用 unindent 0 清空缩进堆栈，最后添加 EOF。
- _ as c: 匹配任何未被识别的字符，抛出 Lexing_error 异常。

**缩进处理**
```
and indentation = parse
  | (space | comment)* '\n'
      { new_line lexbuf; indentation lexbuf }
  | space* as s
      { String.length s }
```
- indentation: 处理空白字符来计算缩进级别。
  - 如果只有空白或注释后跟换行符，则递归调用 indentation，继续处理下一行。 
  - 否则，计算空白字符的数量，即当前行的缩进。
  
**字符串解析**
```
and string = parse
  | '"'
      { let s = Buffer.contents string_buffer in
    Buffer.reset string_buffer;
    s }
  | "\\n"
      { Buffer.add_char string_buffer '\n';
    string lexbuf }
  | "\\\""
      { Buffer.add_char string_buffer '"';
    string lexbuf }
  | _ as c
      { Buffer.add_char string_buffer c;
    string lexbuf }
  | eof
      { raise (Lexing_error "unterminated string") }
```
- string: 解析字符串字面量的递归规则。
  - '"': 遇到结束引号，提取缓存的字符串内容，重置缓存并返回字符串。
  - "\\n": 处理转义字符 \n，添加换行符到缓存。
  - "\\\"": 处理转义字符 \"，添加引号字符到缓存。
  - _ as c: 其他字符，添加到缓存并继续解析。
  - eof: 如果在文件结束前字符串未闭合，抛出异常。

**词法分析器入口**
```
{
  let next_token =
    let tokens = Queue.create () in (* next tokens to emit *)
    fun lb ->
      if Queue.is_empty tokens then begin
    let l = next_tokens lb in
    List.iter (fun t -> Queue.add t tokens) l
      end;
      Queue.pop tokens
}
```
- next_token: 词法分析器的主函数，供解析器调用。
  - 使用一个队列 tokens 来存储待返回的词法符号。
  - 如果队列为空，调用 next_tokens 函数来读取并处理下一个输入。
  - 将解析得到的词法符号列表逐个加入队列。
  - 返回队列中的下一个词法符号。

# parser.mly (same as HW2)

`new_line lexbuf` 是一個函數調用，用於處理當前行的結束並準備解析下一行。這個函數通常會更新詞法分析器的行號和列號，以便在出錯時能夠提供準確的錯誤位置。

在這段代碼中，`new_line` 函數應該是定義在其他地方的，可能在同一個文件的其他部分或在導入的模塊中。它的作用是告訴詞法分析器已經遇到了一個新的行，並且需要更新內部狀態來反映這一點。

如果你需要查看 `new_line` 函數的具體實現，可以在當前文件或導入的模塊中搜索 `new_line` 的定義。

ZYuC-2002: 可以幫我找找 new_line 的定義在哪嗎

GitHub Copilot: `new_line` 函數的定義不在你提供的代碼片段中。你可以在你的代碼庫中搜索 `new_line` 來找到它的定義。以下是一些可能的搜索方法：

1. 在 Visual Studio Code 中使用全局搜索功能：
   - 打開搜索面板（按 `Ctrl+Shift+F`）。
   - 輸入 `new_line` 並查看搜索結果。

2. 使用命令行工具（如 `grep`）在你的代碼庫中搜索：
   ```sh
   grep -r "new_line" path/to/your/codebase
   ```

這樣你應該能夠找到 `new_line` 函數的具體定義位置。

ZYuC-2002: new_line 似乎是 OCaml 的 Module Lexing 裡的函式
https://ocaml.org/manual/5.1/api/Lexing.html

GitHub Copilot: `new_line` 確實是 OCaml 的 `Lexing` 模組中的一個函數。它的作用是更新詞法分析器的行號和列號，以便在出錯時能夠提供準確的錯誤位置。

在 `Lexing` 模組中，`new_line` 的定義如下：

```ocaml
val new_line : lexbuf -> unit
```

這個函數接受一個 `lexbuf`（詞法緩衝區）作為參數，並更新其內部狀態以反映新的行號。

你可以在 OCaml 官方文檔中找到更多關於 `Lexing` 模組的詳細信息：[Lexing 模組文檔](https://ocaml.org/manual/5.1/api/Lexing.html)

ZYuC-2002: 解釋這個檔案在做什麼

GitHub Copilot: 這個文件是 Mini-Python 語言的語法解析器，使用 Menhir 工具來生成解析器。它定義了如何將詞法分析器生成的詞法符號轉換成抽象語法樹（AST）。以下是這個文件的詳細解釋：

### 頭部定義
```ocaml
%{
  open Ast
%}
```
這部分打開了 `Ast` 模塊，這樣可以在解析規則中使用 `Ast` 模塊中的定義。

### 詞法符號定義
```ocaml
%token <Ast.constant> CST
%token <Ast.binop> CMP
%token <string>

 IDENT


%token DEF IF ELSE RETURN PRINT FOR IN AND OR NOT
%token EOF
%token LP RP LSQ RSQ COMMA EQUAL COLON BEGIN END NEWLINE
%token PLUS MINUS TIMES DIV MOD
```
這部分定義了詞法符號（tokens），這些符號是由詞法分析器生成的。每個符號可以有一個類型，例如 `CST` 是 `Ast.constant` 類型，`CMP` 是 `Ast.binop` 類型，`IDENT` 是 `string` 類型。

### 優先級和結合性
```ocaml
%left OR
%left AND
%nonassoc NOT
%nonassoc CMP
%left PLUS MINUS
%left TIMES DIV MOD
%nonassoc unary_minus
%nonassoc LSQ
```
這部分定義了運算符的優先級和結合性，這樣解析器可以正確地解析運算表達式。

### 起始符號和類型
```ocaml
%start file
%type <Ast.file> file
```
這部分定義了解析的起始符號是 `file`，並且它的類型是 `Ast.file`。

### 解析規則
```ocaml
%%

file:
| NEWLINE? dl = list(def) b = nonempty_list(stmt) NEWLINE? EOF
    { dl, Sblock b }
;
```
這部分定義了 `file` 的解析規則。`file` 可以由可選的換行符、一個定義列表、一個非空的語句列表、可選的換行符和文件結束符號組成。解析結果是定義列表和語句塊。

其他解析規則定義了如何解析函數定義、表達式、語句等。例如：

```ocaml
def:
| DEF f = ident LP x = separated_list(COMMA, ident) RP
  COLON s = suite
    { f, x, s }
;
```
這部分定義了函數定義的解析規則。函數定義由 `DEF` 關鍵字、函數名、參數列表、冒號和函數體組成。解析結果是函數名、參數列表和函數體。

```ocaml
expr:
| c = CST
    { Ecst c }
| id = ident
    { Eident id }
| e1 = expr LSQ e2 = expr RSQ
    { Eget (e1, e2) }
| MINUS e1 = expr %prec unary_minus
    { Eunop (Uneg, e1) }
| NOT e1 = expr
    { Eunop (Unot, e1) }
| e1 = expr o = binop e2 = expr
    { Ebinop (o, e1, e2) }
| f = ident LP e = separated_list(COMMA, expr) RP
    { Ecall (f, e) }
| LSQ l = separated_list(COMMA, expr) RSQ
    { Elist l }
| LP e = expr RP
    { e }
;
```
這部分定義了表達式的解析規則。表達式可以是常量、標識符、列表訪問、單目運算、雙目運算、函數調用、列表或括號內的表達式。

### 內聯規則
```ocaml
%inline binop:
| PLUS  { Badd }
| MINUS { Bsub }
| TIMES { Bmul }
| DIV   { Bdiv }
| MOD   { Bmod }
| c=CMP { c    }
| AND   { Band }
| OR    { Bor  }
;
```
這部分定義了雙目運算符的解析規則，這些運算符會被內聯到其他規則中。

### 標識符規則
```ocaml
ident:
  id = IDENT { { loc = ($startpos, $endpos); id } }
;
```
這部分定義了標識符的解析規則。標識符是 `IDENT` 類型的詞法符號，解析結果是帶有位置信息的標識符。

總結來說，這個文件定義了 Mini-Python 語言的語法規則，並且使用 Menhir 工具生成解析器。解析器將詞法分析器生成的詞法符號轉換成抽象語法樹（AST）。

Similar code found with 1 license type

# ast.ml
## 與 HW#2 差異
```
(** {3 Typed trees}

   This is the output of the type checker and the input of the code
   generation. *)

(** In the typed trees, all the occurrences of the same variable
   point to a single record of the following type. *)
type var = {
  v_name: string;
  mutable v_ofs: int; (** position wrt %rbp *)
}

(** Similarly, all the occurrences of a given function all point
   to a single record of the following type. *)
type fn = {
  fn_name: string;
  fn_params: var list;
}

type texpr =
  | TEcst of constant
  | TEvar of var
  | TEbinop of binop * texpr * texpr
  | TEunop of unop * texpr
  | TEcall of fn * texpr list
  | TElist of texpr list
  | TErange of texpr (** list(range(e1)) *)
  | TEget of texpr * texpr (** {[ e1[e2] ]} *)

type tstmt =
  | TSif of texpr * tstmt * tstmt
  | TSreturn of texpr
  | TSassign of var * texpr
  | TSprint of texpr
  | TSblock of tstmt list
  | TSfor of var * texpr * tstmt
  | TSeval of texpr
  | TSset of texpr * texpr * texpr (** {[ e1[e2] = e3 ]} *)

and tdef = fn * tstmt

and tfile = tdef list
  (** the block of global statements is now a `main` function *)
```
