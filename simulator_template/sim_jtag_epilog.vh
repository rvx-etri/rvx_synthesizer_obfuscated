          endcase
        end
        direct_memory_load = 0;
      `else
        $display("[JTAG:INFO] slow SRAM load start");
        write_memory_using_jtag(addr, CHANGE_ENDIAN_HEX2MAN(32,`MEMORY_ENDIAN,hex_memory[0]));
        print_memory_using_jtag(addr);
        for(i=0; i<`SRAM_HEX_SIZE; i=i+1)
        begin
          if((i&32'h FF)==32'h FF)
          begin
            $display("[JTAG:INFO] slow SRAM load is processing... %8d", i);
          end
          write_memory_using_jtag(addr, CHANGE_ENDIAN_HEX2MAN(32,`MEMORY_ENDIAN,hex_memory[i]));
          addr = addr + 4;
        end
      `endif
      $display("[JTAG:INFO] SRAM load end");
    `endif

		// dram
    `ifdef INCLUDE_EXT_MRAM
      $display("[JTAG:INFO] MRAM set");
      write_memory_using_jtag(`I_SYSTEM_EXT_MRAM_CONTROL_BASEADDR+`MMAP_OFFSET_MMIO_CORE_CONFIG_SAWD, (1<<3));
    `endif
		`ifdef USE_LARGE_RAM
			$readmemh(`DRAM_HEX_FILE, hex_memory);
			addr = `LARGE_RAM_BASEADDR;
			num_word_in_line = `DRAM_WIDTH/32;
			`ifdef FAST_APP_LOAD_DRAM
				direct_memory_load = 1;
        `ifdef INCLUDE_EXT_MRAM
  				$display("[JTAG:INFO] fast MRAM load start");
        `else
          $display("[JTAG:INFO] fast DRAM load start");
        `endif
				for(i=0; i<`DRAM_HEX_SIZE; i=i+1)
				begin
					word_index = `DRAM_OFFSET + i;
					word_index_in_line = word_index % num_word_in_line;
					line_index_in_cell = word_index / num_word_in_line;
					`DRAM_CELL[line_index_in_cell][(word_index_in_line+1)*32-1-:32] = CHANGE_ENDIAN_HEX2MAN(32,`MEMORY_ENDIAN,hex_memory[i]);
					//$display("%8x : %8x", word_index, hex_memory[i]);
				end
				direct_memory_load = 0;
			`else
        `ifdef INCLUDE_EXT_MRAM
  				$display("[JTAG:INFO] slow MRAM load start");
        `else
          $display("[JTAG:INFO] slow DRAM load start");
        `endif
				for(i=0; i<`DRAM_HEX_SIZE; i=i+1)
				begin
					write_memory_using_jtag(addr, CHANGE_ENDIAN_HEX2MAN(32,`MEMORY_ENDIAN,hex_memory[i]));
					addr = addr + 4;
				end
			`endif
      `ifdef INCLUDE_EXT_MRAM
        $display("[JTAG:INFO] MRAM load end");
      `else
        $display("[JTAG:INFO] DRAM load end");
      `endif
		`endif
		#1
		app_is_loaded = 1;
	end
end
