# Find all functions
fpath=($DOTFILES/dot/functions $fpath)
autoload -U $DOTFILES/dot/functions/*(:t)
#add each topic folder to fpath so that they can add functions and completion scripts
for topic_folder ($DOTFILES/dot/*) if [ -d $topic_folder ]; then  fpath=($topic_folder $fpath); fi;
#add homebrew's site functions for completion
if test -f '$(brew --prefix)/share/zsh/site-functions/'
then
  fpath=($(brew --prefix)/share/zsh/site-functions/ $fpath)
fi
# Use direnv if it exists
if type direnv &> /dev/null; then
  eval "$(direnv hook zsh)"
fi
