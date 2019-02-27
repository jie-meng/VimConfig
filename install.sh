# /bin/sh

main() {
  # ag
  if brew ls --versions ag > /dev/null; then
    echo "You had install ag"
  else
    brew install ag
  fi

  # ack
  if brew ls --versions ack > /dev/null; then
    echo "You had install ack"
  else
    brew install ack
  fi

  # ctags
  if brew ls --versions ctags > /dev/null; then
      echo "You had install ctags"
  else
      brew install ctags
      alias ctags="`brew --prefix`/bin/ctags"
  fi

  # vim-plug
  if [ ! -f "~/.vim/autoload/plug.vim" ]; then
    curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
      https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  fi
}

main
