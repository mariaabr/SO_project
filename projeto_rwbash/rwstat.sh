#!/bin/bash

# Maria Rafaela Alves Abrunhosa 107658 (50%)
# Matilde Moital Portugal Sampaio Teixeira 108193 (50%)

# STARTS HERE

# declarations

declare -A arrproc=()
declare -A arrread=()
declare -A arrwrite=()
declare -A arropt=()

sort_reverse=0
order=1
totalreverse=0
totalorder=0
#pid=$(ps -ef | grep 'p' | awk '{print $2}') # ps command is used to list the currently running processes and their PIDs
# along with some other information depends on different options
# -ef restricts the processes running on the system in the standart format
re='^[0-9]+([.][0-9]+)?$'
timepattern="[A-Za-z]{3} ([0-2][1-9]|[3][0-1]) ([0-1][0-9]|[2][0-3]):[0-5][0-9]"

# some validations


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


while getopts ":c:s:e:u:m:M:p:rw" options; do

        if [[ -z "$OPTARG" ]]; then # -z -> string is null, evaluates if the string has zero length
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
            user=${arropt['u']}
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
            if ! [[ $gamamin != 'null' || ${gamamin:0:1} != "-" || $gamamin =~ $re || $gamamin -ge 0 ]]; then
                if [$gamamax -le $gamamin]; then
                    echo "gama máxima menor que gama mínima"
                fi
                echo "o argumento de '-m' é 'null', inválido ou menor que 0"
                exit 1
            fi
            ;;
        p) # numero de processos a visualizar
            numproc=${arropt['p']}
            if ! [[ $numproc =~ $re ]]; then
                echo "o argumento de '-p' tem de ser um número"
                exit 1
            fi
            ;;
        r) # sort reverse
            ((totalreverse++))
            sort_reverse=1
            ;;
        w) # sort nos valores do write
            ((totalorder++))
            order=5
            ;;
        *) # opção inválida
            echo "ERROR: Unknown option"
            exit 1
            ;;
    esac
done


shift $((OPTIND - 1))


# more validations

if [[ $totalreverse -gt 1 ]]; then
    echo "ERROR: incompatible commands (-r > 1)"
    exit 1
fi

if [[ $totalorder -gt 1 ]]; then
    echo "ERROR: incompatible commands (-w > 1)"
    exit 1
fi


# procurar e listar os processos

cd /proc
for process in $(ls | grep -E '^[0-9]+$'); do
    if [[ -r $process/status && -r $process/io ]]; then
        pid=$(cat $process/status | grep -w Pid | tr -dc '0-9' )
                    
        rchar=$(cat $process/io | grep rchar | grep -o -E '[0-9]+') # "|" pipe chains commands together -> takes the output from one command and feeds it to the next as input
        wchar=$(cat $process/io | grep wchar | grep -o -E '[0-9]+')
                

        if [[ $rchar == 0 && $wchar == 0 ]]; then
            continue
        else
            arrread[$pid]=$rchar
            arrwrite[$pid]=$wchar
        fi
    fi
    
done
cd


sleep $segundos


# segunda leitura

cd /proc
for process in $(ls | grep -E '^[0-9]+$'); do
    if [[ -r $process/status && -r $process/io ]]; then
        pid=$(cat $process/status | grep -w Pid | tr -dc '0-9' )

        comm=$(cat $process/comm | tr " " "_") # ir buscar o comm,e retirar os espaços e substituir por '_' nos comm's com 2 nomes

        userproc=$(ps -o user= -p $pid)

        data=$(LC_ALL=EN_us.utf8 ls -ld /proc/$process | awk '{print $6 " " $7 " " $8}')
        data_2=$(date -d "$data" +%s)


        # FILTRAR PROCESSOS COM CONDIÇÕES AQUI

        if [[ -v arropt[u] && ! ${arropt['u']} == $userproc ]]; then # -v tells the shell to run in verbose mode -> is useful
        # in locating the line of the script that as created an error
            continue # se não existir o user escolhido não adiciona à lista
        fi


        if [[ -v arropt[c] && ! $comm =~ ${arropt['c']} ]]; then # escolhe quais "$comm" se adequam ao padrão inserido
            continue
        fi

        
        if [[ -v arropt[s] ]]; then
            if [[ "$data_2" -lt "$start" ]]; then
                continue
            fi
        fi
        
        if [[ -v arropt[e] ]]; then
            if [[ "$data_2" -gt "$end" ]]; then
                continue
            fi
        fi


        if [[ -v arropt[m] ]]; then
            if [[ "$pid" -lt "$gamamin" ]]; then
                continue
            fi
        fi
        
        if [[ -v arropt[M] ]]; then
            if [[ "$pid" -gt "$gamamax" ]]; then
                continue
            fi
        fi

        
        rchar_2=$(cat $process/io | grep rchar | grep -o -E '[0-9]+')
        wchar_2=$(cat $process/io | grep wchar | grep -o -E '[0-9]+')

        subread=$(($rchar_2 - ${arrread[$pid]}))
        subwrite=$(($wchar_2 - ${arrwrite[$pid]}))


        if [[ $subread == 0 && $subwrite == 0 ]]; then
            continue
        else
            rater=$(bc <<<"scale=2; $subread/$segundos")
            ratew=$(bc <<<"scale=2; $subwrite/$segundos")
            rater=${rater/#./0.}
            ratew=${ratew/#./0.}
        fi

        arrproc[$pid]=$(printf "%-20s %-13s %8s %11s %11s %11s %11s %13s\n" "$comm" "$userproc" "$pid" "$subread" "$subwrite" "$rater" "$ratew" "$data")   
    fi
done
cd


# PRINT da tabela

if ! [[ -v arropt[p] ]]; then
    p=${#arrproc[@]} # por default o valor de p é igual ao tamanho do array de todos os processos
    # # -> indica o tamanho do array
else
    p=${arropt['p']} # numero de processos inserido
fi

printf "%-20s %-13s %8s %11s %11s %11s %11s %13s\n" "COMM" "USER" "PID" "READB" "WRITEB" "RATER" "RATEW" "DATE"


# printf '%s \n' "${arrproc[@]}" | head -n $p

if [[ $order -ne 1 && $sort_reverse -eq 0 ]]; then
    printf "%s \n" "${arrproc[@]}" | sort -k${order}rn | head -n $p
elif [[ $order -ne 1 && $sort_reverse -eq 1 ]]; then
    printf "%s \n" "${arrproc[@]}" | sort -k${order}n | head -n $p
elif [[ $order -eq 1 && $sort_reverse -eq 1 ]]; then
    printf "%s \n" "${arrproc[@]}" | sort -k${order} -f -r| head -n $p
else
    printf "%s \n" "${arrproc[@]}" | sort -k${order} -f | head -n $p
fi

# ENDSHERE