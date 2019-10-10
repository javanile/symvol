#!/bin/bash
set -e
WORKDIR=$(echo $PWD)

##
symvol_exit () {
    echo $1
    exit 1
}

##
symvol_validate_source () {
    [[ -z "$1" ]] && symvol_exit "Source folder required"
    [[ ! -d "$1" ]] && symvol_exit "Source need to be a directory"
    [[ ! -f "$1/.symvol" ]] && symvol_exit "Missing .symvol file in source"
    [[ ".symvol" != "$(head -n 1 $1/.symvol)" ]] && symvol_exit "First line of .symvol need to be .symvol"
    return 0
}

##
symvol_validate_target () {
    [[ -z "$1" ]] && symvol_exit "Target folder required"
    [[ ! -d "$1" ]] && symvol_exit "Target need to be a directory"
    return 0
}

##
symvol_move () {
    symvol_validate_source $1
    symvol_validate_target $2
    cd $1;
    while IFS= read item || [[ -n "${item}" ]]; do
	    [[ -z "${item}" ]] && continue
	    [[ ! -f "${item}" ]] && [[ ! -d "${item}" ]] && continue
        [[ -L "${item}" ]] && continue
        echo ">>> move: ${item}"
        tar -uvf .symvol.tar ${item}
        rm -fr ${item}
    done < .symvol
    echo ">>> update..."
    cd ${WORKDIR};
    mv $1/.symvol.tar $2
    cd $2;
    tar -xvf .symvol.tar;
    rm -f .symvol.tar
    echo ">>> move done."
    return 0
}

##
symvol_link () {
    symvol_validate_source $1
    symvol_validate_target $2
    while IFS= read item || [[ -n "${item}" ]]; do
	    [[ -z "$1/${item}" ]] && continue
	    [[ ! -f "$1/${item}" ]] && [[ ! -d "$1/${item}" ]] && continue
	    [[ -L "$2/${item}" ]] && continue
        echo ">>> link: ${item}"
        mkdir -p $(dirname $2/${item}) && true
        ln -s $(readlink -f $1/${item}) $(readlink -f $2/${item})
    done < $1/.symvol
    echo ">>> link done."
    return 0
}

##
symvol_drop () {
    symvol_validate_source $1
    while IFS= read item || [[ -n "${item}" ]]; do
	    [[ -z "$1/${item}" ]] && continue
	    [[ ! -f "$1/${item}" ]] && [[ ! -d "$1/${item}" ]] && continue
        echo ">>> drop: ${item}"
        rm -fr $1/${item}
    done < $1/.symvol
    echo ">>> drop done."
    return 0
}

##
case $1 in
    drop)  symvol_drop $2; ;;
    move)  symvol_move $2 $3; ;;
    link)  symvol_link $2 $3; ;;
    "")    symvol_exit "Command required type: move"; ;;
    *)     symvol_exit "Unknown command type: move"; ;;
esac
