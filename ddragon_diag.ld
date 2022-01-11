MEMORY {
  RESET: org=0x8000, len=0x5d
  MAIN: org=0x805d, len=0x3fa3
  ERR: org=0xc000, len=0x3ff2
  VEC: org=0xfff2, len=0xe
}

SECTIONS {
  .reset: {
    FILL8(0x12);
    RESERVE(0x5a);
    *(reset)
  } >RESET
  .main: {
    *(text)
  } >MAIN
  .errs: {
    *(errors)
  } >ERR
  .vecs: {
    *(vectors)
  } >VEC
}
