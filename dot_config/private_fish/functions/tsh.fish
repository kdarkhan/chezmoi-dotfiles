function tsh --description 'ssh connect and start tmux'
  ssh -o RequestTTY=yes "$argv" tmux -u new -ADs remote
end
