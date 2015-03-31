#! /bin/bash

ocamlbuild -use-ocamlfind -cflag -bin-annot \
    -Is src,lib_sc_src \
    main.native
