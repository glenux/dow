
module StringMap = Map.Make(String)


let wiki = ref StringMap.empty


let create page = 
        (* add an empty page in the wiki *)
        wiki := StringMap.add page "new page" !wiki


let view page = 
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
                "<a href=\"" ^ page ^ "/edit\">Edit</a>"
        else
                "<h1>Unknown page " ^ page ^ "</h1>" ^
                "<p>Would you like to create it ?</p>" ^
                "<a href=\"" ^ page ^ "/edit\">Edit</a>"



let edit page = 
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
        "<a href=\"" ^ page ^ "/edit\">Edit</a>"


let render location =
        let handle_page_action page action = 
                Printf.printf "<-- WIKI: page=[%s] action=[%s]\n" page action ; 
                flush stdout ;
                match action with
                | "edit" -> edit page
                | "view" -> view page
                | _ -> view page
        in

        Printf.printf "<-- WIKI/RAW: [%s]\n" location ;
        flush stdout ;
        try 
                Scanf.sscanf location "/%[a-zA-Z]/%[a-z]" handle_page_action
        with
        | End_of_file -> 
                        Printf.printf "<-- WIKI: EOF [%s]\n" location;
                        flush stdout ;
                        view location 


