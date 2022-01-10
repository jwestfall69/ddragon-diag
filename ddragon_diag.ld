MEMORY {
  ROM: org=0x8000, len=0x4000
  ERR: org=0xc000, len=0x3ff2
  VEC: org=0xfff2, len=0xe
}

SECTIONS {
  .rom: {
    *(text)
  } >ROM
  .errs: {
    *(errors)
  } >ERR
  .vecs: {
    *(vectors)
  } >VEC
}
