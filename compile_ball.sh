#! /bin/bash

ocamlbuild -use-ocamlfind -cflag -bin-annot \
    -Is src,lib_sc_src,lib_core-rand00 \
    ball.native
