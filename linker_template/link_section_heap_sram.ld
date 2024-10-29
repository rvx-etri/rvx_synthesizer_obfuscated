  .must_sram :
	{
    . = ALIGN("${DATA_ALIGN_SIZE}");
	} >sram

  .heap_sram :
	{
		. = ALIGN("${DATA_ALIGN_SIZE}");
		_heap_sram_baseaddr = .;
	} >sram
