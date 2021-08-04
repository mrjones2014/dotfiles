# workaround for https://github.com/fish-shell/fish-shell/issues/3481
function fish_vi_cursor; end
function fish_user_key_bindings
  fish_vi_key_bindings
end
