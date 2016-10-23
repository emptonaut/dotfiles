#!/bin/bash
###############################################################################
# %name%.sh
# 
###############################################################################

#
# This function installs %name% using INSTALLER_CMD defined
# in the context this function is called.
# 
# @param none
# @return 0 on success, error code on fail
#
Install () {


    return 0
} 

#
# This function configures %name% using defined DOTFILES_DIR in the
# context this function is called. In addition to linking any config files 
# sourced in the home directory to source files configured in DOTFILES_DIR,
# this function should configure any plugins.
#
# @param none
# @return 0 on success, error code on fail
#
Configure () {


    return 0
}


