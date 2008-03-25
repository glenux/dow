(* vim: set ts=2 sw=2 et : *)



type action_t = 
  | Get_html
  | Get_text
  | Get_tree
  (* text actions *)
  | Set_text of string (* all text *)
  | Insert_text of int (* offset *) * string (* inserted text *)
  | Remove_text of int (* offset *) * string (* removed text *)
  (* tree actions *)
;;

type 'a request_t = {
  link : 'a ;
  page : string ;
  action : action_t ;
}
;;


type answer_t = {
  content: string ;
}


let default_page = "HomePage"
;;

let default_action = Get_html
;;

let string_of_action action = 
  match action with
  | Get_html -> "Get Html"
  | Get_text -> "Get Text"
  | Get_tree -> "Get Tree (?)"
  | Set_text text -> Printf.sprintf "Set Text [%s]" text
  | Insert_text ( offset, text ) -> Printf.sprintf "Insert(%d,%s)" offset text
  | Remove_text ( offset, text ) -> Printf.sprintf "Remove(%d,%s)" offset text
;;

let string_of_request request = 
  Printf.sprintf "action=[%s] page[%s]" 
  (string_of_action request.action)
  (request.page)
;;

let wiki = ref StringMap.empty
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

let handle_request request = 
  (* let handle_page_action =page action = (
    match action with 
    | Change text -> handle_change page text
    | Html -> handle_html page
    | Raw -> handle_raw page 
    | Insert (offset, text) -> handle_insert page offset text
  )
  in *)
  Printf.printf "<-- WIKI.HANDLE_REQUEST: [%s]\n" 
    (string_of_request request) ; 
  flush stdout ;
  ""
  (* handle_page_action page action *)
;;


let post location =
  Printf.printf "<-- WIKI.POST/RAW: [%s]\n" location ;
  flush stdout
;;

