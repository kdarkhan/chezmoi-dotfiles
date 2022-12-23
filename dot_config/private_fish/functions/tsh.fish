function tsh --description 'ssh connect and start tmux'
    if count $argv > /dev/null
      ssh -o RequestTTY=yes "$argv" tmux -u new -ADs remote
    else
      echo (set_color red)'error: please provide the host'(set_color normal)
      return 1
    end
end
