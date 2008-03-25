(* vim: set ts=2 sw=2 et : *)

open WikiEngine;;

type urlhandler_t =
  | Edit
  | View
;;


let string_from_urlhandler = function
  | Edit -> "edit"
  | View -> "view"
;;


let urlhandler_from_action = function
  | Get_html -> View
  | Get_text -> Edit
  | Set_text _ -> Edit
  | Insert_text (_,_) -> Edit (* FIXME *)
  | Remove_text (_,_) -> Edit (* FIXME *)
  | Get_tree -> View (* FIXME *)
;;


let urlhandler_from_string = function
  | "view" -> View
  | "edit" -> Edit
  | _ -> urlhandler_from_action default_action
;;



let get_action_from_urlhandler = function
  | View -> Get_html
  | Edit -> Get_text
;;

let post_action_from_urlhandler text = function
  | View -> Get_html
  | Edit -> Set_text text
;;



let page_from_request request =
  let filter_page page = 
    match page with
    | "" -> default_page
    | _ -> page
  in
  match request.HttpTypes.location with
  | [] -> default_page
  | pg::_ -> filter_page pg
;;


let action_from_request request =
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
;;


let wikirequest_from_request request = { 
  link = request ;
  page = page_from_request request ;
  action = action_from_request request ;
}
;;


let wikicontent_title_from_wikirequest wikirequest =
  let unsupported_action =
    Printf.sprintf "Unsupported action for \"%s\" on page \"%s\"" 
    ( string_of_action wikirequest.action )
    wikirequest.page
  in
  match wikirequest.action with
  | Get_html -> 
      if not ( is_empty wikirequest.page ) then wikirequest.page
      else "Unknown page " ^ wikirequest.page
  | Get_text -> Printf.sprintf "%s (editing)" wikirequest.page
  | Get_tree -> unsupported_action
  | Set_text _ -> unsupported_action
  | Insert_text (_, _) -> unsupported_action
  | Remove_text (_, _) -> unsupported_action
;;


let wikicontent_header_from_wikirequest wikirequest = 
  "    <title>"^ (wikicontent_title_from_wikirequest wikirequest ) ^ "</title>\n"
;;


let wikicontent_body_from_wikirequest wikirequest =
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
    if not ( is_empty wikirequest.page ) then handle_request wikirequest
    else Printf.sprintf body_unknown_fmt wikirequest.page
  and wiki_raw () =
    if not ( is_empty wikirequest.page ) then handle_request wikirequest
    else "Write here the content of page " ^ wikirequest.page
  in

  match wikirequest.action with
  | Get_html -> Printf.sprintf body_view_fmt ( wiki_html () ) wikirequest.page
  | Get_text -> Printf.sprintf body_edit_fmt wikirequest.page ( wiki_raw () )
  | Get_tree -> Printf.sprintf body_edit_fmt wikirequest.page ( wiki_raw () )
  | Set_text _ -> Printf.sprintf body_view_fmt ( wiki_html () ) wikirequest.page
  | Insert_text (_, _) -> Printf.sprintf body_view_fmt ( wiki_html () ) wikirequest.page
  | Remove_text (_, _) ->Printf.sprintf body_view_fmt ( wiki_html () ) wikirequest.page
;;


let wikicontent_from_wikirequest wikirequest = 
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
  let get_answer = get_handler request
  in
  { get_answer with
    HttpTypes.send_content = false
  }
;;



let post_handler request =
  let post_answer = get_handler request
  in 
  post_answer
;;


