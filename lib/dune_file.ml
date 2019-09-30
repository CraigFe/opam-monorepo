open Stdune

module Lang = struct
  type version = int * int

  let compare_version (major, minor) (major', minor') =
    match Int.compare major major' with Eq -> Int.compare minor minor' | _ as ord -> ord

  let pp_version fmt (major, minor) = Format.fprintf fmt "%d.%d" major minor

  let parse_version s =
    let err () = Error (`Msg (Printf.sprintf "Invalid dune lang version: %s" s)) in
    match String.split ~on:'.' s with
    | [ major; minor ] -> (
      match (Int.of_string major, Int.of_string minor) with
      | Some major, Some minor -> Ok (major, minor)
      | _ -> err () )
    | _ -> err ()

  let parse_stanza s =
    let content =
      let open Option.O in
      String.drop_prefix ~prefix:"(" s >>= String.drop_suffix ~suffix:")" >>| fun content ->
      String.split ~on:' ' content
    in
    match content with
    | Some [ "lang"; "dune"; version ] -> parse_version version
    | _ -> Error (`Msg (Printf.sprintf "Invalid lang stanza: %s" s))

  let is_stanza s = String.is_prefix ~prefix:"(lang " s

  let duniverse_minimum_version = (1, 11)

  let stanza version = Format.asprintf "(lang dune %a)" pp_version version
end

module Raw = struct
  let comment s = Printf.sprintf "; %s" s

  let vendored_dirs glob = Printf.sprintf "(vendored_dirs %s)" glob

  let duniverse_dune_content =
    [ comment "This file is generated by duniverse.";
      comment
        "Be aware that it is likely to be overwritten by your next duniverse pull invocation.";
      "";
      vendored_dirs "*"
    ]

  let duniverse_minimum_lang = Lang.stanza Lang.duniverse_minimum_version
end
