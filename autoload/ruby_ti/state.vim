" State management for Ruby-TI plugin

" Private state container
let s:state = {}

function! ruby_ti#state#init()
  let s:state = {
    \ 'popup_visible': 0,
    \ 'popup_window_id': -1,
    \ 'typing_position': 0,
    \ 'typing_timer_id': -1,
    \ 'error_info': {
    \   'message': '',
    \   'filename': '',
    \   'line_number': -1,
    \   'file_path': ''
    \ },
    \ 'match_id': -1
  \ }
endfunction

function! ruby_ti#state#get(key, ...)
  let default = a:0 > 0 ? a:1 : v:null
  return get(s:state, a:key, default)
endfunction

function! ruby_ti#state#set(key, value)
  let s:state[a:key] = a:value
endfunction

function! ruby_ti#state#get_error_info(key, ...)
  let default = a:0 > 0 ? a:1 : ''
  return get(s:state['error_info'], a:key, default)
endfunction

function! ruby_ti#state#set_error_info(info_dict)
  call extend(s:state['error_info'], a:info_dict, 'force')
endfunction

function! ruby_ti#state#clear_error_info()
  let s:state['error_info'] = {
    \ 'message': '',
    \ 'filename': '',
    \ 'line_number': -1,
    \ 'file_path': ''
  \ }
endfunction

function! ruby_ti#state#is_popup_visible()
  return s:state['popup_visible']
endfunction

function! ruby_ti#state#get_popup_window_id()
  return s:state['popup_window_id']
endfunction

function! ruby_ti#state#set_popup_window(window_id, visible)
  let s:state['popup_window_id'] = a:window_id
  let s:state['popup_visible'] = a:visible
endfunction

function! ruby_ti#state#get_typing_state()
  return {
    \ 'position': s:state['typing_position'],
    \ 'timer_id': s:state['typing_timer_id']
  \ }
endfunction

function! ruby_ti#state#set_typing_state(position, timer_id)
  let s:state['typing_position'] = a:position
  let s:state['typing_timer_id'] = a:timer_id
endfunction

function! ruby_ti#state#reset_typing_state()
  let s:state['typing_position'] = 0
  let s:state['typing_timer_id'] = -1
endfunction

function! ruby_ti#state#reset()
  " Clear line highlighting
  execute 'match none'
  
  " Close popup if open
  if s:state['popup_visible'] && s:state['popup_window_id'] != -1
    try
      call nvim_win_close(s:state['popup_window_id'], v:true)
    catch
      " Window might already be closed
    endtry
  endif
  
  " Stop animation timer if running
  if s:state['typing_timer_id'] != -1
    call timer_stop(s:state['typing_timer_id'])
  endif
  
  " Reset state
  let s:state['popup_visible'] = 0
  let s:state['popup_window_id'] = -1
  call ruby_ti#state#reset_typing_state()
endfunction