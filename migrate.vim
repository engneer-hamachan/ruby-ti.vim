" Migration helper for Ruby-TI plugin refactoring
" This script helps users transition from the old monolithic version

function! RubyTiMigrate()
  echo "Ruby-TI Plugin Migration Helper"
  echo "==============================="
  echo ""
  
  " Check if old version exists
  let old_file = expand('%:h') . '/type_animation_vimrc'
  if filereadable(old_file)
    echo "✓ Found old plugin file: " . old_file
    
    " Offer to backup old version
    let backup_choice = input("Create backup of old version? (y/n): ")
    if backup_choice ==# 'y' || backup_choice ==# 'Y'
      let backup_file = old_file . '.backup'
      execute 'silent !cp ' . shellescape(old_file) . ' ' . shellescape(backup_file)
      echo "✓ Backup created: " . backup_file
    endif
    echo ""
  else
    echo "ℹ No old plugin file found"
    echo ""
  endif
  
  " Check for new modular files
  let plugin_dir = expand('%:h')
  let autoload_dir = plugin_dir . '/autoload/ruby_ti'
  
  echo "Checking new plugin structure:"
  
  let required_files = [
    \ 'ruby_ti.vim',
    \ 'autoload/ruby_ti/config.vim',
    \ 'autoload/ruby_ti/state.vim',
    \ 'autoload/ruby_ti/ui.vim',
    \ 'autoload/ruby_ti/animation.vim',
    \ 'autoload/ruby_ti/checker.vim'
  \ ]
  
  let all_files_exist = 1
  for file in required_files
    let full_path = plugin_dir . '/' . file
    if filereadable(full_path)
      echo "✓ " . file
    else
      echo "✗ " . file . " (missing)"
      let all_files_exist = 0
    endif
  endfor
  
  echo ""
  
  if all_files_exist
    echo "✓ All new plugin files are present"
    echo ""
    echo "Migration Steps:"
    echo "1. Remove any old plugin sourcing from your vimrc"
    echo "2. Add this line to your vimrc:"
    echo "   source " . plugin_dir . "/ruby_ti.vim"
    echo ""
    echo "3. Optional: Add configuration (see README.md for details)"
    echo "   let g:ruby_ti_config = { 'animation_speed': 10 }"
    echo ""
    echo "Migration complete! The new modular plugin is ready to use."
  else
    echo "✗ Some plugin files are missing. Please ensure all files are installed."
  endif
  
  echo ""
  echo "For detailed configuration options, see README.md"
endfunction

" Run migration check
call RubyTiMigrate()