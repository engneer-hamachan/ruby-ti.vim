" Type checker integration for Ruby-TI plugin

function! ruby_ti#checker#run()
  " Reset UI state
  call ruby_ti#ui#highlight_error_line(-1)
  call ruby_ti#state#clear_error_info()
  
  " Get current file path
  let file_path = expand('%')
  if empty(file_path)
    return
  endif
  
  " Validate file exists and is readable
  if !filereadable(file_path)
    call ruby_ti#ui#echo_warning('File is not readable: ' . file_path)
    return
  endif
  
  " Get checker command
  let command = ruby_ti#config#get('checker_command', 'ti')
  
  " Check if command exists
  if !executable(command)
    call ruby_ti#ui#echo_warning('Type checker command not found: ' . command . '. Please install Ruby-TI or set g:ruby_ti_config.checker_command')
    return
  endif
  
  " Start type checking job
  let job_options = {
    \ 'on_stdout': function('s:on_checker_complete'),
    \ 'on_stderr': function('s:on_checker_complete'),
    \ 'on_exit': function('s:on_checker_exit'),
    \ 'stdout_buffered': v:true,
    \ 'stderr_buffered': v:true,
    \ 'cwd': getcwd()
  \ }
  
  try
    let job_id = jobstart([command, file_path], job_options)
    if job_id <= 0
      call ruby_ti#ui#echo_warning('Failed to start type checker: ' . command)
    endif
  catch
    call ruby_ti#ui#echo_warning('Error starting type checker: ' . v:exception)
  endtry
endfunction

function! s:on_checker_complete(job_id, data, event)
  let output = a:data
  let current_file = expand('%@:p')
  
  " Skip if no meaningful output
  if empty(output) || output ==# "\n"
    return
  endif
  
  " Parse checker output
  let error_info = s:parse_checker_output(output)
  if empty(error_info)
    return
  endif
  
  " Store error information
  call ruby_ti#state#set_error_info(error_info)
  
  if exists('g:ruby_ti_debug') && g:ruby_ti_debug
    echo printf('Ruby-TI Debug: Error stored - line=%d, file=%s, message=%s', 
      \ error_info.line_number, error_info.file_path, error_info.message)
  endif
  
  " Skip status line message display
  
  " Apply visual feedback if error is in current file
  if current_file ==# error_info.file_path
    call ruby_ti#ui#highlight_error_line(error_info.line_number)
    
    " Show popup if cursor is on error line
    let current_line = line('.')
    if current_line == error_info.line_number
      call ruby_ti#ui#show_popup()
    endif
  endif
endfunction

function! s:on_checker_exit(job_id, exit_code, event)
  " Handle job completion if needed
  " Currently no special handling required
endfunction

function! s:parse_checker_output(output)
  " Parse format: "file_path::line_number::error_message"
  let parts = split(a:output, '::')
  
  if len(parts) < 3
    " Invalid format, try to extract what we can
    return {}
  endif
  
  let file_path = s:sanitize_string(parts[0])
  let line_number = s:parse_line_number(parts[1])
  let error_message = s:sanitize_string(parts[2])
  
  " Validate parsed data
  if empty(file_path) || line_number <= 0 || empty(error_message)
    return {}
  endif
  
  " Create filename display (basename + line number)
  let filename_display = fnamemodify(file_path, ':t') . ' line:' . line_number
  
  return {
    \ 'file_path': file_path,
    \ 'line_number': line_number,
    \ 'message': error_message,
    \ 'filename': filename_display
  \ }
endfunction

function! s:sanitize_string(str)
  " Remove leading/trailing whitespace and newlines
  return substitute(substitute(a:str, '^\s*', '', ''), '\s*$', '', '')
endfunction

function! s:parse_line_number(str)
  let cleaned = s:sanitize_string(a:str)
  let number = str2nr(cleaned)
  return number > 0 ? number : -1
endfunction
