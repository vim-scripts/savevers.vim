" -*- vim -*-
" @(#) $Id: savevers.vim,v 0.2 2001/09/25 08:52:45 eralston Exp $
"
" Vim global plugin for saving multiple 'patchmode' versions
" Last Change: 2001-09-25 08:52:45
" Maintainer: Ed Ralston <eralston@techsan.org>
"
" created 2001-09-20 13:05:40 eralston@techsan.org
"
" Automatically save multiple, sequentially numbered
" old revisions of files (like in VMS)
"
" If the 'patchmode' option is non-empty, then whenever a file
" is saved, a version of the previously saved version is kept,
" but renamed to {file}.{number}.{patchext}, where:
"     {file}     is the filename of the file being saved
"     {number}   is a number between 0001 and 9999
"     {patchext} is the value of the 'patchmode' option.
" 
" Note that this plugin is DISABLED if 'patchmode' is empty.
"
" So, for example, if 'patchmode' is '.clean' and we save a
" file named "test.txt" we'll have the following files:
"
" -rw-r----- 1 eralston admin  106 Sep 20 11:14 test.txt
" -rw-r----- 1 eralston admin  102 Sep 20 11:12 test.txt.0001.clean
"
" If we make subsequent changes to "test.txt" and save it a
" few more times, we'll end up with something like:
"
" -rw-r----- 1 eralston admin  226 Sep 20 11:43 test.txt
" -rw-r----- 1 eralston admin  102 Sep 20 11:12 test.txt.0001.clean
" -rw-r----- 1 eralston admin  106 Sep 20 11:14 test.txt.0002.clean
" -rw-r----- 1 eralston admin  132 Sep 20 11:22 test.txt.0003.clean
" -rw-r----- 1 eralston admin  148 Sep 20 11:34 test.txt.0004.clean
"
" Also provided is the ":Purge [N]" command, which removes all
" but the patchmode files numbered N and below.  The [N] is
" optional, and defaults to 1.  Use ":Purge 0" to delete all
" of the patchmode files.
"
" -----------------------------------------------------------
" $Log: savevers.vim,v $
" Revision 0.2 2001/09/25 08:52:45  eralston
" allow up to 9999 numbered versions
"
" Revision 0.1 2001/09/20 13:05:40  eralston
" initial revision
"

if exists("loaded_savevers") || &cp
   finish
endif
let loaded_savevers = 1


augroup savevers
   au!
   autocmd BufWritePre,FileWritePre,FileAppendPre     *  call s:pre()
   autocmd BufWritePost,FileWritePost,FileAppendPost  *  call s:post()
augroup END

if !exists(":Purge")
   command -nargs=? Purge :call s:purge(<f-args>)
endif

function! s:pre()
   " don't do anything if patchmode isn't set
   if !strlen(&patchmode)
      return
   endif
   " search for the first non-existent patchfile
   let l:base = expand("<afile>:p")
   let l:i = 1
   while l:i < 9999
      let l:ext = substitute("000".l:i,"^.*\\(\\d\\{4}\\)$",".\\1".&pm,"")
      if !filereadable(l:base . l:ext)
         break
      endif
      let l:i = l:i + 1
   endwhile
   " set our new patchmode
   let s:patchmode = &patchmode
   let &patchmode = l:ext
endfunction

function! s:post()
   " don't do anything if patchmode isn't set
   if !strlen(&patchmode) || !exists("s:patchmode")
      return
   endif
   " undo our modifications to patchmode
   let &patchmode = s:patchmode
   unlet! s:patchmode
endfunction

" For efficiency, this assumes that the patchmode versions are
" sequential, and that none have been deleted, i.e., if we have:
"    -rw-r----- 1 eralston admin  226 Sep 20 11:43 test.txt
"    -rw-r----- 1 eralston admin  102 Sep 20 11:12 test.txt.0001.clean
"    -rw-r----- 1 eralston admin  106 Sep 20 11:14 test.txt.0002.clean
"    -rw-r----- 1 eralston admin  148 Sep 20 11:34 test.txt.0004.clean
" (note that "test.txt.0003.clean" is missing)
" then the "test.txt.0004.clean" file will not be deleted.
function! s:purge(...)
   " don't do anything if patchmode isn't set
   if !strlen(&patchmode)
      return
   endif
   " figure out what N should be
   if a:0 > 0
      let l:N = a:1
      if match(a:1,"[^0-9]") != -1
         echohl WarningMsg
         echon "Invalid argument: " . a:1
         echohl None
         return
      endif
   else
      " default N is 1.
      let l:N = 1
   endif
   " delete the specified patchmode files
   let l:base = expand("%:p")
   let l:i = l:N + 1
   while l:i < 9999
      let l:ext = substitute("000".l:i,"^.*\\(\\d\\{4}\\)$",".\\1".&pm,"")
      if delete(l:base . l:ext)
         " short-circuit the loop if the deletion failed.
         break
      endif
      let l:i = l:i + 1
   endwhile
   echo l:i - l:N - 1 . " files purged; " . l:N . " remain."
endfunction

" vim:syntax=vim:
" vim:set ai et sw=3:
