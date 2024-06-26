#!/usr/bin/env bash
###############################################################################
# util.sh
# This script file contains a collection of useful helper function.
###############################################################################

#
# Debug
# $1 Debug string
# Prints the passed debug string if the $DEBUG is set
#
Debug () {

    if [ "${DEBUG_OUTPUT}" -eq 1 ] ; then
        echo "DEBUG: $@"
    fi

}


## AreArgsValid <Passed parameters array>
# Returns 0 if the passed arguments are valid based on shoesfiles
# configuration.
function AreArgsValid() {

    RetVal=0

    # Used to know when we're no longer parsing flags
    FLAGS_FINISHED=0

    SUBCMD=
    TARGET=

    Debug "AreArgsValid Received $@"

    for ARG in "$@"; do
        Debug "Processing argument $ARG"

        if [ $FLAGS_FINISHED -eq 0 ] && [ ${ARG:0:1} = "-" ]; then
            ARG_LENGTH=${#ARG}
            Debug "Argument string length: $ARG_LENGTH"
            for (( FLAG_IND=1; FLAG_IND < ${#ARG}; FLAG_IND++ )); do
                Debug "At index $FLAG_IND"
                FLAG=${ARG:$FLAG_IND:1}
                Debug "Looking at flag $FLAG"
                case $FLAG in
                    "v")
                        DEBUG_OUTPUT=1
                        echo "Enabling verbose output."
                        ;;
                    *)
                        echo "Unknown flag $FLAG. Ignoring."
                        ;;
                esac
            done
        else
            FLAGS_FINISHED=1
        fi
    done
    return $RetVal;
}


#
# Set up and move .dotfiles directory
# The back up directory does NOT exist by default.
# Its presence indicates an existing backup.
# @depends HOME
# @depends DOTFILES_REPO_DIR Location of the repository
# @depends DOTFILES_DIR Final destination
#
ConfigureDotfilesDir() {

    RETVAL=0
    CONTINUE=1

    # In this context
    BACKUP_DIR=$DOTFILES_REPO_DIR/backup/dotfiles.old

    # If we are running from final destination, no worries.
    if [ "$DOTFILES_REPO_DIR" = "$DOTFILES_DIR" ]; then
        Debug "Already in final destination. Not moving."
        return 0;

    # Otherwise, check if final destination exists
    elif [ -e "$DOTFILES_DIR" ]; then

        # Remember, we have non-final REPO DIR and currently old DOTFILES dir.
        # We want to backup the old DOTFILES, and then move the repo dir into it
        Debug "Dotfiles directory exists and we're not in it."
        # Check if backup directory exi
        if [ -e "$BACKUP_DIR" ]; then
            echo -e "!!! WARNING !!!"
            PROMPT="$BACKUP_DIR exists. Obliterate backup directory? "
            CONTINUE=$(BoolPrompt "$PROMPT")
        fi
    fi

    # Exit if user told us to.
    if [ $CONTINUE -eq 0 ]; then
        echo "Deal with existing installation and/or backup and try again."
        return 1
    else
        # We'll get here regardless of an old dotfiles install; check it's there
        # before trying to delete it
        [ -d "$BACKUP_DIR" ] && echo "Deleting $BACKUP_DIR" && rm -r "$BACKUP_DIR"
    fi

    cd "$HOME"
    mkdir -pv "$BACKUP_DIR"
    # If the repo is not the final location and the final location exists
    if  [ -d "$DOTFILES_DIR"  ]; then
        # Move existing dotfiles dir to a backup dir
        # A link will not be moved
        mv -v "$HOME/.dotfiles" "$BACKUP_DIR"
    fi

    # Move repo to final destination
    mv -v "$DOTFILES_REPO_DIR" "$DOTFILES_DIR"
    cd "$HOME/.dotfiles"

    return $RETVAL
}

#
# BooleanPrompt
# Prompts the user for a yes or no answer
# @param $1 takes in a string prompt
# 0 on true or 1 on false
#
BoolPrompt() {

DONE=0
while [ ! $DONE = 1 ]; do
    read -p "$1 [Y/n]: " INPUT; # prompt
    INPUT=$(echo "$INPUT" | tr '[A-Z]' '[a-z]') # make lowercase
    [[ ( $INPUT = "y" || $INPUT = "n" ) ]] && DONE=1
done;
[[ $INPUT = "n" ]] # logic's a bitch
echo $?
}

#
# EmailPrompt
# Prompts the user for an email string
# @param $1 takes a string prompt
# 0 for matching string, 1 for unmatch
#
EmailPrompt() {
DONE=0
while [ ! $DONE = 1 ]; do
    read -p "$1" INPUT; # prompt
    if [[ "$INPUT" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$ ]]; then
    DONE=1
fi
    done
    echo $INPUT;
}

#
# $0 Source folder
# $1 Destination folder (into which source should be installed)
InstallDir() {

    local SOURCE_DIR="$1"
    local TARGET_DIR="$2"

    for NEW_FILE_PATH in $(find $SOURCE_DIR -maxdepth 1 -mindepth 1); do

	echo "Installing $NEW_FILE_PATH to $TARGET_DIR";

        # If file, just install it
        [ -f $NEW_FILE_PATH ] &&
            InstallFiles $NEW_FILE_PATH $TARGET_DIR;

        # If directory, create the destination if it doesn't exist, and
        # make recursive call
        if [ -d $NEW_FILE_PATH ]; then
            NEW_FOLDER_PATH="$TARGET_DIR/$(basename $NEW_FILE_PATH)";
            mkdir -p $NEW_FOLDER_PATH;
            InstallDir "$NEW_FILE_PATH" "$NEW_FOLDER_PATH";
        fi;

    done;

}

#
# InstallFiles
# Installs the passed file or directory into the passed location,
# backing up the file already at the destination if it exists.
# The passed destination is assumed to be prepended with $HOME
# @param $0 Path to new source file to install
# @param $1 Destination path, filename or target NOT included
# @depends HOME
# @depends DOTFILES_BACKUP Storage location for any existing dotfiles
# @depends PKG_DIR Directory of configuration files to be linked from $HOME
#
# @note While reading what this function does, remember that a directory is
# also a type of file
#
InstallFiles() {

    RETVAL=0
    NEW_FILE_PATH="$1" # Location of original source file
    NEW_FILE_NAME=$(basename "$NEW_FILE_PATH")
    DEST_PATH=$2
    CONTINUE=1

    Debug "Looking to install $NEW_FILE_PATH at $DEST_PATH"
    Debug "File name itself is $NEW_FILE_NAME"

    # Check if file exists at destination
    if [ -e "$DEST_PATH/$NEW_FILE_NAME" -o -L "$DEST_PATH/$NEW_FILE_NAME" ];
    then

        # account for when destination exists and already is symlink to dotfiles
        if [ -L "$DEST_PATH/$NEW_FILE_NAME" ]; then
            Debug "Link exists at $DEST_PATH/$NEW_FILE_NAME..."
            LINKPATH=$(readlink "$DEST_PATH/$NEW_FILE_NAME")
            if [ $LINKPATH = $NEW_FILE_PATH ]; then
                Debug "File is already installed."
                CONTINUE=0
            fi

            # Account for a broken link
            # Because only I would create a scenario in which this check is
            # necssary
            if [ ! -e "$DEST_PATH/$NEW_FILE_NAME" ]; then
                echo "WARNING: broken symlink exists at destination $DEST_PATH/$NEW_FILE_NAME"
                PROMPT="Can I delete it? "
                DELETE_BROKEN_LINK=$(BoolPrompt "$PROMPT")
                if [ $DELETE_BROKEN_LINK -eq 1 ]; then
                    echo "Deleting broken link: $DEST_PATH/$NEW_FILE_NAME"
                    rm $DEST_PATH/$NEW_FILE_NAME
                else
                    echo "Stopping neovim install. Please fix/remove broken link and try again."
                    CONTINUE=0
                fi
            fi
        fi

        # Check if file with this name already exists in backup
        if [ $CONTINUE -eq 1 ] && [ -e "$DOTFILES_BACKUP/$NEW_FILE_NAME" ]; then
            echo -e "!!! WARNING !!!"
            PROMPT="$DOTFILES_BACKUP/$NEW_FILE_NAME exists. Obliterate backup? "
            CONTINUE=$(BoolPrompt "$PROMPT")
        fi

        # Delete backup if directed and necessary
        Debug "Seeing if $DOTFILES_BACKUP/$NEW_FILE_NAME exists..."
        if  [ -e "$DOTFILES_BACKUP/$NEW_FILE_NAME" ]; then
            if [ $CONTINUE -eq 1 ]; then
                echo "Deleting $DOTFILES_BACKUP/$NEW_FILE_NAME"
                rm -r "$DOTFILES_BACKUP/$NEW_FILE_NAME"
            else
                echo "Take care of existing backup or destination and try again."
                RETVAL=1
            fi
        fi
    fi

    # Exit if user told us to
    if [ $CONTINUE -eq 1 ]; then

        # Back up
        Debug "Seeing if $DEST_PATH/$NEW_FILE_NAME exists..."
        if [ -e "$DEST_PATH/$NEW_FILE_NAME" ]; then
            Debug "Moving existing $DEST_PATH/$NEW_FILE_NAME to $DOTFILES_BACKUP"
            mv -v "$DEST_PATH/$NEW_FILE_NAME" "$DOTFILES_BACKUP"
        fi

        # Install
        ln -sv "$NEW_FILE_PATH" "$DEST_PATH/$NEW_FILE_NAME"
    fi

    return $RETVAL
}

prereqs_installed() {

    return $(BoolPrompt)

}
