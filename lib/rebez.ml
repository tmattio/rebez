exception Range_error of string

let newton_iterations = 4

let newton_min_slope = 0.001

let subdivision_precision = 0.0000001

let subdivision_max_iterations = 10

let k_spline_table_size = 11

let k_sample_step_size = 1.0 /. (float_of_int k_spline_table_size -. 1.0)

let a a_a1 a_a2 = 1.0 -. (3.0 *. a_a2) +. (3.0 *. a_a1)

let b a_a1 a_a2 = (3.0 *. a_a2) -. (6.0 *. a_a1)

let c a_a1 = 3.0 *. a_a1

let calc_bezier aT a_a1 a_a2 =
  ((((a a_a1 a_a2 *. aT) +. b a_a1 a_a2) *. aT) +. c a_a1) *. aT

let get_slope aT a_a1 a_a2 =
  (3.0 *. a a_a1 a_a2 *. aT *. aT) +. (2.0 *. b a_a1 a_a2 *. aT) +. c a_a1

let binary_subdivide a_x a_a a_b m_x1 m_x2 =
  let rec subdivide i a_a a_b =
    let current_t = a_a +. ((a_b -. a_a) /. 2.0) in
    let current_x = calc_bezier current_t m_x1 m_x2 -. a_x in
    let continue =
      abs_float current_x > subdivision_precision
      && i + 1 < subdivision_max_iterations
    in
    if continue then
      match current_x > 0.0 with
      | true -> subdivide (i + 1) a_a current_t
      | false -> subdivide (i + 1) current_t a_b
    else current_t
  in

  subdivide 0 a_a a_b

let newton_raphson_iterate a_x aGuessT m_x1 m_x2 =
  let rec newton guess attempts =
    let current_slope = get_slope guess m_x1 m_x2 in
    let good_enough = current_slope = 0.0 in
    if good_enough || attempts == newton_iterations - 1 then guess
    else
      let bez = calc_bezier guess m_x1 m_x2 in
      let current_x = bez -. a_x in
      let new_guess = guess -. (current_x /. current_slope) in
      newton new_guess (attempts + 1)
  in

  newton aGuessT 0

let linear_easing x = x

let make_easing m_x1 m_y1 m_x2 m_y2 =
  let sample_values = Array.make k_spline_table_size 0. in
  for i = 0 to k_spline_table_size - 1 do
    sample_values.(i) <-
      calc_bezier (float_of_int i *. k_sample_step_size) m_x1 m_x2
  done;
  let get_t_for_x a_x =
    let last_sample = k_spline_table_size - 1 in
    let rec get_current_sample current_sample interval_start =
      match
        current_sample != last_sample && sample_values.(current_sample) <= a_x
      with
      | true ->
          get_current_sample (current_sample + 1)
            (interval_start +. k_sample_step_size)
      | false -> (current_sample - 1, interval_start)
    in
    let current_sample, interval_start = get_current_sample 1 0.0 in
    let dist =
      (a_x -. sample_values.(current_sample))
      /. (sample_values.(current_sample + 1) -. sample_values.(current_sample))
    in
    let guess_for_t = interval_start +. (dist *. k_sample_step_size) in
    let initial_slope = get_slope guess_for_t m_x1 m_x2 in
    if initial_slope >= newton_min_slope then
      newton_raphson_iterate a_x guess_for_t m_x1 m_x2
    else if initial_slope == 0.0 then guess_for_t
    else
      binary_subdivide a_x interval_start
        (interval_start +. k_sample_step_size)
        m_x1 m_x2
  in

  let easing x =
    match x with
    | 0. -> 0.
    | 1. -> 1.
    | _ -> calc_bezier (get_t_for_x x) m_y1 m_y2
  in
  easing

let make m_x1 m_y1 m_x2 m_y2 =
  if not (0. <= m_x1 && m_x1 <= 1. && 0. <= m_x2 && m_x2 <= 1.) then
    raise (Range_error "bezier x values must be in [0, 1] range");
  if m_x1 == m_y1 && m_x2 == m_y2 then linear_easing
  else make_easing m_x1 m_y1 m_x2 m_y2
