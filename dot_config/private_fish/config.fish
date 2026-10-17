set -gx EDITOR nvim
set -gx CARGO_HOME ~/.local/cargo
fish_add_path -g ~/.local/bin ~/.local/cargo/bin ~/npm/bin ~/go/bin

if status is-interactive
	set -g fish_greeting
	fish_vi_key_bindings
	starship init fish | source

	set fish_vi_force_cursor TRUE
	set fish_cursor_default block
	set fish_cursor_insert line
	set fish_cursor_replace_one underscore
	set fish_cursor_visual block

  alias v=nvim
end
