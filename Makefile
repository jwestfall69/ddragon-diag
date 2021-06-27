OBJS = obj/bg_ram_tests.o \
       obj/comm_ram_tests.o \
       obj/ddragon_diag.o \
       obj/fg_ram_tests.o \
       obj/fg_util.o \
       obj/input_tests.o \
       obj/interrupt_handlers.o \
       obj/mem_tester.o \
       obj/misc_util.o \
       obj/obj_ram_tests.o \
       obj/pal_ext_ram_tests.o \
       obj/pal_ram_tests.o \
       obj/print_error.o \
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
DD = dd

$(OUTPUT_DIR)/ddragon-diag.bin: $(DIR) $(OBJ_DIR) $(OUTPUT_DIR) $(OBJS)
	$(VLINK) $(VLINK_FLAGS) -o $(OUTPUT_DIR)/ddragon-diag.bin $(OBJS)
	@echo
	@ls -l $(OUTPUT_DIR)/ddragon-diag.bin

$(OBJ_DIR)/bg_ram_tests.o: bg_ram_tests.asm $(INCS)
	$(VASM) $(VASM_FLAGS) -o $(OBJ_DIR)/bg_ram_tests.o bg_ram_tests.asm

$(OBJ_DIR)/comm_ram_tests.o: comm_ram_tests.asm $(INCS)
	$(VASM) $(VASM_FLAGS) -o $(OBJ_DIR)/comm_ram_tests.o comm_ram_tests.asm

$(OBJ_DIR)/ddragon_diag.o: ddragon_diag.asm $(INCS)
	$(VASM) $(VASM_FLAGS) -o $(OBJ_DIR)/ddragon_diag.o ddragon_diag.asm

$(OBJ_DIR)/fg_ram_tests.o: fg_ram_tests.asm $(INCS)
	$(VASM) $(VASM_FLAGS) -o $(OBJ_DIR)/fg_ram_tests.o fg_ram_tests.asm

$(OBJ_DIR)/fg_util.o: fg_util.asm $(INCS)
	$(VASM) $(VASM_FLAGS) -o $(OBJ_DIR)/fg_util.o fg_util.asm

$(OBJ_DIR)/input_tests.o: input_tests.asm $(INCS)
	$(VASM) $(VASM_FLAGS) -o $(OBJ_DIR)/input_tests.o input_tests.asm

$(OBJ_DIR)/interrupt_handlers.o: interrupt_handlers.asm $(INCS)
	$(VASM) $(VASM_FLAGS) -o $(OBJ_DIR)/interrupt_handlers.o interrupt_handlers.asm

$(OBJ_DIR)/mem_tester.o: mem_tester.asm $(INCS)
	$(VASM) $(VASM_FLAGS) -o $(OBJ_DIR)/mem_tester.o mem_tester.asm

$(OBJ_DIR)/misc_util.o: misc_util.asm $(INCS)
	$(VASM) $(VASM_FLAGS) -o $(OBJ_DIR)/misc_util.o misc_util.asm

$(OBJ_DIR)/obj_ram_tests.o: obj_ram_tests.asm $(INCS)
	$(VASM) $(VASM_FLAGS) -o $(OBJ_DIR)/obj_ram_tests.o obj_ram_tests.asm

$(OBJ_DIR)/pal_ext_ram_tests.o: pal_ext_ram_tests.asm $(INCS)
	$(VASM) $(VASM_FLAGS) -o $(OBJ_DIR)/pal_ext_ram_tests.o pal_ext_ram_tests.asm

$(OBJ_DIR)/pal_ram_tests.o: pal_ram_tests.asm $(INCS)
	$(VASM) $(VASM_FLAGS) -o $(OBJ_DIR)/pal_ram_tests.o pal_ram_tests.asm

$(OBJ_DIR)/print_error.o: print_error.asm $(INCS)
	$(VASM) $(VASM_FLAGS) -o $(OBJ_DIR)/print_error.o print_error.asm

$(OBJ_DIR)/sound_tests.o: sound_tests.asm $(INCS)
	$(VASM) $(VASM_FLAGS) -o $(OBJ_DIR)/sound_tests.o sound_tests.asm

$(OBJ_DIR)/vector_table.o: vector_table.asm $(INCS)
	$(VASM) $(VASM_FLAGS) -o $(OBJ_DIR)/vector_table.o vector_table.asm

$(OBJ_DIR)/video_dac_tests.o: video_dac_tests.asm $(INCS)
	$(VASM) $(VASM_FLAGS) -o $(OBJ_DIR)/video_dac_tests.o video_dac_tests.asm

$(OBJ_DIR)/work_ram_tests.o: work_ram_tests.asm $(INCS)
	$(VASM) $(VASM_FLAGS) -o $(OBJ_DIR)/work_ram_tests.o work_ram_tests.asm

$(OUTPUT_DIR):
	$(MKDIR) $(OUTPUT_DIR)

$(OBJ_DIR):
	$(MKDIR) $(OBJ_DIR)

clean:
	rm -f $(OUTPUT_DIR)/ddragon-diag.bin $(OBJ_DIR)/*.o

