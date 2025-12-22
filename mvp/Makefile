ASMS = $(wildcard bank_*.asm)
OBJS = $(ASMS:.asm=.o)
ROM = game.gb

all: $(ROM)

$(ROM): $(OBJS)
	@rgblink -o $@ $^
	@rgbfix -v -p 0 $@

%.o: %.asm
	@rgbasm -E -o $@ $<

clean:
	@rm -f $(OBJS) $(ROM)

verify: clean $(ROM)
	echo "b48161623f12f86fec88320166a21fce  $(ROM)" | md5sum -c
	echo "3a4ddb39b234a67ffb361ee7abc3d23e0a8b1c89  $(ROM)" | sha1sum -c
	$(MAKE) clean
