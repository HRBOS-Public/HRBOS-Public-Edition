ASM = nasm
ASMFLAGS = -f bin

MBR_SRC = mbrboot.asm
#PBR_SRC = pbrboot.asm

MBR_TARGET = mbrboot.bin
#PBR_TARGET = pbrboot.bin

.PHONY: all mbr clean

all: mbr

mbr: $(MBR_TARGET)

#pbr: $(PBR_TARGET)

$(MBR_TARGET): $(MBR_SRC)
	$(ASM) $(ASMFLAGS) $< -o $@

#$(PBR_TARGET): $(PBR_SRC)
	#$(ASM) $(ASMFLAGS) $< -o $@

clean:
	rm -f *.bin