(* vim: set ts=2 sw=2 et : *)

(* open WikiEngine;; *)

module WE = WikiEngine;;

let debug = true
;;

type urlhandler_t =
  | Edit
  | View
;;


let string_from_urlhandler = function
  | Edit -> "edit"
  | View -> "view"
;;


let urlhandler_from_action = function
  | WE.Get_html -> View
  | WE.Get_text -> Edit
  | WE.Set_text _ -> Edit
  | WE.Insert_text (_,_) -> Edit (* FIXME *)
  | WE.Remove_text (_,_) -> Edit (* FIXME *)
  | WE.Get_tree -> View (* FIXME *)
;;


let urlhandler_from_string = function
  | "view" -> View
  | "edit" -> Edit
  | _ -> urlhandler_from_action WE.default_action
;;



let get_action_from_urlhandler = function
  | View -> WE.Get_html
  | Edit -> WE.Get_text
;;

let post_action_from_urlhandler text = function
  | View -> WE.Get_html
  | Edit -> WE.Set_text text
;;


let page_from_request request =
  Printf.printf "page_from_request( %s )\n" 
    (HttpRequest.string_of_request request );
  let filter_page page = 
    match page with
    | "" -> WE.default_page
    | _ -> page
  in
  match request.HttpTypes.location with
  | "/" -> WE.default_page
  | pg -> 
      let len = String.length pg
      in 
      if len > 1 then 
        filter_page ( String.sub pg 1 (len -1) )
      else
        WE.default_page
;;


let action_from_request request =
  Printf.printf "action_from_request( ... )\n" ;
  (* match the last ~/[a-z]$~ *)
  (*
  match request.HttpTypes.location with
  | [] -> default_action
  | _::pg_tail -> 
      match pg_tail with
      | [] -> default_action
      | uh::_ ->
          match request.HttpTypes.rmethod with
          | HttpTypes.Head -> 
              get_action_from_urlhandler (urlhandler_from_string uh)
          | HttpTypes.Get -> 
              get_action_from_urlhandler (urlhandler_from_string uh)
          | HttpTypes.Post -> 
              get_action_from_urlhandler (urlhandler_from_string uh) (* FIXME *)
          | HttpTypes.Put ->
              get_action_from_urlhandler (urlhandler_from_string uh) (* FIXME *)
          | HttpTypes.Delete ->
              get_action_from_urlhandler (urlhandler_from_string uh) (* FIXME *)
              *)
  ignore request ;
  WE.default_action
;;


let string_of_wikirequest wikirequest =
  Printf.sprintf "link=[%s] page=[%s] action=..." 
    wikirequest.WE.link 
    wikirequest.page
;;

let wikirequest_from_request request = 
  Printf.printf "wikirequest_from_request( ... )\n" ;
  { 
    WE.link = request ;
    page = page_from_request request ;
    action = action_from_request request ;
  }
;;


let wikicontent_title_from_wikirequest wikirequest =
  Printf.printf "wikicontent_title_from_wikirequest( ... )\n" ;
  let unsupported_action =
    Printf.sprintf "Unsupported action for \"%s\" on page \"%s\"" 
    ( WE.string_of_action wikirequest.WE.action )
    wikirequest.WE.page
  in
  match wikirequest.WE.action with
  | WE.Get_html -> 
      if not ( WE.is_empty wikirequest.WE.page ) then wikirequest.WE.page
      else "Unknown page " ^ wikirequest.WE.page
  | WE.Get_text -> Printf.sprintf "%s (editing)" wikirequest.WE.page
  | WE.Get_tree -> unsupported_action
  | WE.Set_text _ -> unsupported_action
  | WE.Insert_text (_, _) -> unsupported_action
  | WE.Remove_text (_, _) -> unsupported_action
;;


let wikicontent_header_from_wikirequest wikirequest = 
  Printf.printf "wikicontent_header_from_wikirequest( ... )\n" ;
  "    <title>"^ (wikicontent_title_from_wikirequest wikirequest ) ^ "</title>\n"
;;


let wikicontent_body_from_wikirequest wikirequest =
  Printf.printf "wikicontent_body_from_wikirequest( ... )\n" ;
  let body_view_fmt = (
    "%s\n" ^^ "<a href=\"/%s/edit\">Edit</a>\n" )
  and body_edit_fmt = ( 
    "<form action=\"/%s/edit\" method=\"post\" >\n" ^^
    "<textarea name=\"content\">%s</textarea><br />\n" ^^
    "<input type=\"submit\" value=\"save\" >\n" ^^
    "<input type=\"submit\" value=\"preview\" >\n" ^^
    "<input type=\"button\" value=\"cancel\" >\n" ^^
    "</form>\n" )
  and body_unknown_fmt = ( "Page %s does not exist.\n" ^^ "" )
  in

  let wiki_html () = 
    if not ( WE.is_empty wikirequest.WE.page ) then 
      WE.handle_request wikirequest
    else 
      Printf.sprintf body_unknown_fmt wikirequest.WE.page
  and wiki_raw () =
    if not ( WE.is_empty wikirequest.WE.page ) then 
      WE.handle_request wikirequest
    else 
      "Write here the content of page " ^ wikirequest.WE.page
  in

  match wikirequest.WE.action with
  | WE.Get_html -> Printf.sprintf body_view_fmt ( wiki_html () ) wikirequest.WE.page
  | WE.Get_text -> Printf.sprintf body_edit_fmt wikirequest.WE.page ( wiki_raw () )
  | WE.Get_tree -> Printf.sprintf body_edit_fmt wikirequest.WE.page ( wiki_raw () )
  | WE.Set_text _ -> Printf.sprintf body_view_fmt ( wiki_html () )
  wikirequest.WE.page
  | WE.Insert_text (_, _) -> Printf.sprintf body_view_fmt ( wiki_html () )
  wikirequest.WE.page
  | WE.Remove_text (_, _) ->Printf.sprintf body_view_fmt ( wiki_html () )
  wikirequest.WE.page
;;


let wikicontent_from_wikirequest wikirequest = 
  Printf.printf "wikicontent_from_wikirequest( %s )\n" 
    (string_of_wikirequest wikirequest)
  ;
  "<html>\n" ^ 
  "  <head>\n" ^
  wikicontent_header_from_wikirequest wikirequest ^
  "  </head>\n" ^
  "  <body>\n" ^
  wikicontent_body_from_wikirequest wikirequest ^
  "  </body>\n" ^
  "</html>\n"
;;



let get_handler request =
  Printf.printf "get_handler( ... )\n" ;
  let wikirequest = wikirequest_from_request request
  in
  let wikicontent = wikicontent_from_wikirequest wikirequest
  in
 (* let wikianswer = handle_request wikirequest
  in *)
  (* convert request to wikirequest *)
  (* 
  let ( filtered_page, filtered_action ) =
    pageaction_from_request request
  in *)
  { HttpAnswer.default_answer with
    HttpTypes.status = HttpTypes.Success HttpTypes.Ok ;
    HttpTypes.aprotocol = request.HttpTypes.rprotocol ; 
    HttpTypes.send_content = true ;
    HttpTypes.content = wikicontent ; (* "Wiki got a GET request for " ^
    wikirequest.page ^ ":" ^ 
    ( string_of_action wikirequest.action ) *)
  }
;;


let head_handler request = 
  Printf.printf "head_handler( ... )\n" ;
  let get_answer = get_handler request
  in
  { get_answer with
    HttpTypes.send_content = false
  }
;;



let post_handler request =
  Printf.printf "post_handler( ... )\n" ;
  let post_answer = get_handler request
  in 
  post_answer
;;


