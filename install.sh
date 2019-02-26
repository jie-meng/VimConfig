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
  # vim-plug
  if [ ! -f "~/.vim/autoload/plug.vim" ]; then
    curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
      https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  fi
}

main
