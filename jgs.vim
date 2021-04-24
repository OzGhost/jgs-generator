let s:save_cpo = &cpo
set cpo&vim

if exists("g:loaded_jgs")
    finish
endif
let g:loaded_jgs = 1

fu! g:Jgs(start_line, end_line)
    let i = a:start_line
    wh i <= a:end_line
        call s:cook(getline(i))
        let i += 1
    endw
endf

let s:coffin = '^\(\s*\)\(private\s\|protected\s\|transient\s\|volatile\s\)*\([a-zA-Z0-9$_<>\[\] ,]\+\)\s\([a-zA-Z0-9$_]\+\);$'

let s:getter_frame = []
let s:getter_frame += ['/**']
let s:getter_frame += [' * Get value of {{name}}.']
let s:getter_frame += [' * @return {{name}}']
let s:getter_frame += [' */']
let s:getter_frame += ['public {{type}} {{func}}() {']
let s:getter_frame += ['    return {{name}};']
let s:getter_frame += ['}']

let s:setter_frame = []
let s:setter_frame += ['/**']
let s:setter_frame += [' * Set value for {{name}}.']
let s:setter_frame += [' * @param {{name}} the given value']
let s:setter_frame += [' */']
let s:setter_frame += ['public void {{func}}({{type}} {{name}}) {']
let s:setter_frame += ['    this.{{name}} = {{name}};']
let s:setter_frame += ['}']

fu! s:cook(line)
    if a:line !~ s:coffin
        echom '__[o0] Not matched!'
        return
    endif
    let indent = substitute(a:line, s:coffin, '\1', '')
    let type = substitute(a:line, s:coffin, '\3', '')
    let name = substitute(a:line, s:coffin, '\4', '')
    let fname = toupper(strpart(name, 0, 1)) . strpart(name, 1, len(name) - 1)
    if type ==? "boolean"
        call s:pump(s:getter_frame, 'is'.fname, indent, type, name)
    else
        call s:pump(s:getter_frame, 'get'.fname, indent, type, name)
    endif
    call s:pump(s:setter_frame, 'set'.fname, indent, type, name)
endf

fu! s:pump(frames, func, indent, type, name)
    let ap = line('$') - 1
    let r = append(ap, '')
    for frame in a:frames
        let ap += 1
        let df = substitute(frame, '{{func}}', a:func, 'g')
        let df = substitute(df, '{{type}}', a:type, 'g')
        let df = substitute(df, '{{name}}', a:name, 'g')
        let df = a:indent . df
        let r = append(ap, df)
    endfor
endf

com! -range Jgs :call Jgs(<line1>, <line2>)

let &cpo = s:save_cpo
unlet s:save_cpo
