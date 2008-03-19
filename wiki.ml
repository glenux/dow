(* vim: set ts=2 sw=2 et : *)

type action_t = 
  | Html
  | Raw
  | Change of string (* all text *)
  | Insert of int (* offset *) * string (* inserted text *)


module StringMap = Map.Make(String)


let wiki = ref StringMap.empty

let homepage = "HomePage"


let get_view page = 
  Printf.printf "<-- WIKI.VIEW: [%s]\n" page ;
  (* return a html string for page 
   * - header
   * - title
   * - htmlized data
   * - edit button
   *)
  if ( StringMap.mem page !wiki ) then
    let page_data = StringMap.find page !wiki
    in
    "<h1>View " ^ page ^ "</h1>" ^
    page_data ^
    "<a href=\"/" ^ page ^ "/edit\">Edit</a>"
  else
    "<h1>Unknown page " ^ page ^ "</h1>" ^
    "<p>Would you like to create it ?</p>" ^
    "<a href=\"/" ^ page ^ "/edit\">Edit</a>"



let get_edit page = 
  (* return a html string for page 
   * - header
   * - title
   * - textarea + data
   * - save button
   * - cancel button
   *)

  let page_data = 
  if ( StringMap.mem page !wiki ) then
    StringMap.find page !wiki 
  else 
    ""
    in
    "<h1>View " ^ page ^ "</h1>" ^
    "<textarea>" ^
    page_data ^
    "</textarea>" ^
    "<form action=\"" ^ page ^ "/edit\" method=\"post\" >" ^
    "<input type=\"submit\" value=\"save\" >" ^
    "<input type=\"submit\" value=\"preview\" >" ^
    "<input type=\"button\" value=\"cancel\" >" ^
    "</form>"


let get location =
  let handle_page_action page action = (
    Printf.printf "<-- WIKI.GET: page=[%s] action=[%s]\n" page action ; 
    flush stdout ;
    match action with 
    | "edit" -> get_edit page
    | "view" -> get_view page
    | _ -> get_view page
  )
  in
  Printf.printf "<-- WIKI.GET/RAW: [%s]\n" location ;
  flush stdout ;
  try 
    Scanf.sscanf location "/%[a-zA-Z]/%[a-z]" handle_page_action
  with
  | End_of_file -> 
      Printf.printf "<-- WIKI.GET: EOF [%s]\n" location;
      flush stdout ;
      get_view "HomePage"
  | Scanf.Scan_failure _ -> 
      Printf.printf "<-- WIKI.GET: Invalid page [%s]\n" location ;
      flush stdout ;
      get_view "HomePage"


let post location =
  Printf.printf "<-- WIKI.POST/RAW: [%s]\n" location ;
  flush stdout ;
