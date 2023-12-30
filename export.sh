#!/bin/bash 

FILENAME=$(basename $1 .org)
TEMPORARY_DIR=/tmp/notes-$(date +%s)-$RANDOM
OUTPUT=./output 
INPUT="$1"

cp -r "$INPUT" $TEMPORARY_DIR

mkdir -p $OUTPUT
mkdir -p $OUTPUT/pdf/
mkdir -p $OUTPUT/html/

silent() {
    $*  >/dev/null 2>&1
    return $? 
}

set -e 
TEMPORARY_DIR=$(readlink -f $TEMPORARY_DIR)
find $TEMPORARY_DIR -maxdepth 1 -type d  | while read mydir; do 

    fullpath=$(readlink -f "$mydir")
    notes_name="${fullpath/$TEMPORARY_DIR\//""}"
    echo Notes for: $notes_name
    if [ -f "$fullpath/notes.org" ]; then 
        cp -r  "$fullpath/"  $TEMPORARY_DIR/temp
        silent emacs -batch \
                        --load ~/.emacs.d/lisp/emacs-htmlize.el \
                        --visit=$TEMPORARY_DIR/temp/notes.org \
                        -f org-latex-export-to-pdf
                        # --eval "(setq enable-local-variables :all)"" \

        silent emacs -batch \
                        --load ~/.emacs.d/lisp/emacs-htmlize.el \
                        --visit=$TEMPORARY_DIR/temp/notes.org \
                        -f org-html-export-to-html
        #                 --eval "(setq enable-local-variables :all)" \
        for ext in pdf html; do 
            mkdir -p "$OUTPUT/$ext/$notes_name"
            mv $TEMPORARY_DIR/temp/notes.$ext "$OUTPUT/$ext/$notes_name/$notes_name.$ext"
            for img_dir in png pngs img; do 
                if [ -d $TEMPORARY_DIR/temp/$img_dir ]; then 
                    cp -r $TEMPORARY_DIR/temp/$img_dir "$OUTPUT/$ext/$notes_name/$img_dir"
                fi 
            done 
        done 
        rm -rf $TEMPORARY_DIR/temp
    fi 
done 

rm -rf $TEMPORARY_DIR
# latex -interaction nonstopmode -halt-on-error -file-line-error $FILENAME.tex
