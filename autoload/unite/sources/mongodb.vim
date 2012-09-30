" unite-mongodb.vim
let s:save_cpo = &cpo
set cpo&vim

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
  let a_count = len(a:args)

  if (a_count == 0) 
    return s:db_list()
  elseif (a_count == 1)
    return s:col_list(a:args[0])
  else
    return s:doc_list(a:args[0], a:args[1])
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

  return candidates

endfunction "}}}

" return col list
function! s:col_list(db_name) "{{{
  let candidates = []

  " print breadcrumb
  call unite#print_source_message("MongoDB > ".a:db_name." > ", s:source.name)

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

  return candidates

endfunction "}}}




let &cpo = s:save_cpo
unlet s:save_cpo

" vim: foldmethod=marker
