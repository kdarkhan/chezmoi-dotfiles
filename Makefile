apply-interactive:
	chezmoi -S . apply --verbose --interactive

apply:
	chezmoi -S . apply --verbose

stylua-format:
	stylua --config-path=stylua.toml dot_config/nvim/ -g '*.lua'

diff:
	chezmoi -S . diff

re-add:
	chezmoi -S . re-add
