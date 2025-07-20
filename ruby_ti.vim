" Ruby-TI Vim Plugin
" A modern type checker integration for Ruby with animated feedback

if exists('g:loaded_ruby_ti')
  finish
endif
let g:loaded_ruby_ti = 1

" Load plugin components
runtime! vimrc_themes/autoload/ruby_ti/config.vim
runtime! vimrc_themes/autoload/ruby_ti/state.vim
runtime! vimrc_themes/autoload/ruby_ti/ui.vim
runtime! vimrc_themes/autoload/ruby_ti/animation.vim
runtime! vimrc_themes/autoload/ruby_ti/checker.vim

" Initialize plugin
call ruby_ti#state#init()

" Setup autocommands
augroup RubyTi
  autocmd!
  autocmd BufRead *.* call ruby_ti#state#reset()
  autocmd BufWinEnter *.* call ruby_ti#state#reset()
  autocmd BufWritePost *.rb call ruby_ti#checker#run()
  autocmd BufRead *.rb call ruby_ti#checker#run()
  autocmd BufWinEnter *.rb call ruby_ti#checker#run()
  autocmd CursorMoved *.rb call ruby_ti#ui#show_popup_if_needed()
augroup END

" Define highlights
call ruby_ti#ui#setup_highlights()