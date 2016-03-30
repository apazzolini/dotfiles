export NVM_DIR=~/.nvm
nvm() { . "/usr/local/opt/nvm/nvm.sh" ; nvm $@ ; }

#autoload -U add-zsh-hook
#load-nvmrc() {
  #if [[ -f .nvmrc && -r .nvmrc ]]; then
    #nvm use
  #fi
#}
#add-zsh-hook chpwd load-nvmrc
