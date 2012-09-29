" unite-mongodb.vim
let s:save_cpo = &cpo
set cpo&vim

" define unite source
function! unite#sources#mongodb#define()
  return [s:db_source, s:col_source, s:doc_source]
endfunction

" source object
let s:db_source = {
      \ 'name' : 'mongodb',
      \ 'description' : 'candidates from MongoDB',
      \ }

let s:col_source = {
      \ 'name' : 'mongodb_col',
      \ 'description' : 'candidates from MongoDB Collection',
      \ }

let s:doc_source = {
      \ 'name' : 'mongodb_doc',
      \ 'description' : 'candidates from MongoDB Document',
      \ }

" main process of mongodb
function! s:db_source.gather_candidates(args, context) "{{{
  let candidates = []
  
  call unite#print_source_message('MongoDB > ', s:db_source.name)

  " get dbs as string by vimproc,mongo shell
  let dbs_line = vimproc#system("mongo --quiet --eval 'db.getMongo().getDBNames()'")
  " split by '\n'(=='^@') or ',' 
  let dbs = split(dbs_line, '[\n,]')

  " set to unite candidates
  for db in dbs
    call add(candidates, {
          \ "word": db,
          \ "kind": "source",
          \ "action__source_name" : ["mongodb_col", db],
          \ })
    unlet db
  endfor

  return candidates
endfunction "}}}

" main process of mongodb_col
function! s:col_source.gather_candidates(args, context) "{{{
  let candidates = []

  let db_name = a:args[0]

  " print breadcrumb
  call unite#print_source_message("MongoDB > ".db_name." > ", s:db_source.name)

  " get cols as string by vimproc,mongo shell
  let cols_line = vimproc#system(
              \ "mongo "
              \ .db_name
              \ ." --quiet --eval 'db.getCollectionNames()'")
  " split by '\n'(=='^@') or ',' 
  let cols = split(cols_line, '[\n,]')

  " set to unite candidates
  for col in cols
    call add(candidates, {
          \ "word": col,
          \ "kind": "source",
          \ "action__source_name" : ["mongodb_doc", db_name, col],
          \ })
    unlet col
  endfor

  return candidates
endfunction "}}}

" main process of mongodb_doc
function! s:doc_source.gather_candidates(args, context) "{{{
  let candidates = []

  let db_name = a:args[0]
  let col_name = a:args[1]

  " print breadcrumb
  call unite#print_source_message("MongoDB > ".db_name." > ".col_name, s:db_source.name)

  " get cols as string by vimproc,mongo shell
  let docs_line = vimproc#system(
              \ "mongo "
              \ .db_name
              \ ." --quiet --eval 'db."
              \ .col_name
              \ .".find().forEach(printjson)'")

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

  return candidates
endfunction "}}}




let &cpo = s:save_cpo
unlet s:save_cpo

" vim: foldmethod=marker
