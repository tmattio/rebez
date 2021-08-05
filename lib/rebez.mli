(** Cubic bezier implementation in Reason / OCaml *)

val make : float -> float -> float -> float -> float -> float
(** [make m_x1 m_y1 m_x2 m_y2] returns a function that returns an easing
    function.contents

    {4 Example}

    [|
    let easing = Rebez.make 0. 0.99 0. 0.99;;
    (* `easing` is a function that can receive values from 0.0 to 1.0 *)
    let value = easing 0.01;;  (* 0.512011914581 *)
    |]

    @raise Range_error if m_x1, m_y1, m_x2, m_y2 are not in the range [0, 1] *)
