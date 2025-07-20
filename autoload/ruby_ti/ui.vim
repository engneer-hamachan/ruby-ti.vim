" UI management for Ruby-TI plugin

function! ruby_ti#ui#setup_highlights()
  let colors = ruby_ti#config#get('colors')
  
  " Warning highlight for echo messages
  execute printf('highlight RubyTiWarning ctermfg=%s guifg=%s cterm=bold gui=bold', 
    \ colors.warning_fg, colors.warning_fg)
  
  " Line highlighting for error lines
  highlight MyMatch cterm=underline
  
  " Popup window highlights
  execute printf('highlight ErrorFloat guibg=%s guifg=%s ctermbg=0 ctermfg=108 cterm=bold gui=bold',
    \ colors.error_bg, colors.error_fg)
  execute printf('highlight ErrorFloatBorder guibg=%s guifg=%s ctermbg=0 ctermfg=198 cterm=bold gui=bold',
    \ colors.error_bg, colors.border_fg)
endfunction

function! ruby_ti#ui#echo_warning(message)
  if empty(a:message)
    return
  endif
  
  echohl RubyTiWarning
  echo 'Error: ' . a:message
  echohl None
endfunction

function! ruby_ti#ui#highlight_error_line(line_number)
  if !ruby_ti#config#get('enable_line_highlighting', 1)
    return
  endif
  
  if a:line_number > 0
    execute 'match MyMatch /\%' . a:line_number . 'l/'
  else
    execute 'match none'
  endif
endfunction

function! ruby_ti#ui#show_popup_if_needed()
  let current_line = line('.')
  let current_file = expand('%:p')
  let error_line = ruby_ti#state#get_error_info('line_number')
  let error_file = ruby_ti#state#get_error_info('file_path')
  
  if exists('g:ruby_ti_debug') && g:ruby_ti_debug
    echo printf('Ruby-TI Debug: line=%d, file=%s, error_line=%d, error_file=%s', 
      \ current_line, current_file, error_line, error_file)
  endif
  
  " Show popup if cursor is on error line in the error file
  if current_line == error_line && current_file == error_file && !ruby_ti#state#is_popup_visible()
    if exists('g:ruby_ti_debug') && g:ruby_ti_debug
      echo 'Ruby-TI Debug: Showing popup'
    endif
    call ruby_ti#ui#show_popup()
  elseif ruby_ti#state#is_popup_visible() && (current_line != error_line || current_file != error_file)
    call ruby_ti#ui#hide_popup()
  endif
endfunction

function! ruby_ti#ui#show_popup()
  let error_message = ruby_ti#state#get_error_info('message')
  let error_filename = ruby_ti#state#get_error_info('filename')
  
  if exists('g:ruby_ti_debug') && g:ruby_ti_debug
    echo printf('Ruby-TI Debug: show_popup called with message="%s", filename="%s"', 
      \ error_message, error_filename)
  endif
  
  if empty(error_message) || empty(error_filename)
    if exists('g:ruby_ti_debug') && g:ruby_ti_debug
      echo 'Ruby-TI Debug: Empty message or filename, not showing popup'
    endif
    return
  endif
  
  " Stop any existing animation
  call ruby_ti#animation#stop()
  
  " Create buffer for popup
  try
    let buffer_id = nvim_create_buf(v:false, v:true)
    if buffer_id == -1
      call ruby_ti#ui#echo_warning('Failed to create popup buffer')
      return
    endif
  catch
    call ruby_ti#ui#echo_warning('nvim_create_buf failed: ' . v:exception)
    return
  endtry
  
  " Calculate popup dimensions
  try
    let dimensions = s:calculate_popup_dimensions(error_message, error_filename)
  catch
    call ruby_ti#ui#echo_warning('Failed to calculate dimensions: ' . v:exception)
    return
  endtry
  
  " Create popup frame
  try
    let frame_content = s:create_popup_frame(dimensions.width, dimensions.inner_width)
  catch
    call ruby_ti#ui#echo_warning('Failed to create frame: ' . v:exception)
    return
  endtry
  
  try
    call nvim_buf_set_lines(buffer_id, 0, -1, v:true, frame_content)
  catch
    call ruby_ti#ui#echo_warning('Failed to set popup content: ' . v:exception)
    return
  endtry
  
  " Configure popup window options
  let config = ruby_ti#config#get('popup_style')
  let popup_options = {
    \ 'relative': 'cursor',
    \ 'width': dimensions.width,
    \ 'height': 5,
    \ 'col': ruby_ti#config#get('popup_offset_col', -2),
    \ 'row': ruby_ti#config#get('popup_offset_row', 1),
    \ 'anchor': 'NW',
    \ 'style': 'minimal',
    \ 'border': 'none'
  \ }
  
  " Open popup window
  try
    let window_id = nvim_open_win(buffer_id, 0, popup_options)
    call nvim_win_set_option(window_id, 'winhl', 'Normal:ErrorFloat,FloatBorder:ErrorFloatBorder')
    call ruby_ti#state#set_popup_window(window_id, 1)
  catch
    call ruby_ti#ui#echo_warning('Failed to open popup window: ' . v:exception)
    return
  endtry
  
  " Start typing animation
  let clean_error = substitute(error_message, '^\s*', '', '')
  let clean_filename = substitute(error_filename, '^\s*', '', '')
  call ruby_ti#animation#start_typing(buffer_id, clean_error, clean_filename, dimensions.inner_width)
endfunction

function! ruby_ti#ui#hide_popup()
  if !ruby_ti#state#is_popup_visible()
    return
  endif
  
  let window_id = ruby_ti#state#get_popup_window_id()
  if window_id != -1
    try
      call nvim_win_close(window_id, v:true)
    catch
      " Window might already be closed
    endtry
  endif
  
  call ruby_ti#animation#stop()
  call ruby_ti#state#set_popup_window(-1, 0)
endfunction

function! s:calculate_popup_dimensions(error_text, file_text)
  let config = ruby_ti#config#get('popup_style')
  let min_width = ruby_ti#config#get('min_popup_width', 40)
  
  " Calculate content widths
  let error_width = len(config.error_symbol . ' ' . a:error_text) + 4
  let file_width = len(config.file_symbol . ' ' . a:file_text) + 4
  let title_width = len(config.title) + 8
  let footer_width = len(config.footer) + 8
  
  " Find maximum width needed
  let content_width = max([error_width, file_width, title_width, footer_width])
  let popup_width = max([content_width, min_width])
  let inner_width = popup_width - 1
  
  return {
    \ 'width': popup_width,
    \ 'inner_width': inner_width
  \ }
endfunction

function! s:create_popup_frame(popup_width, inner_width)
  let config = ruby_ti#config#get('popup_style')
  let chars = config.border_chars
  
  " Create frame components
  let title_padding_length = inner_width - len(config.title) - 1
  let title_padding = title_padding_length > 0 ? repeat(chars.horizontal, title_padding_length) : ''
  
  let header = chars.top_left . chars.horizontal . chars.horizontal . chars.horizontal . ' ' . config.title . ' ' . title_padding . chars.top_right
  
  let footer_content = chars.footer_left . ' ' . config.footer . ' ' . chars.footer_right
  let footer_padding_length = inner_width - len(footer_content) - 14
  let footer_padding = footer_padding_length > 0 ? repeat(chars.horizontal, footer_padding_length) : ''
  let footer_line = chars.bottom_left . footer_padding . footer_content . repeat(chars.horizontal, 10) . chars.bottom_right
  
  let separator = chars.separator_left . repeat(chars.horizontal, inner_width - 1) . chars.separator_right
  
  " Create empty content lines (will be filled by animation)
  let empty_error = chars.vertical . ' ' . config.error_symbol . ' ' . repeat(' ', inner_width - len(config.error_symbol) - 3) . chars.vertical
  let empty_file = chars.vertical . ' ' . config.file_symbol . ' ' . repeat(' ', inner_width - len(config.file_symbol) - 3) . chars.vertical
  
  return [header, empty_error, separator, empty_file, footer_line]
endfunction