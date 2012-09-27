" unite-mongodb.vim

let s:save_cpo = &cpo
set cpo&vim

" source object
let s:source = {
      \ 'name' : 'mongodb',
      \ 'description' : 'candidates from MongoDB',
      \ }


"
function! s:source.gather_candidates(args, context)
  let candidates = []

  let dbs = ["aaa","bbb"]
  
  for db in dbs
    call add(candidates, {
          \ "word": db,
          \ "kind": "source",
          \ "action__source_name" : "mongodb",
          \ })
    unlet db
  endfor


  return candidates
endfunction


" define unite source
function! unite#sources#mongodb#define()
  return s:source
endfunction



let &cpo = s:save_cpo
unlet s:save_cpo
