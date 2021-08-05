(lang dune 2.0)

(name rebez)

(documentation "https://jchavarri.github.io/rebez/")

(source
 (github jchavarri/rebez))

(license ISC)

(authors "Javier Ch\195\161varri")

(maintainers "Javier Ch\195\161varri")

(generate_opam_files true)

(package
 (name rebez)
 (synopsis "Cubic bezier implementation in Reason / OCaml")
 (description "Cubic bezier implementation in Reason / OCaml")
 (depends
  (ocaml
   (>= 4.08.0))
  dune
  (odoc :with-doc)))
