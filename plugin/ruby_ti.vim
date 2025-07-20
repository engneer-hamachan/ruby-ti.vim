" Ruby-TI Vim Plugin
" A modern type checker integration for Ruby with animated feedback

if exists('g:loaded_ruby_ti')
  finish
endif
let g:loaded_ruby_ti = 1

" Plugin components are loaded automatically via autoload mechanism

" Debug: Check if plugin is loading
if exists('g:ruby_ti_debug') && g:ruby_ti_debug
  echo 'Ruby-TI: Plugin loading started'
endif

" Initialize plugin
try
  call ruby_ti#state#init()
  if exists('g:ruby_ti_debug') && g:ruby_ti_debug
    echo 'Ruby-TI: State initialized successfully'
  endif
catch
  echo 'Ruby-TI Error: Failed to initialize state - ' . v:exception
endtry

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
try
  call ruby_ti#ui#setup_highlights()
  if exists('g:ruby_ti_debug') && g:ruby_ti_debug
    echo 'Ruby-TI: Highlights setup successfully'
  endif
catch
  echo 'Ruby-TI Error: Failed to setup highlights - ' . v:exception
endtry

" Debug command to test popup
command! RubyTiTest call s:test_popup()
function! s:test_popup()
  call ruby_ti#state#set_error_info({
    \ 'file_path': expand('%:p'),
    \ 'line_number': line('.'),
    \ 'message': 'Test error message',
    \ 'filename': 'test.rb line:' . line('.')
  \ })
  call ruby_ti#ui#show_popup()
endfunction