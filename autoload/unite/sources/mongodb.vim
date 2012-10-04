" unite-mongodb.vim
let s:save_cpo = &cpo
set cpo&vim


let s:pre_db = ""
let s:pre_col = ""

" define unite source
function! unite#sources#mongodb#define()
  return executable('mongo') && unite#util#has_vimproc() 
              \ ? [s:source]
              \ : []
endfunction

" source object
let s:source = {
      \ 'name' : 'mongodb',
      \ 'description' : 'candidates from MongoDB',
      \ }

" main process of mongodb
function! s:source.gather_candidates(args, context) "{{{
  let a_cnt = len(a:args)

  " check input & pre-select
  if (a_cnt == 0) 
    let select_db = s:pre_db
    let select_col = s:pre_col
  elseif (a_cnt == 1)
    let select_db = a:args[0]
    let select_col = s:pre_col
  else
    let select_db = a:args[0]
    let select_col = a:args[1]
  end

  " call each list
  if select_db == "" && select_col == ""
    return s:db_list()
  elseif select_col == ""
    return s:col_list(select_db)
  else
    return s:doc_list(select_db, select_col)
  end

endfunction "}}}


" return db list
function! s:db_list() "{{{
  let candidates = []
  
  call unite#print_source_message('MongoDB > ', s:source.name)

  " get dbs as string by vimproc,mongo shell
  let dbs_line = vimproc#system("mongo --quiet --eval 'db.getMongo().getDBNames()'")
  " split by '\n'(=='^@') or ',' 
  let dbs = split(dbs_line, '[\n,]')

  " set to unite candidates
  for db in dbs
    call add(candidates, {
          \ "word": db,
          \ "kind": "source",
          \ "action__source_name" : ["mongodb", db],
          \ })
    unlet db
  endfor

  " reset pre-select db, col
  let s:pre_db = ""
  let s:pre_col = ""

  return candidates

endfunction "}}}

" return col list
function! s:col_list(db_name) "{{{
  let candidates = []

  " print breadcrumb
  call unite#print_source_message("MongoDB > ".a:db_name." > ", s:source.name)

  call s:set_prompt("MongoDB/".a:db_name."/")

  " get cols as string by vimproc,mongo shell
  let cols_line = vimproc#system(
              \ "mongo "
              \ .a:db_name
              \ ." --quiet --eval 'db.getCollectionNames()'")
  " split by '\n'(=='^@') or ',' 
  let cols = split(cols_line, '[\n,]')

  " set to unite candidates
  for col in cols
    call add(candidates, {
          \ "word": col,
          \ "kind": "source",
          \ "action__source_name" : ["mongodb", a:db_name, col],
          \ })
    unlet col
  endfor

  " set db_name as pre-select
  let s:pre_db = a:db_name
  " reset pre-select col
  let s:pre_col = ""

  return candidates

endfunction "}}}

" return doc list
function! s:doc_list(db_name, col_name) "{{{
  let candidates = []
  
  " print breadcrumb
  call unite#print_source_message("MongoDB > ".a:db_name." > ".a:col_name, s:source.name)

  " get cols as string by vimproc,mongo shell
  let docs_line = vimproc#system(
              \ "mongo "
              \ .a:db_name
              \ ." --quiet --eval 'db."
              \ .a:col_name
              \ .".find().forEach(printjsononeline)'")

  " split by '\n'(=='^@') or ',' 
  let docs = split(docs_line, '[\n]')

  " set to unite candidates
  for doc in docs
    call add(candidates, {
          \ "word": doc,
          \ "kind": "word",
          \ })
    unlet doc
  endfor

  " set db_name, col_name as pre-select
  let s:pre_db = a:db_name
  let s:pre_col = a:col_name
  
  return candidates

endfunction "}}}

" set to unite current prompt
function! s:set_prompt(str)
  let unite = unite#get_current_unite()
  let unite.prompt = a:str
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: foldmethod=marker
