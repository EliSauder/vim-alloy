" alloy.vim: Vim syntax file for Grafana Alloy syntax.

if exists('b:current_syntax')
  finish
end

function! s:FoldEnable(...) abort
  if a:0 > 0
    return index(s:FoldEnable(), a:1) > -1
  endif
  return get(g:, 'go_fold_enable', ['block', 'import', 'varconst', 'package_comment'])
endfunction

function! s:HighlightStringSpellcheck() abort
  return get(g:, 'go_highlight_string_spellcheck', 1)
endfunction

syn keyword alloyDeclare    declare contained
syn keyword alloyArgument   argument contained
syn cluster alloyComponentKeywords contains=alloyDeclare,alloyArgument
hi def link alloyDeclare    Keyword
hi def link alloyArgument   Keyword

syn keyword alloyBool   true false contained
hi def link alloyBool   Boolean

syn keyword alloyNull   null contained
hi def link alloyNull   Constant

syn match alloyEscapeOctal display contained "\\[0-7]\{3}"
syn match alloyEscapeC display contained +\\[abfnrtv\\'"]+
syn match alloyEscapeX display contained "\\x\x\{2}"
syn match alloyEscapeU display contained "\\u\x\{4}"
syn match alloyEscapeBigU display contained "\\U\x\{8}"
syn match alloyEscapeError display contained +\\[^0-7xuUabfnrtv\\'"]+
hi def link alloyEscapeOctal    alloySpecialString
hi def link alloyEscapeC        alloySpecialString
hi def link alloyEscapeX        alloySpecialString
hi def link alloyEscapeU        alloySpecialString
hi def link alloyEscapeBigU     alloySpecialString
hi def link alloyEscapeError    alloySpecialError
hi def link alloySpecialString  Special
hi def link alloySpecialError   Error

" Strings and their contents
syn cluster     alloyStringGroup       contains=alloyEscapeOctal,alloyEscapeC,alloyEscapeX,alloyEscapeU,alloyEscapeBigU,alloyEscapeError
if s:HighlightStringSpellcheck()
  syn region      alloyString            start=+"+ skip=+\\\\\|\\"+ end=+"+ contains=@alloyStringGroup,@Spell oneline contained
  syn region      alloyRawString         start=+`+ end=+`+ contains=@Spell contained
else
  syn region      alloyString            start=+"+ skip=+\\\\\|\\"+ end=+"+ contains=@alloyStringGroup oneline contained
  syn region      alloyRawString         start=+`+ end=+`+ contained
endif
hi def link alloyString     String
hi def link alloyRawString  String

syn match alloyInt   "\<-\=\(0\|[1-9]_\?\(\d\|\d\+_\?\d\+\)*\)\%([Ee][-+]\=\d\+\)\=\>" contained
syn match alloyFloat "\<-\=\d\+\.\d*\%([Ee][-+]\=\d\+\)\=\>" contained
syn match alloyFloat "\<-\=\.\d\+\%([Ee][-+]\=\d\+\)\=\>" contained
hi def link alloyInt        Number
hi def link alloyFloat      Float

syn cluster alloyValues contains=alloyInt,alloyFloat,alloyString,alloyRawString,alloyBool,alloyNull

syn keyword alloyTodo contained TODO FIXME XXX BUG NOTE
hi def link alloyTodo Todo
syn region alloyComment start="//" end="$" contains=alloyTodo,@Spell
if s:FoldEnable('comment')
    syn region alloyComment start="/\*" end="\*/" contains=alloyTodo,@Spell fold
    syn match alloyComment  /\(^\s*//.*\n\)\+/ contains=alloyTodo,@Spell fold
else
    syn region alloyComment start="/\*" end="\*/" contains=alloyTodo,@Spell
end
hi def link alloyComment    Comment

syn match alloyBlockHeader /[^=]\{-}\({\)\@=/ contains=alloyComponent,alloyComment nextgroup=alloyBlock
syn region alloyBlock start="{" end="}" contained contains=alloyAttribute,alloyBlockHeader,alloyComment fold
syn match alloyComponent /^\s\{-}\h\(\w\|\.\)*/ contained contains=alloyComponentSeparator,@alloyComponentKeywords skipwhite nextgroup=alloyComponentLabel
syn match alloyComponentReference /\h\(\w\|\.\)*/ contained contains=alloyComponentSeparator,@alloyComponentKeywords skipwhite
syn match alloyComponentLabel /"\(\h\w*\)"/ contained
syn match alloyComponentSeparator "\." contained

hi def link alloyComponent  Structure
hi def link alloyComponentReference  Structure
hi def link alloyComponentSeparator  Delimiter
hi def link alloyComponentLabel Identifier

syn match alloyAttribute /\h\w*\s*\(=\)\@=/ skipwhite contained nextgroup=alloyAssignmentOperator
hi def link alloyAttribute Identifier

syn match alloyAssignmentOperator "\s*=.*" contained skipwhite contains=@alloyExpression
hi def link alloyAssignmentOperator Operator

syn region alloyObject start="{" end="}" contained contains=alloyObjectProperty,alloyListSeparator,alloyComment
syn match alloyObjectProperty /"\?\h\w*"\?\s*\(=\)\@=/ skipwhite contained contains=alloyObjectPropertyStringName,alloyComment nextgroup=alloyAssignmentOperator
syn match alloyObjectPropertyStringName +"+ contained skipwhite
hi def link alloyObjectProperty Identifier
hi def link alloyObjectPropertyStringName String

syn match alloyListSeparator "," contained skipwhite
hi def link alloyListSeparator Delimiter

syn region alloyArray start="\[" end="]" contained skipwhite contains=@alloyExpression,alloyListSeparator,alloyComment

syn region alloyFunctionCall start=/\(\h\w*\.\)*\(\h\w*\)\((\)\@=/ end=")" contains=alloyComponentReference,@alloyExpression,alloyListSeparator,alloyComment

syn cluster alloyExpression contains=alloyFunctionCall,alloyObject,alloyArray,@alloyValues,alloyComponentReference,


let b:current_syntax = 'alloy'
