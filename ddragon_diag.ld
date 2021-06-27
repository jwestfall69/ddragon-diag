MEMORY {
  ROM: org=0x8000, len=0x7ff2
  VEC: org=0xfff2, len=0xe
}

SECTIONS {
  .rom: {
    *(text)
  } >ROM

  .vecs: {
    *(vectors)
  } >VEC
}
