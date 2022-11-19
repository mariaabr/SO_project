#!/bin/bash
# Maria Rafaela Alves Abrunhosa 107658 (50%)
# Matilde Moital Portugal Sampaio Teixeira 108193 (50%)

if (($# == 0)); then # ou switch casa
    echo "Please, insert some arguments"
    exit
fi

while getopts ":c:s:e:u:m:M:p:rw" options; do
    case "$options" in
        c)
            ;;
        s)
            ;;
        e)
            ;;
        u)
            ;;
        m)
            ;;
        M)
            ;;
        p)
            ;;
        r)
            ;;
        w)
            ;;
        *)
            ;;
    esac
done
shift $((OPTIND - 1))









# Validações

if 
    (...)
fi









# PRINT da tabela
# printf("%-15s %-13s %8s %11s %11s %11s %11s %13s %13s %13s\n" "COMM", "USER", "PID", "READB", "WRITEB", "RATER", "RATEW", "DATE")
# printf("%-15s %-13s %8s %11s %11s %11s %11s %13s %13s %13s\n" COISAS)