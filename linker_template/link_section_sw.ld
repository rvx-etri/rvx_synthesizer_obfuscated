	.init	:
  {
    _text_start = .;
		_cacheable_start = .;
		*(.text.init)
		. = ALIGN(8);
		*(.init)
		. = ALIGN(8);
  } >"${TEXT_MEMORY_REGION}"

	.text :
  {
    *(.text.unlikely .text.unlikely.*)
    *(.text.startup .text.startup.*)
    *(.text .text.*)
    *(.gnu.linkonce.t.*)
		. = ALIGN(8);
  } >"${TEXT_MEMORY_REGION}"

  .fini           :
	{
		KEEP (*(SORT_NONE(.fini)))
	} >"${TEXT_MEMORY_REGION}"

	.preinit_array  :
	{
		PROVIDE_HIDDEN (__preinit_array_start = .);
		KEEP (*(.preinit_array))
		PROVIDE_HIDDEN (__preinit_array_end = .);
	} >"${TEXT_MEMORY_REGION}"

	.init_array     :
	{
		PROVIDE_HIDDEN (__init_array_start = .);
		KEEP (*(SORT_BY_INIT_PRIORITY(.init_array.*) SORT_BY_INIT_PRIORITY(.ctors.*)))
		KEEP (*(.init_array EXCLUDE_FILE (*crtbegin.o *crtbegin?.o *crtend.o *crtend?.o ) .ctors))
		PROVIDE_HIDDEN (__init_array_end = .);
	} >"${TEXT_MEMORY_REGION}"

	.fini_array     :
	{
		PROVIDE_HIDDEN (__fini_array_start = .);
		KEEP (*(SORT_BY_INIT_PRIORITY(.fini_array.*) SORT_BY_INIT_PRIORITY(.dtors.*)))
		KEEP (*(.fini_array EXCLUDE_FILE (*crtbegin.o *crtbegin?.o *crtend.o *crtend?.o ) .dtors))
		PROVIDE_HIDDEN (__fini_array_end = .);
	} >"${TEXT_MEMORY_REGION}"

	.ctors          :
	{
		KEEP (*crtbegin.o(.ctors))
		KEEP (*crtbegin?.o(.ctors))
		KEEP (*(EXCLUDE_FILE (*crtend.o *crtend?.o ) .ctors))
		KEEP (*(SORT(.ctors.*)))
		KEEP (*(.ctors))
	} >"${TEXT_MEMORY_REGION}"

	.dtors          :
	{
		KEEP (*crtbegin.o(.dtors))
		KEEP (*crtbegin?.o(.dtors))
		KEEP (*(EXCLUDE_FILE (*crtend.o *crtend?.o ) .dtors))
		KEEP (*(SORT(.dtors.*)))
		KEEP (*(.dtors))
    _text_end = .;
	} >"${TEXT_MEMORY_REGION}"

  .rodata	:
  {
    *(.rdata)
    *(.rodata .rodata.*)
    *(.gnu.linkonce.r.*)
		. = ALIGN(8);
  } >"${CACHEABLE_MEMORY_REGION}"
	
	.stack :
	{
		. = ALIGN("${DATA_ALIGN_SIZE}");
		. += ("${STACK_SIZE}"*"${NUM_REAL_CORE}");
		. = ALIGN("${DATA_ALIGN_SIZE}");
		PROVIDE( _sp = . );
	} >"${CACHEABLE_MEMORY_REGION}"

	.cached :
	{
		. = ALIGN("${DATA_ALIGN_SIZE}");
		*(.cached)
		*(.exclusive)
		_cacheable_end = NEXT("${DATA_ALIGN_SIZE}");
  } >"${CACHEABLE_MEMORY_REGION}"
