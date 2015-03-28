
open Batteries

module S = SC.Synth

let sleep t = Lwt_main.run (Lwt_unix.sleep t)

(**matching on text-output from 'imu'*)
let match_xyz s = 
  let int = Int.of_string in
  match s with
  | <:re< [" \t"]* 
     "X: " (["0"-"9""-"]* as x) " " 
     "Y: " (["0"-"9""-"]* as y) " " 
     "Z: " (["0"-"9""-"]* as z) 
    >> -> Some (int x, int y, int z)
  | _ -> None

let action = function
  | Some (x, y, z) -> Printf.printf "x = %d, y = %d, z = %d\n" x y z
  | None -> print_endline "No values were found"


let _ =
  (match_xyz " X: -1000 aaaaa" |> action);
  match_xyz " X: -1000 Y: -323 Z: 02020" |> action 
