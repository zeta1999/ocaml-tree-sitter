(*
   Simple utilities to work on the types defined in Tree_sitter_output.atd.
*)

open Printf
open Tree_sitter_bindings.Tree_sitter_output_t

let format_snippet src start end_ =
  let snippet = Src_file.get_token src start end_ in
  sprintf "%s\n" snippet

let string_of_node_type x =
  match x.children with
  | None ->
      sprintf "%S" x.type_
  | Some _ ->
      x.type_

let string_of_node x =
  match x.children with
  | None ->
      sprintf "node type: %S" x.type_
  | Some children ->
      sprintf "\
node type: %s
children: [
%s]"
        x.type_
        (List.map (fun x -> sprintf "  %s\n" (string_of_node_type x)) children
         |> String.concat "")

(* Take an error message and prepend the location information,
   in a human-readable and possibly computer-readable format (TODO check with
   emacs etc.)
*)
let prepend_msg src node msg =
  let start = node.start_pos in
  let end_ = node.end_pos in
  let loc =
    if start.row = end_.row then
      sprintf "Line %i, characters %i-%i:"
        start.row start.column end_.column
    else
      sprintf "Line %i, character %i to line %i, character %i:"
        start.row start.column end_.row end_.column
  in
  let snippet = format_snippet src start end_ in
  sprintf "\
%s
%s
source code:
%s
%s"
    loc
    (string_of_node node)
    snippet
    msg

let fail src node msg =
  let msg = prepend_msg src node msg in
  failwith msg
