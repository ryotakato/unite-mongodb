" unite-mongodb.vim

let s:save_cpo = &cpo
set cpo&vim

" source object
let s:db_source = {
      \ 'name' : 'mongodb',
      \ 'description' : 'candidates from MongoDB',
      \ }

let s:col_source = {
      \ 'name' : 'mongodb_col',
      \ 'description' : 'candidates from MongoDB',
      \ }

" main process of mongodb_db
function! s:db_source.gather_candidates(args, context) "{{{
  let candidates = []
  
  call unite#print_source_message('MongoDB > ', s:db_source.name)

  " get dbs as string by vimproc,mongo shell
  let dbs_line = vimproc#system("mongo --quiet --eval 'db.getMongo().getDBNames()'")
  " last char is ^@, so remove last and split by ','
  let dbs = split(dbs_line[0 : strlen(dbs_line) - 2], ",")

  "call append(line('$'), dbs)
  
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

  " print breadcrumb
  call unite#print_source_message("MongoDB > ".a:args[0]." > ", s:db_source.name)

  " get cols as string by vimproc,mongo shell
  let cols_line = vimproc#system(
              \ "mongo ".
              \ a:args[0] .
              \ " --quiet --eval 'db.getCollectionNames()'")
  " last char is ^@, so remove last and split by ','
  let cols = split(cols_line[0 : strlen(cols_line) - 2], ",")

  "call append(line('$'), dbs)
  
  " set to unite candidates
  for col in cols
    call add(candidates, {
          \ "word": col,
          \ "kind": "source",
          \ "action__source_name" : "mongodb",
          \ })
    unlet col
  endfor

  return candidates
endfunction "}}}



" define unite source
function! unite#sources#mongodb#define()
  return [s:db_source, s:col_source]
endfunction



let &cpo = s:save_cpo
unlet s:save_cpo


" vim: foldmethod=marker
