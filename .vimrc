"test
set ma
set number
set noma
set modifiable
syntax  on
set showmode
set mouse=a
set encoding=utf-8
set t_Co=256
filetype indent on
set autoindent
set tabstop=2
set relativenumber
set cursorline
set showmatch
set hlsearch
filetype plugin on
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 按 F5 执行当前 Python 代码
map <F5> :call PRUN()<CR>
func! PRUN()
    exec "w" 
    if &filetype == 'python'
        exec "!python %"
    endif
endfunc

"vim-plug开始
call plug#begin('~/.vim/plugged')

Plug 'Shougo/defx.nvim'
Plug 'roxma/nvim-yarp'
Plug 'roxma/vim-hug-neovim-rpc'
Plug 'preservim/nerdcommenter'
Plug 'jiangmiao/auto-pairs'
Plug 'nvie/vim-flake8'
Plug 'Yggdroot/indentLine'
Plug 'davidhalter/jedi-vim'
Plug 'vim-airline/vim-airline'
Plug 'iamcco/mathjax-support-for-mkdp'
Plug 'iamcco/markdown-preview.vim'

call plug#end()
"vim-plug结束
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"插件设置

"indentLine设置
let g:indentLine_concealcursor = 'inc'
let g:indentLine_conceallevel = 2

"jedi-vim自动补全设置
let g:jedi#completions_command = "<C-T>"


"Defx配置
    " 设置 ff 为开关defx的快捷键, 其中【-search=`expand('%:p')`】表示打开defx树后，光标自动放在当前buffer上
    nmap <silent> ff :Defx  -search=`expand('%:p')` -toggle <cr>

    "打开vim自动打开defx
    func! ArgFunc() abort
        let s:arg = argv(0)
        if isdirectory(s:arg)
            return s:arg
        else
            return fnamemodify(s:arg, ':h')
        endif
    endfunc
    "autocmd VimEnter * Defx `ArgFunc()` -no-focus -search=`expand('%:p')`

    " 设置defx树的一些格式
    call defx#custom#option('_', {
          \ 'columns': 'icons:indent:filename:size',
          \ 'winwidth': 30,
          \ 'split': 'vertical',
          \ 'direction': 'botright',
          \ 'show_ignored_files': 0,
          \ 'resume': 1,
          \ })
       " Exit Vim if defxTree is the only window left.
    autocmd BufEnter * if tabpagenr('$') == 1 && winnr('$') == 1 && exists('b:defx') |
    \ quit | endif

    " 在打开多个tab的情况下，当前tab里只有一个buffer和nerd树，当关闭buffer时，自动关闭当前标签页的nerd树
    autocmd BufEnter * if tabpagenr('$') > 1 && winnr('$') == 1 && exists('b:defx') |
    \ tabclose | endif

    " 在新tab页打开文件
    func! MyT(context) abort
        if isdirectory(get(a:context.targets, 0)) == 0
            call defx#call_action('drop', 'tabe')
        endif
    endfunc

    " 给cd快捷键写的
    func! MyCD(context) abort
        if isdirectory(get(a:context.targets, 0))
            execute 'cd' . get(a:context.targets, 0)
        else
            execute 'cd' . fnamemodify(defx#get_candidate().action__path, ':h')
        endif
    endfunc

    " 给 ter 快捷键写的
    func! MyTER(context) abort
        if isdirectory(get(a:context.targets, 0))
            execute '!xfce4-terminal --working-directory=' . get(a:context.targets, 0)
        else
            execute '!xfce4-terminal --working-directory=' . fnamemodify(defx#get_candidate().action__path, ':h')
        endif
    endfunc

    " 所有快捷键在这里设置
    autocmd FileType defx call s:defx_my_settings()
    function! s:defx_my_settings() abort
        nnoremap <silent><buffer><expr> <CR>     defx#do_action('drop')
        nnoremap <silent><buffer><expr> t        defx#do_action('call', 'MyT')
        nnoremap <silent><buffer><expr> yy       defx#do_action('yank_path')
        nnoremap <silent><buffer><expr> dd       defx#do_action('remove_trash')
        nnoremap <silent><buffer><expr> cc        defx#do_action('copy')
        nnoremap <silent><buffer><expr> mm        defx#do_action('move')
        nnoremap <silent><buffer><expr> pp        defx#do_action('paste')
        nnoremap <silent><buffer><expr> N        defx#do_action('new_file')
        nnoremap <silent><buffer><expr> M        defx#do_action('new_multiple_files')
        nnoremap <silent><buffer><expr> R        defx#do_action('rename')
        nnoremap <silent><buffer><expr> j        line('.') == line('$') ? 'gg' : 'j'
        nnoremap <silent><buffer><expr> k        line('.') == 1 ? 'G' : 'k'
        nnoremap <silent><buffer><expr> h    
                    \ defx#is_opened_tree() ? 
                    \ defx#do_action('close_tree', defx#get_candidate().action__path) : 
                    \ defx#do_action('search',  fnamemodify(defx#get_candidate().action__path, ':h'))
        nnoremap <silent><buffer><expr> l        defx#do_action('open_tree')
	nnoremap <silent><buffer><expr> o        defx#do_action('open_directory')
        nnoremap <silent><buffer><expr> u        defx#do_action('cd', ['..'])
        nnoremap <silent><buffer><expr> E        defx#do_action('open', 'vsplit')
        nnoremap <silent><buffer><expr> P        defx#do_action('preview')
        nnoremap <silent><buffer><expr> C        defx#do_action('toggle_columns',  'mark:indent:icon:filename:type:size:time')
        nnoremap <silent><buffer><expr> S        defx#do_action('toggle_sort', 'time')
        nnoremap <silent><buffer><expr> !        defx#do_action('execute_command')
        nnoremap <silent><buffer><expr> x        defx#do_action('execute_system')
        nnoremap <silent><buffer><expr> cd       defx#do_action('call', 'MyCD')
        nnoremap <silent><buffer><expr> ~        defx#do_action('cd')
        nnoremap <silent><buffer><expr> ter      defx#do_action('call', 'MyTER')
        nnoremap <silent><buffer><expr> .        defx#do_action('toggle_ignored_files')
        nnoremap <silent><buffer><expr> q        defx#do_action('quit')
        nnoremap <silent><buffer><expr> <Space>  defx#do_action('toggle_select') . 'j'
        nnoremap <silent><buffer><expr> *        defx#do_action('toggle_select_all')
        nnoremap <silent><buffer><expr> m        defx#do_action('clear_select_all')
        nnoremap <silent><buffer><expr> r        defx#do_action('redraw')
        nnoremap <silent><buffer><expr> pr       defx#do_action('print')
        nnoremap <silent><buffer><expr> >        defx#do_action('resize',  defx#get_context().winwidth - 10)
        nnoremap <silent><buffer><expr> <        defx#do_action('resize',  defx#get_context().winwidth + 10)
	nnoremap <silent><buffer><expr> <2-LeftMouse>
    endfunction
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"markdown-peview.vim插件配置

nmap <silent> <F8> <Plug>MarkdownPreview        " 普通模式
imap <silent> <F8> <Plug>MarkdownPreview        " 插入模式
nmap <silent> <F9> <Plug>StopMarkdownPreview    " 普通模式
imap <silent> <F9> <Plug>StopMarkdownPreview    " 插入模式
"F8打开预览窗口，F9关闭预览窗口

let g:mkdp_path_to_chrome = '/mnt/c/Program\ Files/Google/Chrome/Application/chrome.exe' "设置 chrome 浏览器的路径（或是启动 chrome（或其他现代浏览器）的命令）
    " 如果设置了该参数, g:mkdp_browserfunc 将被忽略


let g:mkdp_browserfunc = 'MKDP_browserfunc_default'
    " vim 回调函数, 参数为要打开的 url

let g:mkdp_auto_start = 1
    " 设置为 1 可以在打开 markdown 文件的时候自动打开浏览器预览，只在打开
    " markdown 文件的时候打开一次

let g:mkdp_auto_open = 1
    " 设置为 1 在编辑 markdown 的时候检查预览窗口是否已经打开，否则自动打开预
    " 览窗口

let g:mkdp_auto_close = 1
    " 在切换 buffer 的时候自动关闭预览窗口，设置为 0 则在切换 buffer 的时候不
    " 自动关闭预览窗口

let g:mkdp_refresh_slow = 0
    " 设置为 1 则只有在保存文件，或退出插入模式的时候更新预览，默认为 0，实时
    " 更新预览

let g:mkdp_command_for_global = 0
    " 设置为 1 则所有文件都可以使用 MarkdownPreview 进行预览，默认只有 markdown
    " 文件可以使用改命令

let g:mkdp_open_to_the_world = 0
    " 设置为 1, 在使用的网络中的其他计算机也能访问预览页面
    " 默认只监听本地（127.0.0.1），其他计算机不能访问


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"vim-airline设置
let g:airline#extensions#tabline#enabled = 1
"启用扩展
