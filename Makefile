OBJS = obj/bg_ram_tests.o \
       obj/comm_ram_tests.o \
       obj/ddragon_diag.o \
       obj/fg_ram_tests.o \
       obj/fg_util.o \
       obj/input_tests.o \
       obj/interrupt_handlers.o \
       obj/mem_tester.o \
       obj/mem_viewer.o \
       obj/misc_util.o \
       obj/mcu_tests.o \
       obj/obj_ram_tests.o \
       obj/pal_ext_ram_tests.o \
       obj/pal_ram_tests.o \
       obj/print_error.o \
       obj/scroll_tests.o \
       obj/sound_tests.o \
       obj/vector_table.o \
       obj/video_dac_tests.o \
       obj/work_ram_tests.o

INCS = include/ddragon.inc include/ddragon_diag.inc include/error_codes.inc \
       include/macros.inc

VASM = vasm6809_oldstyle
VASM_FLAGS = -Fvobj -6309 -chklabels -Iinclude -quiet
VLINK = vlink
VLINK_FLAGS = -brawbin1 -Tddragon_diag.ld
OUTPUT_DIR = bin
OBJ_DIR = obj
MKDIR = mkdir

$(OUTPUT_DIR)/ddragon-diag.bin: $(OBJ_DIR) $(OUTPUT_DIR) $(OBJS)
	$(VLINK) $(VLINK_FLAGS) -o $(OUTPUT_DIR)/ddragon-diag.bin $(OBJS)
	@echo
	@ls -l $(OUTPUT_DIR)/ddragon-diag.bin

$(OBJ_DIR)/%.o: %.asm $(INCS)
	$(VASM) $(VASM_FLAGS) -o $@ $<

$(OUTPUT_DIR):
	$(MKDIR) $(OUTPUT_DIR)

$(OBJ_DIR):
	$(MKDIR) $(OBJ_DIR)

clean:
	rm -f $(OUTPUT_DIR)/ddragon-diag.bin $(OBJ_DIR)/*.o

