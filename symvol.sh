#!/bin/bash
set -e
##
## ==== SymVol ====
## by Francesco Bianco
## contact: info@javanile.org
## license: MIT License
##
WORKDIR=$(echo $PWD)

## Print message
symvol_echo () {
    echo -e "\e[1m>>> $1\e[0m"
    return 0
}

## Print error and exit
symvol_exit () {
    echo -e "\e[31m>>> $2\e[0m"
    exit $1
}

## Validate source argument
symvol_validate_source () {
    [[ -z "$1" ]] && symvol_exit 1 "Missing source directory."
    [[ ! -d "$1" ]] && symvol_exit 1 "Source '$1' seem not a directory."
    [[ ! -f "$1/.symvol" ]] && symvol_exit 1 "Missing '.symvol' file in '$1' source directory."
    [[ ".symvol" != "$(head -n 1 $1/.symvol)" ]] && symvol_exit 1 "Missing '.symvol' as first line of '.symvol' file."
    return 0
}

## Validate target argument
symvol_validate_target () {
    [[ -z "$1" ]] && symvol_exit 1 "Missing target directory"
    [[ ! -d "$1" ]] && symvol_exit 1 "Target '$1' seem not a directory"
    return 0
}

## Move source files to target directory
symvol_move () {
    symvol_validate_source $1
    symvol_validate_target $2
    cd $1;
    while IFS= read item || [[ -n "${item}" ]]; do
	    [[ -z "${item}" ]] && continue
	    [[ ! -f "${item}" ]] && [[ ! -d "${item}" ]] && continue
        [[ -L "${item}" ]] && continue
        [[ "${item::1}" == "#" ]] && continue
        symvol_echo "move: ${item}"
        tar -uvf .symvol.tar ${item}
        rm -fr ${item}
    done < .symvol
    symvol_echo "processing..."
    cd ${WORKDIR};
    mv $1/.symvol.tar $2
    cd $2;
    tar -xvf .symvol.tar;
    rm -f .symvol.tar
    symvol_echo "move done."
    return 0
}

## Safe copy source files to target directory
symvol_copy () {
    symvol_validate_source $1
    symvol_validate_target $2
    [[ -f "$2/.symvol" ]] && symvol_exit 0 "Copy from '$1' was stopped because target '$2' is not empty."
    cd $1;
    while IFS= read item || [[ -n "${item}" ]]; do
	    [[ -z "${item}" ]] && continue
	    [[ ! -f "${item}" ]] && [[ ! -d "${item}" ]] && continue
        [[ -L "${item}" ]] && continue
        [[ "${item::1}" == "#" ]] && continue
        symvol_echo "copy: ${item}"
        tar -uvf .symvol.tar ${item}
    done < .symvol
    symvol_echo "processing..."
    cd ${WORKDIR};
    mv $1/.symvol.tar $2
    cd $2;
    tar -xvf .symvol.tar;
    rm -f .symvol.tar
    symvol_echo "copy done."
    return 0
}

## Force copy source files to target directory
symvol_push () {
    symvol_validate_source $1
    symvol_validate_target $2
    cd $1;
    while IFS= read item || [[ -n "${item}" ]]; do
	    [[ -z "${item}" ]] && continue
	    [[ ! -f "${item}" ]] && [[ ! -d "${item}" ]] && continue
        [[ -L "${item}" ]] && continue
        [[ "${item::1}" == "#" ]] && continue
        symvol_echo "push: ${item}"
        tar -uvf .symvol.tar ${item}
    done < .symvol
    symvol_echo "processing..."
    cd ${WORKDIR};
    mv $1/.symvol.tar $2
    cd $2;
    tar -xvf .symvol.tar;
    rm -f .symvol.tar
    symvol_echo "push done."
    return 0
}

## Create links from source to target
symvol_link () {
    symvol_validate_source $1
    symvol_validate_target $2
    while IFS= read item || [[ -n "${item}" ]]; do
	    [[ -z "${item}" ]] && continue
	    [[ ! -f "$1/${item}" ]] && [[ ! -d "$1/${item}" ]] && continue
	    [[ -h "$(realpath -qs $2/${item})" ]] && continue
	    [[ -L "$2/${item}" ]] && continue
        [[ "${item::1}" == "#" ]] && continue
        symvol_echo "link: ${item}"
        mkdir -p $(dirname $2/${item}) && true
        ln -s $(readlink -f $1/${item}) $(readlink -f $2/${item})
    done < $1/.symvol
    symvol_echo "link done."
    return 0
}

## Remove source files and symlinks
symvol_drop () {
    symvol_validate_source $1
    while IFS= read item || [[ -n "${item}" ]]; do
	    [[ -z "${item}" ]] && continue
	    [[ ! -f "$1/${item}" ]] && [[ ! -d "$1/${item}" ]] && continue
        [[ "${item::1}" == "#" ]] && continue
        symvol_echo "drop: ${item}"
        rm -fr $(realpath -s $1/${item})
    done < $1/.symvol
    symvol_echo "drop done."
    return 0
}

## Show help
symvol_help () {
    echo "==== SymVol ===="
    echo "Manage symbolic links to create persisten volume on docker contanier"
    echo ""
    echo "  symvol [move|copy|push|link] SOURCE TARGET"
    echo "  symvol [drop] SOURCE"
    echo "  symvol [help]"
    echo ""
    echo "  move  Move SOURCE files to TARGET directory"
    echo "  copy  Safe copy SOURCE files to TARGET directory"
    echo "  push  Force copy SOURCE files to TARGET directory"
    echo "  link  Link SOURCE files to TARGET directory"
    echo "  drop  Delete SOURCE files or symlinks"
    echo "  help  Show this help"
    echo ""
    echo "More info at https://github.com/javanile/symvol"
}

## Entrypoint
case $1 in
    drop)  symvol_drop $2; ;;
    move)  symvol_move $2 $3; ;;
    copy)  symvol_copy $2 $3; ;;
    push)  symvol_push $2 $3; ;;
    link)  symvol_link $2 $3; ;;
    help)  symvol_help; ;;
    "")    symvol_exit 1 ">>> Require command: use 'symvol help'."; ;;
    *)     symvol_exit 1 ">>> Unknown command: use 'symvol help'."; ;;
esac
