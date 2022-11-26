#!/bin/bash
# Maria Rafaela Alves Abrunhosa 107658 (50%)
# Matilde Moital Portugal Sampaio Teixeira 108193 (50%)

# STARTS HERE

# declarations

declare -A arrproc=()
declare -A arrcomms=()
declare -A arrusers=()
declare -A arrread=()
declare -A arrwrite=()
declare -A arropt=()

sort_reverse=""
i=0
pid=$(ps -ef | grep 'p' | awk '{print $2}') # ps command is used to list the currently running processes and their PIDs
# along with some other information depends on different options
# -ef restricts the processes running on the system in the standart format
re='^[0-9]+([.][0-9]+)?$'
timepattern="[A-Za-z]{3} ([0-2][1-9]|[3][0-1]) ([0-1][0-9]|[2][0-3]):[0-5][0-9]"

# validations

# if 
#     (...)
# fi

if [[ -n $pid ]]; then # -n evaluates the expressions in bash -> tests the string
# next to it and evaluates it as "True" if string is not empty
    echo ""
else
    echo "ERROR: Cannot find any"
fi



if (($# == 0)); then
    echo "Please, insert some arguments"
    exit
fi



if [[ ${@: -1} =~ $re ]]; then
    if [[ ${@: -1} -ge 0 ]]; then
        segundos=${@: -1}
    fi
else
    echo "insert some seconds or the number you have chose is not a positive number"
    exit 1
fi

# printf "%d -> o valor dos segundos\n" "$segundos"



while getopts ":c:s:e:u:m:M:p:rw" options; do

    if [[ -z "$OPTARG" ]]; then
        arropt[$options]="null"
    else
        arropt[$options]=${OPTARG} # $OPTARG gets the value of the argument "linked" to the option
    fi

    case "$options" in
        c) # seleção dos processos a visualizar através de uma expressão regular
            expreg=${arropt['c']}
            if [[ $expreg == 'null'|| ${expreg:0:1} == "-" || ${expreg} =~ $re ]]; then
                echo "é necessário que a seleção de processos seja feita através de uma expressão regular"
                echo "o argumento de '-c' é 'null' ou inválido"
                exit 1
            fi
            ;;
        s) # especificação do período temporal - data mínima
            datemin=${arropt['s']}
            if [[ $datemin == 'null' || ${datemin:0:1} == "-" || ! "${datemin}" =~ $timepattern ]]; then
                echo "o argumento de '-s' é 'null' ou inválido"
                exit 1
            fi
            start=$(date -d "$datemin" +%s);
            ;;
        e) # especificação do período temporal - data máxima
            datemax=${arropt['e']}
            if [[ $datemax == 'null' || ${datemax:0:1} == "-" || ! "${datemax}" =~ $timepattern ]]; then
                echo "o argumento de '-e' é 'null' ou inválido"
                exit 1
            fi
            end=$(date -d "$datemax" +%s);
            ;;
        u) # seleção realizada pelo nome de utilizador
            user=${arropt['c']}
            echo "estou no user!"
            if [[ $user == 'null' || ${user:0:1} == "-" || ${user} =~ $re ]]; then
                echo "o argumento de '-u' é 'null' ou inválido"
                exit 1
            fi
            ;;
        m) # gama de pids - gama mínima # FAZER AS GAMAS!!!
            gamamin=${arropt['m']}
            if ! [[ $gamamin != 'null' || ${gamamin:0:1} != "-" || $gamamin =~ $re || $gamamin -ge 0 ]]; then
                echo "o argumento de '-m' é 'null', inválido ou menor que 0"
                exit 1
            fi
            ;;
        M) # gama de pids - gama máxima
            gamamax=${arropt['M']}
            if ! [[ $gamamax != 'null' || ${gamamax:0:1} != "-" || $gamamax =~ $re || $gamamax -ge 0 ]]; then
                echo "o argumento de '-m' é 'null', inválido ou menor que 0"
                exit 1
            fi
            ;;
        p) # numero de processos a visualizar
            numproc=${arropt['p']}
            echo "estou no p!"
            if ! [[ $numproc =~ $re ]]; then
                echo "o argumento de '-p' é 'null' tem de ser um número"
                exit 1
            fi
            ;;
        r) # sort reverse
            sort_reverse="-r";
            echo "cucumber"
            ;;
        w) # sort nos valores do write
            echo "cucumber"
            ;;
        *) # opção inválida
            echo "ERROR: Unknown option"
            exit 1
            ;;
    esac
done
shift $((OPTIND - 1))



# procurar e listar os processos

cd /proc
for process in $(ls | grep -E '^[0-9]+$'); do
    if [[ -r $process/status && -r $process/io ]]; then
        arrproc[i]=$process
        printf "%d -> o valor do proc (pid) \n" "$process"

        cd /proc/$process
        comm=$(cat comm)
        arrcomms[i]=$comm
        printf "%s -> o valor do comm \n" "$comm"

        userproc=$(ls -ld | awk '{print $3}')
        arrusers[i]=$userproc
        printf "%s -> o valor do user \n" "$userproc"

        rchar=$(cat /proc/$process/io | grep rchar | grep -o -E '[0-9]+') # "|" pipe chains commands together -> takes the output from one command and feeds it to the next as input
        wchar=$(cat /proc/$process/io | grep wchar | grep -o -E '[0-9]+')
                
        # echo "estás aqui, patinho?"
        printf "%d -> o valor do rchar \n" "$rchar"
        printf "%d -> o valor do wchar \n" "$wchar"

        arrread[i]=$rchar
        arrwrite[i]=$wchar

        i=$((i+1))
    fi
done
cd




# sleep $segundos



# PRINT da tabela
for i in $arrproc[@]; do
    echo "cucumber"
    printf "%-15s %-13s %8s %11s %11s %11s %11s %13s %13s %13s\n" "COMM" "USER" "PID" "READB" "WRITEB" "RATER" "RATEW" "DATE"
    printf "%-15s %-13s %8s %11s %11s %11s %11s %13s %13s %13s\n" "${arrcomms[i]}" "${arrusers[i]}" "${arrproc[i]}" "${arrread[i]}" "${arrwrite[i]}" "rater" "raterw" "COISAS"
done




# ENDS HERE