  .must_dram :
	{
    . = ALIGN("${DATA_ALIGN_SIZE}");
	} >dram

  .heap_dram :
	{
		. = ALIGN("${DATA_ALIGN_SIZE}");
		_heap_dram_baseaddr = .;
	} >dram
