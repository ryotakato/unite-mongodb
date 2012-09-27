" unite-mongodb.vim

let s:save_cpo = &cpo
set cpo&vim

" source object
let s:source = {
      \ 'name' : 'mongodb',
      \ 'description' : 'candidates from MongoDB',
      \ }


" main of this source
function! s:source.gather_candidates(args, context)
  let candidates = []

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
