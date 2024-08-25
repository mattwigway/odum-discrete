#!/bin/bash

set -ex

# render python files
julia extract_chunks.jl discrete-choice.qmd

# convert to ipynb
for i in *.py; do
    jupytext --to ipynb "$i"
done

# strip # %% from qmd
ggrep --invert-match "# %%" discrete-choice.qmd |\
    gsed -E "s/#\\| filename: (.*).py/#\\| filename: \1.ipynb"/ >\
    discrete-choice-final.qmd
# render
quarto render discrete-choice-final.qmd