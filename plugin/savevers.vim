" -*- vim -*-
" @(#) $Id: savevers.vim,v 0.8 2001/10/10 15:29:11 eralston Exp $
"
" Vim global plugin for saving multiple 'patchmode' versions
" Last Change: 2001/10/10 15:29:11
" Maintainer: Ed Ralston <eralston@techsan.org>
"
" created 2001-09-20 13:05:40 eralston@techsan.org
"
" Copyright 2001 Ed Ralston
" Free distribution, use, and modification permitted under GPL2.
"
" DESCRIPTION:
"    Automatically saves and compares multiple, sequentially numbered
"    old revisions of files (like in VMS)
"    
"    If the 'patchmode' option is non-empty, then whenever a file
"    is saved, a version of the previously saved version is kept,
"    but renamed to {file}.{number}.{patchext}, where:
"        {file}     is the filename of the file being saved
"        {number}   is a number between 0001 and 9999
"        {patchext} is the value of the 'patchmode' option.
"    
"    Note that this plugin is DISABLED if 'patchmode' is empty.
"    Also, this plugin won't work if 'backupdir' is empty or if
"    'backup' is unset, so to get started, put the following in
"    your ".vimrc" (NOT .gvimrc)
"
"        set backup
"        set patchmode=.clean
"    
"    So, for example, if 'patchmode' is '.clean' and we save a
"    file named "test.txt" we'll have the following files:
"    
"    -rw-r----- 1 eralston admin  106 Sep 20 11:14 test.txt
"    -rw-r----- 1 eralston admin  102 Sep 20 11:12 test.txt.0001.clean
"    
"    If we make subsequent changes to "test.txt" and save it a
"    few more times, we'll end up with something like:
"    
"    -rw-r----- 1 eralston admin  226 Sep 20 11:43 test.txt
"    -rw-r----- 1 eralston admin  102 Sep 20 11:12 test.txt.0001.clean
"    -rw-r----- 1 eralston admin  106 Sep 20 11:14 test.txt.0002.clean
"    -rw-r----- 1 eralston admin  132 Sep 20 11:22 test.txt.0003.clean
"    -rw-r----- 1 eralston admin  148 Sep 20 11:34 test.txt.0004.clean
"
" COMMANDS:
"    :Purge [-a] [-v] [N]
"       Removes all but the patchmode files numbered N and below.
"       The [N] is optional, and defaults to 1.
"       Normally, this operates only on the patchmode files associated
"       with the current buffer, but if the [-a] flag is given, then
"       it operates on all patchmode files in the directory of the
"       current file.
"       If the optional [-v] (verbose) flag is given, then the filename
"       of each deleted patchmode file is printed.
"
"       Use ":Purge 0" to delete all of the patchmode files for the
"       current file.
"
"       Use ":Purge -a 0" to delete all of the patchmode files in
"       the directory of the current file.
"
"    :VersDiff [-t] [arg]
"       Does a "diffsplit" on the current file with the version
"       indicated by [arg].  So, for example, if the current
"       file is "test.txt" then the ":VersDiff 5" command will
"       do a "diffsplit" with "test.txt.0005.clean", assuming
"       &patchmode is ".clean"
"
"       If [arg] is zero (the default), then the diff is done with
"       the current saved version of the file.
"
"       If [arg] is negative, then the diff is done with the
"       [arg]th oldest file; e.g., if [arg] is "-5" and there are
"       versions 0001-0023 saved on disk, then the version that
"       is diffed will be (23-5+1)=19, i.e, "test.txt.0019" will
"       be diffed.
"
"       If [arg] is "-cvs", then the diff is done with the most recently
"       checked-in version of the file.
"
"       If [arg] is "-", then the current VersDiff window is decremented.
"       If [arg] is "+", then the current VersDiff window is incremented.
"           (Note that if VersDiff is currently doing a cvs diff, then
"           the cvs revision is incremented/decremented)
"
"
"       If [arg] is "-c", then any current VersDiff window is closed.
"
"       If the optional [-t] (toggle) flag is given, then if there
"       is currently a VersDiff window, then it is closed.  Otherwise,
"       the indicated VersDiff window is created.
"
" CONFIGURATION:
"    First make sure that the "backup" option is set, and the
"    "patchmode" option is non-empty.
"
"    This plugin can be configured by setting the following
"    variables in ".vimrc" (NOT .gvimrc)
"
"    savevers_types     - This is a comma-separated list of filename
"                         patterns.  Sets the types of files that
"                         will have numbered versions.
"                         Defaults to "*" (all files).
"
"    savevers_max       - Sets the maximum patchmode version.
"                         Defaults to "9999".
"
"    savevers_purge     - Sets default value of [N] for the :Purge command
"                         Defaults to "1".
"
"    savevers_dirs      - This is a comma-separated list of directories
"                         that will be tried to store the patchmode files.
"                         The first writable directory in this list is used.
"                         This works much like the vim 'backupdir' option.
"                         To set this to the same as 'backupdir', do
"                            :let savevers_dirs = &backupdir
"                         Defaults to '.', which puts all patchmode files
"                         in the same directory as the original file.
"
"    versdiff_no_resize - Disables window resizing during ":VersDiff"
"
"    versdiff_max_cols  - Limits window resizing during ":VersDiff"
"
"    So, for example, if the user has in ~/.vimrc:
"       let savevers_types = "*.c,*.h,*.vim"
"       let savevers_max = 99
"       let savevers_purge = 0
"    then only "*.c", "*.h", and "*.vim" files will be numbered,
"    and there will be a maximum of 99 versions saved.
"    Also, the ":Purge" command will purge all numbered versions
"    (instead of the default, which is to delete all but the oldest).
"
" HINTS:
"    If you use GNU 'ls', then try adding "-I'*.clean'" (without the
"    double quotes) to your 'ls' alias (assuming &patchmode==.clean)
"
"    It's also helpful to have the patchmode value in the backupskip,
"    suffixes, and wildignore vim options:
"
"       :exe "set backupskip+=*" . &patchmode
"       :exe "set suffixes+=" . &patchmode
"       :exe "set wildignore+=*" . &patchmode
"
"    Also, here are some nice mappings that allow quick comparison
"    of the current file with previous versions.  Pressing <F5>
"    successively shows the diff with older versions.
"
"       " <F5> decrease version viewed in VersDiff window
"       " <F6> increase version viewed in VersDiff window
"       " <F7> do VersDiff with cvs version of current file
"       " <F8> cancel VersDiff window
"       nmap <silent> <F5> :VersDiff -<cr>
"       nmap <silent> <F6> :VersDiff +<cr>
"       nmap <silent> <F7> :VersDiff -cvs<cr>
"       nmap <silent> <F8> :VersDiff -c<cr>
"
" -----------------------------------------------------------
"
" $Log: savevers.vim,v $
" Revision 0.8 2001/10/10 15:29:11  eralston
" Corrected some obscure documentation.
" Allow cvs revisions to be incremented/decremented.
"
" Revision 0.7 2001/10/02 13:55:22  eralston
" Added 'savevers_dirs' option to specify directory for patchmode files
"
" Revision 0.6 2001/10/01 11:05:12  eralston
" ":VersDiff" command improvements
"
" Revision 0.5 2001/10/01 09:50:22  eralston
" Added ":VersDiff" command
"
" Revision 0.4 2001/09/26 11:45:20  eralston
" Added "-a" and "-v" flags to the ":Purge" command.
"
" Revision 0.3 2001/09/25 14:51:38  eralston
" Added configuration variables.
"
" Revision 0.2 2001/09/25 08:52:45  eralston
" Allow up to 9999 numbered versions.
"
" Revision 0.1 2001/09/20 13:05:40  eralston
" Initial revision.
"

if exists("loaded_savevers") || &cp
   finish
endif
let loaded_savevers = 1


" Determine what types of files will have numbered versions.
" The user can specify this by setting the variable "savevers_types".
if exists("savevers_types") && strlen(savevers_types)
   if ( match( substitute(savevers_types,"\\f","x","g"), "[^,\*x]") == -1 )
      let s:types = savevers_types
   else
      " If you get this error, it means your "savevers_types" configuration
      " variable is malformed.  It should look like the {pat} field
      " of the |:autocmd| command.  Do ":help :au" for more help on this.
      echoerr "Malformed savevers_types - savevers.vim disabled"
      finish
   endif
else
   let s:types = "*"
endif

augroup savevers
   au!
   exe "au BufWritePre,FileWritePre,FileAppendPre    " . s:types . " call s:pre()"
   exe "au BufWritePost,FileWritePost,FileAppendPost " . s:types . " call s:post()"
augroup END


" Determine what the maximum patchmode version should be.
" The user can specify this by setting the variable "savevers_max".
if exists("savevers_max") && savevers_max > 0
   let s:max_ver = savevers_max
else
   let s:max_ver = 9999
endif


" Determine how many characters are in s:max_ver, so that
" we can insert an appropriate number of leading zeroes.
let s:ver_len = strlen(s:max_ver)
let s:zeroes = strpart("000000000000000000000000",0,s:ver_len)
let s:ver_subst = "^.*\\(\\d\\{" . s:ver_len . "}\\)$"
unlet s:ver_len


function! s:get_ext(i)
   return substitute(s:zeroes.a:i,s:ver_subst,".\\1".&pm,"")
endfunction

function! s:get_version(base,i,dir)
   if a:dir =~ "^$" || a:dir =~ "^\\\./$"
      return fnamemodify(a:base,":p") . s:get_ext(a:i)
   else
      return a:dir . fnamemodify(a:base,":t") . s:get_ext(a:i)
   endif
endfunction


" define the ":Purge" command
if !exists(":Purge")
   command -nargs=* Purge :call s:purge(<f-args>)
endif

function! s:pre()
   " don't do anything if patchmode isn't set
   if !strlen(&patchmode)
      return
   endif
   " search for the first non-existent patchfile
   let l:base = expand("<afile>:p")
   let l:dir = s:first_versdir(l:base)
   let l:i = 1
   let s:patchnum = 1
   while l:i <= s:max_ver
      let s:patchnum = l:i
      if !filereadable(s:get_version(l:base,l:i,l:dir))
         break
      endif
      let l:i = l:i + 1
   endwhile
   " set our new patchmode
   let s:patchmode = &patchmode
   let &patchmode = s:get_ext(s:patchnum)
endfunction


function! s:post()
   " don't do anything if patchmode isn't set
   if !strlen(&patchmode) || !exists("s:patchmode")
      return
   endif
   let l:base = expand("<afile>:p")
   let l:src = l:base . &patchmode
   let &patchmode = s:patchmode
   let l:dst = s:get_version(l:base,s:patchnum,s:first_versdir(l:base))
   if l:src != l:dst
      if filereadable(l:dst)
         let l:tmp = l:dst . ".SaVeVeRs." . s:patchnum
         if filereadable(l:tmp)
            echohl ErrorMsg
            echo ":savevers.vim - Old temp file?  Something went wrong..."
            echohl None
         elseif rename(l:dst,l:tmp)
            echohl ErrorMsg
            echo ":savevers.vim - Can't create temp file?  Something went wrong..."
            echohl None
         elseif !filereadable(l:src)
            " Hmm, src no longer exists? Maybe src and dst are the same?
            call rename(l:tmp,l:dst)
         elseif !rename(l:src,l:dst)
            call delete(l:tmp)
         endif
      else
         call rename(l:src,l:dst)
      endif
   endif
   unlet! s:patchmode s:patchnum
endfunction


function! s:purge(...)
   " don't do anything if patchmode isn't set
   if !strlen(&patchmode)
      return
   endif
   " set the default N
   if exists("g:savevers_purge")
      if match(g:savevers_purge,"[^0-9]") == -1
         let l:N = g:savevers_purge
      else
         echohl ErrorMsg
         echo ":Purge - invalid savevers_purge: " . g:savevers_purge
         echohl None
         return
      endif
   else
      let l:N = 1
   endif
   " parse the arguments
   let l:all = 0
   let l:verbose = 0
   let l:argn = 1
   while l:argn <= a:0
      exe "let l:arg = a:" . l:argn
      if match(l:arg,"-a$") == 0
         let l:all = 1
      elseif match(l:arg,"-v$") == 0
         let l:verbose = 1
      elseif match(l:arg,"[^0-9]") == -1
         let l:N = l:arg
      else
         echohl ErrorMsg
         echo ":Purge - invalid argument: " . l:arg
         echohl None
         return
      endif
      let l:argn = l:argn + 1
   endwhile

   " delete the patchmode files
   let s:npurged = 0
   let s:nremain = 0
   if l:all
      let l:types = s:types
      while strlen(l:types)
         let l:comma = match(l:types,",")
         if l:comma < 0
            let l:type = l:types
            let l:types = ""
         elseif l:comma == 0
            let l:types = strpart(l:types,1)
            continue
         else
            let l:type = strpart(l:types,0,l:comma)
            let l:types = strpart(l:types,l:comma+1)
         endif
         let l:glob = globpath(expand("%:p:h"),l:type)
         while strlen(l:glob)
            let l:nl = match(l:glob,"\n")
            if l:nl < 0
               call s:purgef(l:N,l:glob,l:verbose)
               break
            elseif l:nl == 0
               let l:glob = strpart(l:glob,1)
               continue
            else
               call s:purgef(l:N,strpart(l:glob,0,l:nl),l:verbose)
               let l:glob = strpart(l:glob,l:nl+1)
            endif
         endwhile
      endwhile
   else
      call s:purgef(l:N,expand("%:p"),l:verbose)
   endif

   echo s:npurged . " files purged; " . s:nremain . " remain."
   unlet! s:npurged s:nremain
endfunction


" CAVEAT:
" For efficiency, this assumes that the patchmode versions are
" sequential, and that none have been deleted, i.e., if we have:
"    -rw-r----- 1 eralston admin  226 Sep 20 11:43 test.txt
"    -rw-r----- 1 eralston admin  102 Sep 20 11:12 test.txt.0001.clean
"    -rw-r----- 1 eralston admin  106 Sep 20 11:14 test.txt.0002.clean
"    -rw-r----- 1 eralston admin  148 Sep 20 11:34 test.txt.0004.clean
" (note that "test.txt.0003.clean" is missing)
" then the "test.txt.0004.clean" file will not be deleted.
function! s:purgef(N,base,verbose)
   let l:max_ver = ( s:max_ver < 9999 ) ? 9999 : s:max_ver
   let l:versdir = s:first_versdir(a:base)
   while strlen(l:versdir)
      let l:i = 1
      while l:i <= l:max_ver
         let l:fname = s:get_version(a:base,l:i,l:versdir)
         if l:i <= a:N
            if !filereadable(l:fname)
               " break the loop if the file doesn't exist
               break
            else
               let s:nremain = s:nremain + 1
            endif
         elseif delete(l:fname)
            " break the loop if the deletion failed.
            break
         else
            let s:npurged = s:npurged + 1
            if a:verbose
               echo "purged: " . l:fname
            endif
         endif
         let l:i = l:i + 1
      endwhile
      let l:versdir = s:next_versdir(a:base)
   endwhile
endfunction

function! s:first_versdir(base)
   if exists("g:savevers_dirs") && strlen(g:savevers_dirs)
      let s:verspath_iterator = g:savevers_dirs
   else
      let s:verspath_iterator = "."
   endif
   return s:next_versdir(a:base)
endfunction

function! s:next_versdir(base)
   while strlen(s:verspath_iterator)
      let l:comma = match(s:verspath_iterator,",")
      if l:comma < 0
         let l:dir = s:verspath_iterator
         let s:verspath_iterator = ""
      elseif l:comma == 0
         let s:verspath_iterator = strpart(s:verspath_iterator,1)
         continue
      else
         let l:dir = strpart(s:verspath_iterator,0,l:comma)
         let s:verspath_iterator = strpart(s:verspath_iterator,l:comma+1)
      endif

      if match(l:dir,"\\\.") == 0
         let l:dir = fnamemodify(fnamemodify(expand(a:base),":p:h")."/".l:dir,":p")
      else
         let l:dir = expand(l:dir)
         if !strlen(l:dir)
            continue
         endif
         let l:dir = fnamemodify(l:dir,":p")
      endif
      if !strlen(l:dir)
         continue
      endif
      if match(l:dir,"/$") < 0
         let l:dir = l:dir . "/"
      endif
      let l:dir = substitute(l:dir,"/\\\./","/","g")
      if filewritable(l:dir) != 2
         continue
      endif
      return l:dir
   endwhile
   unlet! s:verspath_iterator
   return ""
endfunction



" define the ":VersDiff" command, but only if we can actually do a diff.
if !has("diff")
   finish
endif

if !exists(":VersDiff")
   command -nargs=? VersDiff :call s:versdiff(<f-args>)
endif

augroup savevers
   au BufUnload * call s:bufunload()
augroup END

function! s:bufunload()
   if exists("s:versdiff_child") && s:versdiff_child == expand("<abuf>")
      call s:undo_versdiff()
      if exists("*VersDiff_hook") && !exists("s:versdiff_child") && !exists("s:versdiff_creating")
         call VersDiff_hook("close")
      endif
   endif
endfunction

function! s:versdiff(...)
   " don't do anything if patchmode isn't set
   if !strlen(&patchmode)
      return
   endif
   " parse the arguments
   let l:N = 0
   let l:argn = 1
   let l:relative = 0
   while l:argn <= a:0
      exe "let l:arg = a:" . l:argn
      if match(l:arg,"-c$") == 0
         call s:close_versdiff()
         let s:cvs_parent = -1
         return
      elseif match(l:arg,"-t$") == 0
         if exists("s:versdiff_child") && bufexists(s:versdiff_child)
            call s:close_versdiff()
            let s:cvs_parent = -1
            return
         endif
      elseif match(l:arg,"-[0-9]") == 0 && match(l:arg,"[^-0-9]") == -1
         let l:N = l:arg
      elseif match(l:arg,"[0-9]") == 0 && match(l:arg,"[^0-9]") == -1
         let l:N = l:arg
      elseif match(l:arg,"-cvs$") == 0
         let l:N = "cvs"
      elseif match(l:arg,"[-+]$") == 0
         let l:dir = match(l:arg,"-") ? 1 : -1
         if exists("s:cvs_parent")
                 \ && exists("s:versdiff_parent") && exists("s:versdiff_child")
                 \ && ( s:versdiff_parent == bufnr("%")
                         \ || s:versdiff_child == bufnr("%") )
                 \ && s:versdiff_parent == s:cvs_parent
            let l:N = "cvs" . l:arg
         else
            if exists("s:versdiff_N")
                     \ && exists("s:versdiff_parent") && exists("s:versdiff_child")
                     \ && ( s:versdiff_parent == bufnr("%")
                     \ || s:versdiff_child == bufnr("%") )
               let l:N = s:versdiff_N + l:dir
            else
               let l:N = ( l:dir + 1 ) / 2
            endif
            if !l:N && !&modified
               let l:N = l:dir
            endif
         endif
         let l:relative = 1
      else
         echohl ErrorMsg
         echo ":VersDiff - invalid argument: " . l:arg
         echohl None
         return
      endif
      let l:argn = l:argn + 1
   endwhile

   if exists("s:versdiff_child") && exists("s:versdiff_parent")
           \ && s:versdiff_child == bufnr("%")
      exec bufwinnr(s:versdiff_parent) . "wincmd w"
   endif

   let l:base = expand("%:p")
   let l:dir = s:first_versdir(l:base)
   let l:curbuf = bufnr("%")

   " look for the appropriate file, and run the diff.
   if l:N == 0
      call s:do_versdiff( l:curbuf, "", l:base, l:N, l:relative )
   elseif l:N > 0
      call s:do_versdiff( l:curbuf, l:dir, l:base, l:N, l:relative )
   else
      let l:nver = 1
      while l:nver <= s:max_ver
         if !filereadable(s:get_version(l:base,l:nver,l:dir))
            break
         endif
         let l:nver = l:nver + 1
      endwhile
      let l:i = l:nver + l:N
      if l:i > 0
         call s:do_versdiff( l:curbuf, l:dir, l:base, l:i, l:relative)
      elseif l:relative
         call s:do_versdiff( l:curbuf, "", l:base, 0, l:relative )
      else
         echohl WarningMsg
         echo ":VersDiff - only " . (l:nver-1) . " versions available"
         echohl None
      endif
   endif
   if l:curbuf != bufnr("%")
      exec bufwinnr(l:curbuf) . "wincmd w"
   endif
endfunction

function! s:do_versdiff(parentbuf,dir,base,N,relative)
   if a:N 
      let l:fname = s:get_version(a:base,a:N,a:dir)
   else
      let l:fname = a:base
   endif
   let l:N = a:N
   if !filereadable(l:fname)
      if a:relative
         let l:fname = a:base
         let l:N = 0
      endif
      if !filereadable(l:fname)
         echohl WarningMsg
         echo ":VersDiff - cannot read file \"" . l:fname . "\""
         echohl None
         return
      endif
   endif

   if exists("*VersDiff_hook")
      if !exists("s:versdiff_child")
         call VersDiff_hook("open")
      endif
      call VersDiff_hook("change")
   endif

   " close any active versdiff
   let l:reusewin = 0
   let l:parbufnr = bufnr("%")
   let l:parbufwinnr = bufwinnr("%")
   if exists("s:versdiff_child")
      let s:versdiff_creating = 1
      if a:parentbuf == s:versdiff_parent && bufexists(s:versdiff_child)
         let l:reusewin = bufwinnr(s:versdiff_child)
      else
         call s:close_versdiff()
         if l:parbufnr != bufnr("%")
            if winbufnr(l:parbufnr) == l:parbufwinnr
               exec l:parbufwinnr . "wincmd w"
            endif
            if l:parbufnr != bufnr("%")
               exec bufwinnr(l:parbufnr) . "wincmd w"
            endif
         endif
      endif
      unlet! s:versdiff_child s:versdiff_creating
   endif
   let s:versdiff_parent = a:parentbuf

   let l:curline = line(".")

   " turn off diff in all windows
   let l:winnr = 1
   while winbufnr(l:winnr) > 0
      call setwinvar(l:winnr,"&diff", 0)
      let l:winnr = l:winnr + 1
   endwhile

   " save current settings.
   if l:reusewin <= 0
      let s:versdiff_cols = &columns
      let s:versdiff_width = winwidth(0)
      let s:versdiff_foldcol = &l:foldcolumn
      let s:versdiff_foldmethod = &l:foldmethod
      let s:versdiff_scrollbind = &l:scrollbind
      let s:versdiff_wrap = &l:wrap
   endif
   if has("syntax")
      let l:syntax = &l:syntax
   endif
   let l:ff = &l:ff
   
   " clean up old cvs stuff
   if exists("s:cvs_parent")
          \ && ( ( s:cvs_parent != s:versdiff_parent ) || match(l:N, "^cvs") )
      if exists("s:cvs_versbuf") && s:cvs_versbuf != s:versdiff_parent
         exe "silent! bw! " . s:cvs_versbuf
      endif
      unlet! s:cvs_parent s:cvs_versbuf s:cvs_versline
   endif

   " do diffsplit
   diffthis
   if l:reusewin > 0
      exec l:reusewin . "wincmd w"
      setlocal nodiff
   else
      vert new
   endif
   if bufnr("%") == s:versdiff_parent
      " Just to be safe, we make sure we're no longer in the parent window.
      " (We don't want to end up losing its contents).
      " This should never happen.
      echohl ErrorMsg
      echo ":VersDiff - Still in parent?  Something went wrong..."
      echohl None
      return
   elseif l:N == 0
      enew
      setlocal modifiable
      setlocal noswapfile
      setlocal bufhidden=delete
      setlocal buftype=nofile
      let &l:ff = l:ff
      if match(l:N, "^cvs") == 0
         let s:cvs_parent = s:versdiff_parent
         let l:autowrite = &autowrite
         set noautowrite
         let l:cvs_rev = ""
         if match(l:N, "[+-]") > 0
            let l:diffbufnr = bufnr("%")
            if !exists("s:cvs_versbuf") || !bufexists(s:cvs_versbuf)
               let s:cvs_versline = 1
               new
               setlocal modifiable
               setlocal noswapfile
               setlocal bufhidden=hide
               setlocal buftype=nofile
               exe "silent read! cvs -Q log -b -N " . l:fname
               if v:shell_error
                  bw!
               else
                  v/^revision\>\s\+\d\+\.\?\d\+/d
                  %s/^revision\s\+\(\d\)/-r \1/
                  let s:cvs_versbuf = bufnr("%")
                  hide
               endif
            endif
            if exists("s:cvs_versbuf") && bufexists(s:cvs_versbuf)
               exe "sb " . s:cvs_versbuf
               if match(l:N, "+") > 0 && s:cvs_versline > 1
                  let s:cvs_versline = s:cvs_versline - 1
               elseif match(l:N, "-") > 0 && s:cvs_versline < line("$")
                  let s:cvs_versline = s:cvs_versline + 1
               endif
               let l:cvs_rev = getline(s:cvs_versline)
               hide
            endif
            if l:diffbufnr != bufnr("%")
               exe bufwinnr(l:diffbufnr) . "wincmd w"
            endif
         else
            let s:cvs_versline = 1
         endif
         %d
         normal G
         call append(0,"--X--")
         exe "silent 0read! cvs -Q update -p " . l:cvs_rev . " " . l:fname
         normal ']+dG
         let &autowrite = l:autowrite
         if v:shell_error
            %d
            let l:cvs_failed = 1
         endif
      else
         let s:versdiff_N = l:N
         %d
         normal G
         call append(0,"--X--")
         exe "0read " . l:fname
         normal ']+dG
      endif
   else
      let s:versdiff_N = l:N
      setlocal buftype=
      if l:reusewin > 0
         let l:delbuf = bufnr("%")
         exec "silent edit! " . l:fname
         silent! exec "silent! bd! " . l:delbuf
      else
         exec "silent edit! " . l:fname
      endif
   endif
   setlocal nomodifiable
   diffthis
   let l:diffbufnr = bufnr("%")
   let s:versdiff_width = s:versdiff_width + &l:foldcolumn

   " set the syntax of the new file
   if has("syntax")
      let &l:syntax = l:syntax
   endif

   " set the window sizes
   if l:reusewin <= 0
      let l:wantcols = ( s:versdiff_width * 2 + 1 )
      if exists("g:versdiff_max_cols") && l:wantcols > g:versdiff_max_cols
         let l:wantcols = g:versdiff_max_cols
      endif
      if exists("s:versdiff_cols") && l:wantcols > s:versdiff_cols
         if has("gui_running") && !exists("g:versdiff_no_resize")
            let &columns = l:wantcols
         else
            unlet! s:versdiff_cols
         endif
         let l:actual_width = ( &columns - 1 ) / 2
         exec l:actual_width . "wincmd |"
         exec bufwinnr(s:versdiff_parent) . "wincmd w"
         exec l:actual_width . "wincmd |"
      else
         exec bufwinnr(s:versdiff_parent) . "wincmd w"
         unlet! s:versdiff_cols
      endif
   else
      exec bufwinnr(s:versdiff_parent) . "wincmd w"
   endif
   let s:versdiff_child = l:diffbufnr
   exec l:curline

   if exists("l:cvs_failed")
      echohl WarningMsg
      echo ":VersDiff - cvs command failed."
      echohl None
   endif
endfunction

function! s:close_versdiff()
   if !exists("s:versdiff_child") || !bufexists(s:versdiff_child)
      return
   endif
   exec bufwinnr(s:versdiff_child) . "wincmd w"
   silent! bw
endfunction

function! s:undo_versdiff()
   if !exists("s:versdiff_parent") || bufwinnr(s:versdiff_parent) <= 0
      return
   endif

   let l:curwin = winnr()

   if bufnr("%") != s:versdiff_parent
      exec bufwinnr(s:versdiff_parent) . "wincmd w"
   endif

   " undo the setting changes due to the diff
   setlocal nodiff
   let &l:foldcolumn = s:versdiff_foldcol
   let &l:foldmethod = s:versdiff_foldmethod
   let &l:scrollbind = s:versdiff_scrollbind
   let &l:wrap = s:versdiff_wrap
   if &l:foldmethod == "manual"
      normal zEzX
   endif

   if exists("s:versdiff_cols")
      let &columns = s:versdiff_cols
      unlet! s:versdiff_cols
   endif

   " resize the parent window
   if exists("s:versdiff_width")
      exec s:versdiff_width . "wincmd|"
      unlet! s:versdiff_width
   endif

   unlet! s:versdiff_child s:versdiff_parent s:versdiff_N
   exec l:curwin . "wincmd w"
endfunction


" vim:syntax=vim:
" vim:set ai et sw=3:
