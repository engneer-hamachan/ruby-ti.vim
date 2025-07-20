" Ruby-TI Vim Plugin
" A modern type checker integration for Ruby with animated feedback

if exists('g:loaded_ruby_ti')
  finish
endif
let g:loaded_ruby_ti = 1

" Initialize plugin with deferred setup
function! s:initialize_ruby_ti()
  try
    call ruby_ti#state#init()
    
    " Apply user configuration if exists
    if exists('g:ruby_ti_config')
      call ruby_ti#config#update(g:ruby_ti_config)
    endif
    
    " Setup highlights
    call ruby_ti#ui#setup_highlights()
  catch
    echo 'Ruby-TI Error: Failed to initialize - ' . v:exception
  endtry
endfunction

" Defer initialization until VimEnter
autocmd VimEnter * call s:initialize_ruby_ti()

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

" Debug command to show config
command! RubyTiConfig call s:show_config()
function! s:show_config()
  echo 'enable_line_highlighting: ' . ruby_ti#config#get('enable_line_highlighting', 1)
  echo 'animation_speed: ' . ruby_ti#config#get('animation_speed', 7)
  if exists('g:ruby_ti_config')
    echo 'g:ruby_ti_config: ' . string(g:ruby_ti_config)
  endif
endfunction