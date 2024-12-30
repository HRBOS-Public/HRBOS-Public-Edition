.PHONY: all clean boot

all: boot

boot:
	$(MAKE) -C boot

clean:
	$(MAKE) -C boot clean
