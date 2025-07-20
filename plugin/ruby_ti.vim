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
  autocmd BufRead *.* call ruby_ti#ui#hide_popup() | call ruby_ti#state#reset()
  autocmd BufWinEnter *.* call ruby_ti#ui#hide_popup() | call ruby_ti#state#reset()
  autocmd BufWritePost *.rb call timer_start(100, function('s:delayed_checker_run'))
  autocmd BufReadPost *.rb call timer_start(200, function('s:delayed_checker_run'))
  autocmd BufWinEnter *.rb call timer_start(300, function('s:delayed_checker_run'))
  autocmd CursorMoved *.rb call timer_start(50, function('s:delayed_popup_check'))
augroup END

" Delayed popup check to avoid immediate empty popups
function! s:delayed_popup_check(timer_id)
  call ruby_ti#ui#show_popup_if_needed()
endfunction

" Delayed checker run to avoid running before file is fully loaded
function! s:delayed_checker_run(timer_id)
  " Only run if file is fully loaded and readable
  if filereadable(expand('%')) && line('$') > 0
    call ruby_ti#checker#run()
  endif
endfunction

