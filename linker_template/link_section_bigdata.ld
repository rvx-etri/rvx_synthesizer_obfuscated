	.bigdata :
	{
		. = ALIGN("${DATA_ALIGN_SIZE}");
		*(.bigdata)
	} >"${BIGDATA_MEMORY_REGION}"

	.once :
	{
		. = ALIGN("${DATA_ALIGN_SIZE}");
		*(.once)
	} >"${BIGDATA_MEMORY_REGION}"

	.bigdata_bss :
	{
		. = ALIGN("${DATA_ALIGN_SIZE}");
		_bigdata_bss_start = .;
		*(.bigdata_bss)
		_bigdata_bss_end = NEXT(4);
	} >"${BIGDATA_MEMORY_REGION}"
