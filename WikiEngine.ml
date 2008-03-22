(* vim: set ts=2 sw=2 et : *)

type action_t = 
  | Html
  | Raw
  | Change of string (* all text *)
  | Insert of int (* offset *) * string (* inserted text *)
;;


let string_of_action action = 
  match action with
  | Html -> "Html"
  | Raw -> "Raw"
  | Change text -> Printf.sprintf "Change(%s)" text
  | Insert(offset,text) -> Printf.sprintf "Insert(%d,%s)" offset text
;;


let wiki = ref StringMap.empty
;;


let homepage = "HomePage"
;;



let handle_change page text =
  ignore text ;
  ignore page ;
  ""
;;


let handle_insert page offset text =
  ignore page ;
  ignore offset ;
  ignore text ;
  ""
;;


exception Unknown_page of string
;;


let htmlize text = 
   text
;;


let is_empty page =
  not ( StringMap.mem page !wiki )
;;


let handle_html page = 
  Printf.printf "<-- WIKI.VIEW: [%s]\n" page ;
  (* return a html string for page 
   * - header
   * - title
   * - htmlized data
   * - edit button
   *)
  if ( StringMap.mem page !wiki ) then
    htmlize ( StringMap.find page !wiki )
  else
    raise ( Unknown_page page )
    (* "<h1>Unknown page " ^ page ^ "</h1>" ^
    "<p>Would you like to create it ?</p>" ^
    "<a href=\"/" ^ page ^ "/edit\">Edit</a>" *)

;;


let handle_raw page = 
  (* return a html string for page 
   * - header
   * - title
   * - textarea + data
   * - save button
   * - cancel button
   *)

  if ( StringMap.mem page !wiki ) then
    StringMap.find page !wiki 
  else 
    "Write here the content of page " ^ page
;;


let handle page action  =
  let handle_page_action page action = (
    match action with 
    | Change text -> handle_change page text
    | Html -> handle_html page
    | Raw -> handle_raw page 
    | Insert (offset, text) -> handle_insert page offset text
  )
  in
  Printf.printf "<-- WIKI.GET: page=[%s] action=[%s]\n" 
    page (string_of_action action) ; 
  flush stdout ;
  handle_page_action page action
;;


let post location =
  Printf.printf "<-- WIKI.POST/RAW: [%s]\n" location ;
  flush stdout
;;

