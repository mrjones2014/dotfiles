let g:airline_powerline_fonts = 1
let g:airline_theme = 'codedark'
let g:airline_skip_empty_sections = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tmuxline#enabled = 1
let g:airline#extensions#tabline#buffer_idx_mode = 1
let g:airline#extensions#tabline#buffer_idx_format = {
	\ '0': '0 ',
	\ '1': '1 ',
	\ '2': '2 ',
	\ '3': '3 ',
	\ '4': '4 ',
	\ '5': '5 ',
	\ '6': '6 ',
	\ '7': '7 ',
	\ '8': '8 ',
	\ '9': '9 '
	\}
let g:airline#extensions#tabline#fnamemod = ':t'
let g:airline#extensions#tabline#fnamecollapse = 1
let g:airline#extensions#tabline#fnametruncate = 0

let g:airline#extensions#tabline#show_tab_nr = 1
let g:airline#extensions#tabline#tab_nr_type= 2
let g:airline#extensions#tabline#show_tab_type = 1
let g:airline#extensions#tabline#buffers_label = 'BUFFERS'
let g:airline#extensions#tabline#tabs_label = 'TABS'
let g:airline_section_c = '%F'

function! WindowNumber(...)
    let builder = a:1
    let context = a:2
    call builder.add_section('airline_b', '%{tabpagewinnr(tabpagenr())}')
    return 0
endfunction

call airline#add_statusline_func('WindowNumber')
call airline#add_inactive_statusline_func('WindowNumber')

" Go to tab by number
nmap <leader>1 <Plug>AirlineSelectTab1
nmap <leader>2 <Plug>AirlineSelectTab2
nmap <leader>3 <Plug>AirlineSelectTab3
nmap <leader>4 <Plug>AirlineSelectTab4
nmap <leader>5 <Plug>AirlineSelectTab5
nmap <leader>6 <Plug>AirlineSelectTab6
nmap <leader>7 <Plug>AirlineSelectTab7
nmap <leader>8 <Plug>AirlineSelectTab8
nmap <leader>9 <Plug>AirlineSelectTab9

" Go to window by number
nmap <Space>1 :1 wincmd w<CR>
nmap <Space>2 :2 wincmd w<CR>
nmap <Space>3 :3 wincmd w<CR>
nmap <Space>4 :4 wincmd w<CR>
nmap <Space>5 :5 wincmd w<CR>
nmap <Space>6 :6 wincmd w<CR>
nmap <Space>7 :7 wincmd w<CR>
nmap <Space>8 :8 wincmd w<CR>
nmap <Space>9 :9 wincmd w<CR>
