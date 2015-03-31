
open Batteries

module S = SC.Synth

let sleep t = Lwt_main.run (Lwt_unix.sleep t)

(**matching on text-output from 'imu'*)
let match_xyz s = 
  let int = Int.of_string in
  match s with
  | <:re< [" \t"]* 
     "X: " (["0"-"9""-"]+ as x) " " 
     "Y: " (["0"-"9""-"]+ as y) " " 
     "Z: " (["0"-"9""-"]+ as z) 
    >> -> Some (int x, int y, int z)
  | _ -> None

let read_next () =
  let open IO in
  let b = Buffer.create 25 
  and stop = ref false in
  let looking_for = function 
    |'X'..'Z'|':'|' '|'0'..'9'|'-' -> true 
    | _ -> false in
  while not !stop do
    let c_opt = try Some (read stdin) with _ -> None in
    match c_opt with
    | Some c -> 
      if looking_for c then
        Buffer.add_char b c
      else 
        stop := true
    | None -> stop := true
  done;
  Buffer.contents b

let test = function
  | Some (x, y, z) -> Printf.printf "x = %d, y = %d, z = %d\n" x y z
  | None -> print_endline "No values were found"

let s_sinew c = S.synth c "sinew" [] 

let set_freq s v = S.set s [("freq", `I v)]

let apply_x f (x, _, _) = f x

let bounce_minval n x = if x < n then (Int.abs (x-n)) + n else x

let test_x = function 
    Some v -> Printf.printf "mapped x: %d\n" v
  | None -> print_endline "failed input"

let ( >>= ) = Option.bind
and ( >>| ) x f = Option.map f x

let _ =

  let freq_base = 
    if Array.length Sys.argv > 1 then 
      Int.of_string(Sys.argv.(1)) 
    else 300 
  in
  let _ = SC.Server.run_script () in 
  let _ = sleep 10. in 
  let c = SC.Client.make () in
  let s = s_sinew c in
  at_exit (fun () -> SC.Client.quit_all c);

  while true do
    match_xyz (read_line ()) 
    >>| apply_x (bounce_minval freq_base)
    >>| Int.mul 2
    >>| set_freq s
    |> ignore
  done;



