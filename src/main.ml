open Batteries

open Ball

let init () = 
  match SC.Server.run_script () with
  | false -> failwith "Ball: SuperCollider server (scsynth) failed to start."
  | true -> 
    let c = SC.Client.make () in
    let _ = at_exit (fun () -> SC.Client.quit_all c)
    in c 

let test_01 () =
  let freq_base = 
    if Array.length Sys.argv > 1 then 
      Int.of_string(Sys.argv.(1)) 
    else 300 
  in
  let c = init () in
  let s = s_sinew c 
  in
  while true do 
    match_xyz (read_line ()) 
    >>| apply_x (bounce_minval freq_base)
    >>| Int.mul 2
    >>| set_freq s
    |> ignore
  done


let () = test_01 ()


