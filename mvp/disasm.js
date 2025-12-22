#!/usr/bin/env node
/**
 * Game Boy ROM Disassembler - Ultimate Edition
 * 
 * ROADMAP DES AMÉLIORATIONS (du plus simple au plus complexe) :
 * 1. [x] Hardware Mapping : Nommer les registres I/O ($FF40 -> rLCDC, etc.)
 * 2. [ ] Identification Data : Repérer automatiquement les blocs GFX (Tiles) et Audio.
 * 3. [ ] Résolution JP HL : Utiliser l'émulation pour suivre les Jump Tables.
 * 4. [ ] Analyse de Pile : Suivre SP pour déduire les signatures de fonctions.
 * 5. [ ] Export CFG : Générer des graphes de flux (DOT/Graphviz).
 * 6. [ ] Support Charmaps : Permettre l'usage de tables de caractères (RGBDS).
 * 
 * Features:
 * - Recursive descent flow analysis
 * - Multi-bank ROM support with MBC detection
 * - Configurable entry points
 * - Symbol table generation
 * - Professional RGBDS output
 */

const fs = require('fs').promises;
const path = require('path');

// ============================================================================
// CONSTANTS
// ============================================================================

const Memory = Object.freeze({
	ROM_BANK_SIZE: 0x4000,      // 16 KB per bank
	ROM0_START: 0x0000,
	ROM0_END: 0x3FFF,
	ROMX_START: 0x4000,
	ROMX_END: 0x7FFF,
	VRAM_START: 0x8000,
	CARTRIDGE_TYPE_ADDR: 0x0147,
	ROM_SIZE_ADDR: 0x0148,
	TITLE_START: 0x0134,
	TITLE_END: 0x0143,
});

const EntryPoints = Object.freeze({
	RESET_VECTORS: [0x0000, 0x0008, 0x0010, 0x0018, 0x0020, 0x0028, 0x0030, 0x0038],
	INTERRUPT_VECTORS: [0x0040, 0x0048, 0x0050, 0x0058, 0x0060],
	MAIN_ENTRY: 0x0100,
});

const FlowType = Object.freeze({
	NORMAL: 'normal',
	JUMP: 'jump',
	JUMP_HL: 'jump_hl',
	JUMP_COND: 'jump_cond',
	JR: 'jr',
	JR_COND: 'jr_cond',
	CALL: 'call',
	CALL_COND: 'call_cond',
	RET: 'ret',
	RET_COND: 'ret_cond',
	RST: 'rst',
	STOP: 'stop',
	HALT: 'halt',
	INVALID: 'invalid',
});

// ============================================================================
// OPCODE TABLES
// ============================================================================

class OpcodeTable {
	constructor() {
		this.main = new Map();
		this.cb = new Map();
		this._buildMainTable();
		this._buildCBTable();
	}

	static REGS_8 = ['b', 'c', 'd', 'e', 'h', 'l', '[hl]', 'a'];
	static REGS_16 = ['bc', 'de', 'hl', 'sp'];
	static REGS_16_STACK = ['bc', 'de', 'hl', 'af'];
	static REGS_16_MEM = ['bc', 'de', 'hl+', 'hl-'];
	static CONDITIONS = ['nz', 'z', 'nc', 'c'];
	static ALU_OPS = ['add a,', 'adc a,', 'sub', 'sbc a,', 'and', 'xor', 'or', 'cp'];
	static CB_OPS = ['rlc', 'rrc', 'rl', 'rr', 'sla', 'sra', 'swap', 'srl'];

	_buildMainTable() {
		// Row 0x00
		this._set(0x00, 'nop', 1);
		this._set(0x01, 'ld bc, {d16}', 3);
		this._set(0x02, 'ld [bc], a', 1);
		this._set(0x03, 'inc bc', 1);
		this._set(0x04, 'inc b', 1);
		this._set(0x05, 'dec b', 1);
		this._set(0x06, 'ld b, {d8}', 2);
		this._set(0x07, 'rlca', 1);
		this._set(0x08, 'ld [{a16}], sp', 3);
		this._set(0x09, 'add hl, bc', 1);
		this._set(0x0A, 'ld a, [bc]', 1);
		this._set(0x0B, 'dec bc', 1);
		this._set(0x0C, 'inc c', 1);
		this._set(0x0D, 'dec c', 1);
		this._set(0x0E, 'ld c, {d8}', 2);
		this._set(0x0F, 'rrca', 1);

		// Row 0x10 - STOP is technically 2 bytes, but often 1 byte in ROMs
		this._set(0x10, 'db $10', 1, FlowType.STOP);
		this._set(0x11, 'ld de, {d16}', 3);
		this._set(0x12, 'ld [de], a', 1);
		this._set(0x13, 'inc de', 1);
		this._set(0x14, 'inc d', 1);
		this._set(0x15, 'dec d', 1);
		this._set(0x16, 'ld d, {d8}', 2);
		this._set(0x17, 'rla', 1);
		this._set(0x18, 'jr {r8}', 2, FlowType.JR);
		this._set(0x19, 'add hl, de', 1);
		this._set(0x1A, 'ld a, [de]', 1);
		this._set(0x1B, 'dec de', 1);
		this._set(0x1C, 'inc e', 1);
		this._set(0x1D, 'dec e', 1);
		this._set(0x1E, 'ld e, {d8}', 2);
		this._set(0x1F, 'rra', 1);

		// Row 0x20
		this._set(0x20, 'jr nz, {r8}', 2, FlowType.JR_COND);
		this._set(0x21, 'ld hl, {d16}', 3);
		this._set(0x22, 'ld [hl+], a', 1);
		this._set(0x23, 'inc hl', 1);
		this._set(0x24, 'inc h', 1);
		this._set(0x25, 'dec h', 1);
		this._set(0x26, 'ld h, {d8}', 2);
		this._set(0x27, 'daa', 1);
		this._set(0x28, 'jr z, {r8}', 2, FlowType.JR_COND);
		this._set(0x29, 'add hl, hl', 1);
		this._set(0x2A, 'ld a, [hl+]', 1);
		this._set(0x2B, 'dec hl', 1);
		this._set(0x2C, 'inc l', 1);
		this._set(0x2D, 'dec l', 1);
		this._set(0x2E, 'ld l, {d8}', 2);
		this._set(0x2F, 'cpl', 1);

		// Row 0x30
		this._set(0x30, 'jr nc, {r8}', 2, FlowType.JR_COND);
		this._set(0x31, 'ld sp, {d16}', 3);
		this._set(0x32, 'ld [hl-], a', 1);
		this._set(0x33, 'inc sp', 1);
		this._set(0x34, 'inc [hl]', 1);
		this._set(0x35, 'dec [hl]', 1);
		this._set(0x36, 'ld [hl], {d8}', 2);
		this._set(0x37, 'scf', 1);
		this._set(0x38, 'jr c, {r8}', 2, FlowType.JR_COND);
		this._set(0x39, 'add hl, sp', 1);
		this._set(0x3A, 'ld a, [hl-]', 1);
		this._set(0x3B, 'dec sp', 1);
		this._set(0x3C, 'inc a', 1);
		this._set(0x3D, 'dec a', 1);
		this._set(0x3E, 'ld a, {d8}', 2);
		this._set(0x3F, 'ccf', 1);

		// Rows 0x40-0x7F: LD r, r' (with HALT at 0x76)
		for (let i = 0x40; i <= 0x7F; i++) {
			if (i === 0x76) {
				this._set(0x76, 'halt', 1, FlowType.HALT);
			} else {
				const dst = OpcodeTable.REGS_8[(i >> 3) & 7];
				const src = OpcodeTable.REGS_8[i & 7];
				this._set(i, `ld ${dst}, ${src}`, 1);
			}
		}

		// Rows 0x80-0xBF: ALU operations
		for (let i = 0x80; i <= 0xBF; i++) {
			const op = OpcodeTable.ALU_OPS[(i >> 3) & 7];
			const reg = OpcodeTable.REGS_8[i & 7];
			this._set(i, `${op} ${reg}`, 1);
		}

		// Row 0xC0
		this._set(0xC0, 'ret nz', 1, FlowType.RET_COND);
		this._set(0xC1, 'pop bc', 1);
		this._set(0xC2, 'jp nz, {a16}', 3, FlowType.JUMP_COND);
		this._set(0xC3, 'jp {a16}', 3, FlowType.JUMP);
		this._set(0xC4, 'call nz, {a16}', 3, FlowType.CALL_COND);
		this._set(0xC5, 'push bc', 1);
		this._set(0xC6, 'add a, {d8}', 2);
		this._setRST(0xC7, 0x00);
		this._set(0xC8, 'ret z', 1, FlowType.RET_COND);
		this._set(0xC9, 'ret', 1, FlowType.RET);
		this._set(0xCA, 'jp z, {a16}', 3, FlowType.JUMP_COND);
		this._set(0xCB, 'PREFIX CB', 1); // Special handling
		this._set(0xCC, 'call z, {a16}', 3, FlowType.CALL_COND);
		this._set(0xCD, 'call {a16}', 3, FlowType.CALL);
		this._set(0xCE, 'adc a, {d8}', 2);
		this._setRST(0xCF, 0x08);

		// Row 0xD0
		this._set(0xD0, 'ret nc', 1, FlowType.RET_COND);
		this._set(0xD1, 'pop de', 1);
		this._set(0xD2, 'jp nc, {a16}', 3, FlowType.JUMP_COND);
		this._setInvalid(0xD3);
		this._set(0xD4, 'call nc, {a16}', 3, FlowType.CALL_COND);
		this._set(0xD5, 'push de', 1);
		this._set(0xD6, 'sub {d8}', 2);
		this._setRST(0xD7, 0x10);
		this._set(0xD8, 'ret c', 1, FlowType.RET_COND);
		this._set(0xD9, 'reti', 1, FlowType.RET);
		this._set(0xDA, 'jp c, {a16}', 3, FlowType.JUMP_COND);
		this._setInvalid(0xDB);
		this._set(0xDC, 'call c, {a16}', 3, FlowType.CALL_COND);
		this._setInvalid(0xDD);
		this._set(0xDE, 'sbc a, {d8}', 2);
		this._setRST(0xDF, 0x18);

		// Row 0xE0
		this._set(0xE0, 'ldh [{a8}], a', 2);
		this._set(0xE1, 'pop hl', 1);
		this._set(0xE2, 'ld [$ff00+c], a', 1);
		this._setInvalid(0xE3);
		this._setInvalid(0xE4);
		this._set(0xE5, 'push hl', 1);
		this._set(0xE6, 'and {d8}', 2);
		this._setRST(0xE7, 0x20);
		this._set(0xE8, 'add sp, {s8}', 2);
		this._set(0xE9, 'jp hl', 1, FlowType.JUMP_HL);
		this._set(0xEA, 'ld [{a16}], a', 3);
		this._setInvalid(0xEB);
		this._setInvalid(0xEC);
		this._setInvalid(0xED);
		this._set(0xEE, 'xor {d8}', 2);
		this._setRST(0xEF, 0x28);

		// Row 0xF0
		this._set(0xF0, 'ldh a, [{a8}]', 2);
		this._set(0xF1, 'pop af', 1);
		this._set(0xF2, 'ld a, [$ff00+c]', 1);
		this._set(0xF3, 'di', 1);
		this._setInvalid(0xF4);
		this._set(0xF5, 'push af', 1);
		this._set(0xF6, 'or {d8}', 2);
		this._setRST(0xF7, 0x30);
		this._set(0xF8, 'ld hl, sp{s8}', 2);
		this._set(0xF9, 'ld sp, hl', 1);
		this._set(0xFA, 'ld a, [{a16}]', 3);
		this._set(0xFB, 'ei', 1);
		this._setInvalid(0xFC);
		this._setInvalid(0xFD);
		this._set(0xFE, 'cp {d8}', 2);
		this._setRST(0xFF, 0x38);
	}

	_buildCBTable() {
		// 0x00-0x3F: Rotation/Shift operations
		for (let i = 0x00; i <= 0x3F; i++) {
			const op = OpcodeTable.CB_OPS[(i >> 3) & 7];
			const reg = OpcodeTable.REGS_8[i & 7];
			this.cb.set(i, { mnemonic: `${op} ${reg}`, length: 2 });
		}

		// 0x40-0x7F: BIT operations
		for (let i = 0x40; i <= 0x7F; i++) {
			const bit = (i >> 3) & 7;
			const reg = OpcodeTable.REGS_8[i & 7];
			this.cb.set(i, { mnemonic: `bit ${bit}, ${reg}`, length: 2 });
		}

		// 0x80-0xBF: RES operations
		for (let i = 0x80; i <= 0xBF; i++) {
			const bit = (i >> 3) & 7;
			const reg = OpcodeTable.REGS_8[i & 7];
			this.cb.set(i, { mnemonic: `res ${bit}, ${reg}`, length: 2 });
		}

		// 0xC0-0xFF: SET operations
		for (let i = 0xC0; i <= 0xFF; i++) {
			const bit = (i >> 3) & 7;
			const reg = OpcodeTable.REGS_8[i & 7];
			this.cb.set(i, { mnemonic: `set ${bit}, ${reg}`, length: 2 });
		}
	}

	_set(opcode, mnemonic, length, flow = FlowType.NORMAL) {
		this.main.set(opcode, { mnemonic, length, flow });
	}

	_setRST(opcode, target) {
		this.main.set(opcode, {
			mnemonic: `rst $${target.toString(16).padStart(2, '0')}`,
			length: 1,
			flow: FlowType.RST,
			target
		});
	}

	_setInvalid(opcode) {
		this.main.set(opcode, {
			mnemonic: `db $${opcode.toString(16).padStart(2, '0')}`,
			length: 1,
			flow: FlowType.INVALID
		});
	}

	get(opcode) {
		return this.main.get(opcode);
	}

	getCB(opcode) {
		return this.cb.get(opcode);
	}
}

// ============================================================================
// ROM READER
// ============================================================================

class ROMReader {
	constructor(buffer) {
		this.data = new Uint8Array(buffer);
		this.bankSize = Memory.ROM_BANK_SIZE;
		this.numBanks = Math.ceil(this.data.length / this.bankSize);
	}

	static async fromFile(filePath) {
		const buffer = await fs.readFile(filePath);
		return new ROMReader(buffer);
	}

	get length() {
		return this.data.length;
	}

	readByte(romIndex) {
		if (romIndex < 0 || romIndex >= this.data.length) {
			return null;
		}
		return this.data[romIndex];
	}

	readWord(romIndex) {
		const lo = this.readByte(romIndex);
		const hi = this.readByte(romIndex + 1);
		if (lo === null || hi === null) return null;
		return lo | (hi << 8);
	}

	readSignedByte(romIndex) {
		const val = this.readByte(romIndex);
		if (val === null) return null;
		return val > 127 ? val - 256 : val;
	}

	getTitle() {
		let title = '';
		for (let i = Memory.TITLE_START; i <= Memory.TITLE_END; i++) {
			const ch = this.readByte(i);
			if (ch === 0 || ch === null) break;
			title += String.fromCharCode(ch);
		}
		return title.trim();
	}

	getCartridgeType() {
		const type = this.readByte(Memory.CARTRIDGE_TYPE_ADDR);
		const types = {
			0x00: 'ROM ONLY',
			0x01: 'MBC1', 0x02: 'MBC1+RAM', 0x03: 'MBC1+RAM+BATTERY',
			0x05: 'MBC2', 0x06: 'MBC2+BATTERY',
			0x08: 'ROM+RAM', 0x09: 'ROM+RAM+BATTERY',
			0x0B: 'MMM01', 0x0C: 'MMM01+RAM', 0x0D: 'MMM01+RAM+BATTERY',
			0x0F: 'MBC3+TIMER+BATTERY', 0x10: 'MBC3+TIMER+RAM+BATTERY',
			0x11: 'MBC3', 0x12: 'MBC3+RAM', 0x13: 'MBC3+RAM+BATTERY',
			0x19: 'MBC5', 0x1A: 'MBC5+RAM', 0x1B: 'MBC5+RAM+BATTERY',
			0x1C: 'MBC5+RUMBLE', 0x1D: 'MBC5+RUMBLE+RAM', 0x1E: 'MBC5+RUMBLE+RAM+BATTERY',
			0x20: 'MBC6', 0x22: 'MBC7+SENSOR+RUMBLE+RAM+BATTERY',
			0xFC: 'POCKET CAMERA', 0xFD: 'BANDAI TAMA5', 0xFE: 'HuC3', 0xFF: 'HuC1+RAM+BATTERY'
		};
		return types[type] || `UNKNOWN ($${type?.toString(16).padStart(2, '0')})`;
	}

	getROMSizeKB() {
		const code = this.readByte(Memory.ROM_SIZE_ADDR);
		if (code === null) return 0;
		return 32 << code;
	}

	/**
	 * Convert memory address + bank to ROM index
	 */
	memToRomIndex(memAddr, bank) {
		if (memAddr < Memory.ROMX_START) {
			return memAddr; // Bank 0 is always at the start
		}
		return bank * this.bankSize + (memAddr - Memory.ROMX_START);
	}

	/**
	 * Convert ROM index to memory address + bank
	 */
	romIndexToMem(romIndex) {
		if (romIndex < this.bankSize) {
			return { addr: romIndex, bank: 0 };
		}
		const bank = Math.floor(romIndex / this.bankSize);
		const addr = Memory.ROMX_START + (romIndex % this.bankSize);
		return { addr, bank };
	}
}

// ============================================================================
// SYMBOL TABLE
// ============================================================================

class SymbolTable {
	constructor() {
		this.labels = new Map();  // romIndex -> label name
		this.comments = new Map(); // romIndex -> comment
	}

	addLabel(romIndex, bank, memAddr) {
		if (!this.labels.has(romIndex)) {
			const prefix = this._getLabelPrefix(memAddr);
			this.labels.set(romIndex, `${prefix}${bank.toString(16)}_${memAddr.toString(16).padStart(4, '0')}`);
		}
	}

	_getLabelPrefix(memAddr) {
		// Known hardware vectors
		const knownLabels = {
			0x0000: 'RST_00',
			0x0008: 'RST_08',
			0x0010: 'RST_10',
			0x0018: 'RST_18',
			0x0020: 'RST_20',
			0x0028: 'RST_28',
			0x0030: 'RST_30',
			0x0038: 'RST_38',
			0x0040: 'VBlank',
			0x0048: 'LCDC',
			0x0050: 'Timer',
			0x0058: 'Serial',
			0x0060: 'Joypad',
			0x0100: 'EntryPoint',
		};
		if (knownLabels[memAddr]) {
			return knownLabels[memAddr] + '_';
		}
		return 'L';
	}

	getLabel(romIndex) {
		return this.labels.get(romIndex);
	}

	hasLabel(romIndex) {
		return this.labels.has(romIndex);
	}

	addComment(romIndex, comment) {
		this.comments.set(romIndex, comment);
	}

	getComment(romIndex) {
		return this.comments.get(romIndex);
	}
}

// ============================================================================
// CPU STATE (Minimal Emulator for Flow Analysis)
// ============================================================================

class CPUState {
	constructor(bank = 1) {
		this.regs = new Uint8Array(8); // B, C, D, E, H, L, (HL), A
		this.bank = bank;
		this.known = new Uint8Array(8).fill(0); // Bitmask: 1 if value is known
	}

	clone() {
		const newState = new CPUState(this.bank);
		newState.regs.set(this.regs);
		newState.known.set(this.known);
		return newState;
	}

	setReg(idx, val) {
		if (idx === 6) return; // Ignore [HL] for now
		this.regs[idx] = val & 0xFF;
		this.known[idx] = 1;
	}

	invalidate(idx) {
		if (idx === 6) return;
		this.known[idx] = 0;
	}

	isKnown(idx) {
		return this.known[idx] === 1;
	}

	getReg(idx) {
		return this.regs[idx];
	}

	getHL() {
		if (this.isKnown(4) && this.isKnown(5)) {
			return (this.regs[4] << 8) | this.regs[5];
		}
		return null;
	}

	setHL(val) {
		this.setReg(4, (val >> 8) & 0xFF);
		this.setReg(5, val & 0xFF);
	}
}

// ============================================================================
// FLOW ANALYZER
// ============================================================================

class FlowAnalyzer {
	constructor(rom, opcodes, symbols) {
		this.rom = rom;
		this.opcodes = opcodes;
		this.symbols = symbols;
		this.codeMap = new Set();      // ROM indices identified as code
		this.visited = new Map();       // romIdx -> Set of banks visited here
		this.warnings = [];
		this.hooks = new Map();         // targetAddress -> Function

		this._setupDefaultHooks();
	}

	_setupDefaultHooks() {
		// Example: Super Mario Land Inter-bank Call (RST $28)
		// It takes 3 bytes of parameters: bank (1 byte), address (2 bytes)
		this.hooks.set(0x0028, (romIdx, memAddr, bank, state) => {
			const targetBank = this.rom.readByte(romIdx + 1);
			const targetAddr = this.rom.readWord(romIdx + 2);

			if (targetBank !== null && targetAddr !== null) {
				const actualBank = targetBank === 0 ? 1 : targetBank;
				return {
					targets: [{
						memAddr: targetAddr,
						bank: actualBank,
						romIdx: this.rom.memToRomIndex(targetAddr, actualBank)
					}],
					consumed: 3 // consumed 3 bytes after the RST instruction
				};
			}
			return null;
		});
	}

	analyze(entryPoints) {
		const queue = [];

		for (const ep of entryPoints) {
			const state = new CPUState(ep.bank || 1);
			queue.push({ addr: ep.addr, bank: ep.bank || 0, state });

			const romIdx = this.rom.memToRomIndex(ep.addr, ep.bank || 0);
			if (romIdx < this.rom.length) {
				this.symbols.addLabel(romIdx, ep.bank || 0, ep.addr);
			}
		}

		while (queue.length > 0) {
			const { addr, bank, state } = queue.shift();
			this._traceBlock(addr, bank, state, queue);
		}

		return {
			codeMap: this.codeMap,
			warnings: this.warnings
		};
	}

	_traceBlock(startAddr, bank, state, queue) {
		const startRomIdx = this.rom.memToRomIndex(startAddr, bank);

		if (startRomIdx >= this.rom.length) return;

		// If we've been here with this bank before, skip
		if (!this.visited.has(startRomIdx)) {
			this.visited.set(startRomIdx, new Set());
		}
		if (this.visited.get(startRomIdx).has(state.bank)) {
			return;
		}
		this.visited.get(startRomIdx).add(state.bank);

		let currentRomIdx = startRomIdx;
		let currentMemAddr = startAddr;
		let currentBank = bank;

		while (currentRomIdx < this.rom.length) {
			const opcode = this.rom.readByte(currentRomIdx);
			if (opcode === null) break;

			const op = this.opcodes.get(opcode);
			if (!op) break;

			// Handle CB prefix
			let instrLength = op.length;
			if (opcode === 0xCB) {
				const cbOpcode = this.rom.readByte(currentRomIdx + 1);
				if (cbOpcode === null) break;
				instrLength = 2;
			}

			// Boundary Check
			const bankEnd = (Math.floor(currentRomIdx / this.rom.bankSize) + 1) * this.rom.bankSize;
			if (currentRomIdx + instrLength > bankEnd) break;

			this.codeMap.add(currentRomIdx);

			// Check Hooks (e.g., RST $28)
			let hookResult = null;
			if (op.flow === FlowType.RST || op.flow === FlowType.CALL) {
				let targetAddr = (op.flow === FlowType.RST) ? op.target : this.rom.readWord(currentRomIdx + 1);
				if (this.hooks.has(targetAddr)) {
					hookResult = this.hooks.get(targetAddr)(currentRomIdx, currentMemAddr, currentBank, state);
				}
			}

			if (hookResult) {
				for (const target of hookResult.targets) {
					if (target.romIdx < this.rom.length) {
						queue.push({
							addr: target.memAddr,
							bank: target.bank,
							state: state.clone()
						});
						this.symbols.addLabel(target.romIdx, target.bank, target.memAddr);
					}
				}
				// Skip hook parameters in the sweep
				currentRomIdx += instrLength + hookResult.consumed;
				currentMemAddr += instrLength + hookResult.consumed;
				continue;
			}

			// --- EMULATION STEP ---
			this._emulate(opcode, currentRomIdx, state);

			// Process flow control
			const targets = this._getFlowTargets(currentRomIdx, currentMemAddr, currentBank, state, op);
			for (const target of targets) {
				if (target.romIdx < this.rom.length) {
					queue.push({
						addr: target.memAddr,
						bank: target.bank,
						state: state.clone()
					});
					this.symbols.addLabel(target.romIdx, target.bank, target.memAddr);
				}
			}

			// If we jump/call/return, we might change context
			if (this._isFlowTerminator(op.flow)) {
				break;
			}

			// Stop if we hit a label that isn't the start of our block
			if (currentRomIdx !== startRomIdx && this.symbols.hasLabel(currentRomIdx)) {
				// We don't break immediately because we want to follow the code,
				// but BFS will handle the label as a new entry point anyway.
				// However, if we're doing recursive descent, we should merge.
				break;
			}

			currentRomIdx += instrLength;
			currentMemAddr += instrLength;

			if (currentMemAddr >= Memory.VRAM_START) break;
			if (currentMemAddr >= Memory.ROMX_START && startAddr < Memory.ROMX_START) break;
		}
	}

	_emulate(opcode, romIdx, state) {
		// LD r, n
		if ((opcode & 0xC7) === 0x06) {
			state.setReg((opcode >> 3) & 7, this.rom.readByte(romIdx + 1));
		}
		// LD r, r
		else if ((opcode & 0xC0) === 0x40 && opcode !== 0x76) {
			const dst = (opcode >> 3) & 7;
			const src = opcode & 7;
			if (state.isKnown(src)) {
				state.setReg(dst, state.getReg(src));
			} else {
				state.invalidate(dst);
			}
		}
		// LD HL, nn
		else if (opcode === 0x21) {
			state.setHL(this.rom.readWord(romIdx + 1));
		}
		// LD [HL], A
		else if (opcode === 0x77) {
			const hl = state.getHL();
			if (hl !== null && hl >= 0x2000 && hl <= 0x3FFF) {
				if (state.isKnown(7)) {
					const val = state.getReg(7) & 0x1F;
					state.bank = val === 0 ? 1 : val;
				}
			}
		}
		// LD [nnnn], A
		else if (opcode === 0xEA) {
			const addr = this.rom.readWord(romIdx + 1);
			if (addr >= 0x2000 && addr <= 0x3FFF) {
				if (state.isKnown(7)) {
					const val = state.getReg(7) & 0x1F;
					state.bank = val === 0 ? 1 : val;
				}
			}
		}
		// ALU ops affect A
		else if ((opcode & 0xC0) === 0x80 || (opcode & 0xC7) === 0xC6) {
			state.invalidate(7);
		}
	}

	_getFlowTargets(romIdx, memAddr, currentBank, state, op) {
		const targets = [];

		switch (op.flow) {
			case FlowType.RST:
				targets.push({
					memAddr: op.target,
					bank: 0,
					romIdx: op.target
				});
				break;

			case FlowType.JR:
			case FlowType.JR_COND: {
				const offset = this.rom.readSignedByte(romIdx + 1);
				if (offset !== null) {
					const targetMemAddr = memAddr + 2 + offset;
					const targetBank = targetMemAddr < Memory.ROMX_START ? 0 : state.bank;
					targets.push({
						memAddr: targetMemAddr,
						bank: targetBank,
						romIdx: this.rom.memToRomIndex(targetMemAddr, targetBank)
					});
				}
				break;
			}

			case FlowType.JUMP:
			case FlowType.JUMP_COND:
			case FlowType.CALL:
			case FlowType.CALL_COND: {
				const targetMemAddr = this.rom.readWord(romIdx + 1);
				if (targetMemAddr !== null && targetMemAddr < Memory.VRAM_START) {
					const targetBank = targetMemAddr < Memory.ROMX_START ? 0 : state.bank;
					targets.push({
						memAddr: targetMemAddr,
						bank: targetBank,
						romIdx: this.rom.memToRomIndex(targetMemAddr, targetBank)
					});
				}
				break;
			}
		}

		return targets;
	}

	_isFlowTerminator(flow) {
		return flow === FlowType.JUMP ||
			flow === FlowType.JUMP_HL ||
			flow === FlowType.JR ||
			flow === FlowType.RET ||
			flow === FlowType.STOP ||
			flow === FlowType.INVALID;
	}
}

// ============================================================================
// INSTRUCTION FORMATTER
// ============================================================================

class InstructionFormatter {
	constructor(rom, opcodes, symbols, hardware) {
		this.rom = rom;
		this.opcodes = opcodes;
		this.symbols = symbols;
		this.hardware = hardware;
	}

	format(romIdx, currentBank) {
		const opcode = this.rom.readByte(romIdx);
		if (opcode === null) return null;

		// Handle CB prefix
		if (opcode === 0xCB) {
			return this._formatCB(romIdx);
		}

		const op = this.opcodes.get(opcode);
		if (!op) return null;

		let mnemonic = op.mnemonic;
		const { addr: memAddr } = this.rom.romIndexToMem(romIdx);

		if (op.length === 2) {
			mnemonic = this._formatByte(mnemonic, romIdx, memAddr, currentBank, op);
		} else if (op.length === 3) {
			mnemonic = this._formatWord(mnemonic, romIdx, currentBank, op);
		}

		return { mnemonic, length: op.length };
	}

	_formatCB(romIdx) {
		const cbOpcode = this.rom.readByte(romIdx + 1);
		if (cbOpcode === null) return null;

		const cbOp = this.opcodes.getCB(cbOpcode);
		if (!cbOp) return null;

		return { mnemonic: cbOp.mnemonic, length: 2 };
	}

	_formatByte(mnemonic, romIdx, memAddr, bank, op) {
		const val = this.rom.readByte(romIdx + 1);
		if (val === null) return mnemonic;

		// Relative jump
		if (op.flow === FlowType.JR || op.flow === FlowType.JR_COND) {
			const offset = val > 127 ? val - 256 : val;
			const targetMemAddr = memAddr + 2 + offset;
			const targetBank = targetMemAddr < Memory.ROMX_START ? 0 : (bank === 0 ? 1 : bank);
			const targetRomIdx = this.rom.memToRomIndex(targetMemAddr, targetBank);
			const label = this.symbols.getLabel(targetRomIdx) || `$${targetMemAddr.toString(16).padStart(4, '0')}`;
			return mnemonic.replace('{r8}', label);
		}

		// Signed 8-bit (sp+e8)
		if (mnemonic.includes('{s8}')) {
			const offset = val > 127 ? val - 256 : val;
			const sign = offset >= 0 ? '+' : '';
			return mnemonic.replace('{s8}', sign + offset);
		}

		// High RAM address (LDH)
		if (mnemonic.includes('{a8}')) {
			const hwName = this.hardware?.getName(0xFF00 + val);
			if (hwName) {
				return mnemonic.replace('{a8}', hwName);
			}
			return mnemonic.replace('{a8}', `$ff00+$${val.toString(16).padStart(2, '0')}`);
		}

		// Regular 8-bit immediate
		return mnemonic.replace('{d8}', `$${val.toString(16).padStart(2, '0')}`);
	}

	_formatWord(mnemonic, romIdx, bank, op) {
		const val = this.rom.readWord(romIdx + 1);
		if (val === null) return mnemonic;

		// Jump/Call targets - use labels if available
		if (op.flow === FlowType.JUMP || op.flow === FlowType.JUMP_COND ||
			op.flow === FlowType.CALL || op.flow === FlowType.CALL_COND) {

			if (val < Memory.VRAM_START) {
				const targetBank = val < Memory.ROMX_START ? 0 : (bank === 0 ? 1 : bank);
				const targetRomIdx = this.rom.memToRomIndex(val, targetBank);
				const label = this.symbols.getLabel(targetRomIdx);
				if (label) {
					return mnemonic
						.replace('{a16}', label)
						.replace('{d16}', label);
				}
			}
		}

		const hwName = this.hardware?.getName(val);
		if (hwName) {
			return mnemonic
				.replace('{a16}', hwName)
				.replace('{d16}', hwName);
		}

		// Regular 16-bit value
		return mnemonic
			.replace('{a16}', `$${val.toString(16).padStart(4, '0')}`)
			.replace('{d16}', `$${val.toString(16).padStart(4, '0')}`);
	}
}

// ============================================================================
// ASM WRITER
// ============================================================================

class ASMWriter {
	constructor(rom, codeMap, symbols, formatter, options = {}) {
		this.rom = rom;
		this.codeMap = codeMap;
		this.symbols = symbols;
		this.formatter = formatter;
		this.labelWidth = 16;
		this.dumpBytes = options.dumpBytes || 0;
		this.dumpPadding = 40;
	}

	async writeBank(bankIndex, outputDir) {
		const start = bankIndex * this.rom.bankSize;
		const end = Math.min(start + this.rom.bankSize, this.rom.length);

		const lines = [];
		lines.push(this._bankHeader(bankIndex));
		lines.push('INCLUDE "hardware.inc"');
		lines.push('');

		let addr = start;
		while (addr < end) {
			const line = this._formatLine(addr, bankIndex, end);

			let text = line.text;
			if (this.dumpBytes > 0) {
				const { addr: memAddr, bank } = this.rom.romIndexToMem(addr);
				const bytes = [];
				for (let i = 0; i < this.dumpBytes; i++) {
					const b = this.rom.readByte(addr + i);
					if (b === null) break;
					bytes.push(b.toString(16).padStart(2, '0').toUpperCase());
				}
				const dump = `; ${bank.toString(16).padStart(2, '0')}:${memAddr.toString(16).padStart(4, '0')}  ${bytes.join(' ')}`;
				text = text.padEnd(this.dumpPadding) + dump;
			}

			lines.push(text);
			addr += line.length;
		}

		const filename = `bank_${bankIndex.toString().padStart(3, '0')}.asm`;
		const filepath = path.join(outputDir, filename);
		await fs.writeFile(filepath, lines.join('\n') + '\n');

		return { filename, bytes: end - start };
	}

	_bankHeader(bankIndex) {
		const hexIndex = bankIndex.toString(16).toUpperCase();
		if (bankIndex === 0) {
			return `SECTION "ROM Bank 000", ROM0[$0000]`;
		}
		return `SECTION "ROM Bank ${bankIndex.toString().padStart(3, '0')}", ROMX[$4000], BANK[$${hexIndex}]`;
	}

	_formatLine(romIdx, bankIndex, bankEnd) {
		const label = this.symbols.getLabel(romIdx);
		let labelStr = label ? `${label}:` : '';

		if (labelStr.length >= this.labelWidth) {
			labelStr += ' ';
		} else {
			labelStr = labelStr.padEnd(this.labelWidth);
		}

		// Check if this is code
		if (this.codeMap.has(romIdx)) {
			return this._formatCodeLine(romIdx, bankIndex, bankEnd, labelStr);
		}

		// Data byte
		const byte = this.rom.readByte(romIdx);
		return {
			text: `${labelStr}db $${byte.toString(16).padStart(2, '0')}`,
			length: 1
		};
	}

	_formatCodeLine(romIdx, bankIndex, bankEnd, labelStr) {
		const opcode = this.rom.readByte(romIdx);
		const op = this.opcodes?.get(opcode) || { length: 1 };
		const instrLength = opcode === 0xCB ? 2 : op.length;

		// Safety: check for labels in middle of instruction or bank boundary
		let hasLabelInMiddle = false;
		for (let k = 1; k < instrLength; k++) {
			if (this.symbols.hasLabel(romIdx + k)) {
				hasLabelInMiddle = true;
				break;
			}
		}

		if (romIdx + instrLength > bankEnd || hasLabelInMiddle) {
			const byte = this.rom.readByte(romIdx);
			return {
				text: `${labelStr}db $${byte.toString(16).padStart(2, '0')}`,
				length: 1
			};
		}

		const formatted = this.formatter.format(romIdx, bankIndex);
		if (!formatted) {
			const byte = this.rom.readByte(romIdx);
			return {
				text: `${labelStr}db $${byte.toString(16).padStart(2, '0')}`,
				length: 1
			};
		}

		return {
			text: `${labelStr}${formatted.mnemonic}`,
			length: formatted.length
		};
	}
}

// ============================================================================
// HARDWARE SYMBOLS
// ============================================================================

class HardwareSymbols {
	constructor() {
		this.symbols = new Map(); // address -> name
	}

	async load(filepath) {
		try {
			const content = await fs.readFile(filepath, 'utf8');
			const lines = content.split('\n');
			for (const line of lines) {
				// Match: DEF rNAME EQU $addr or rNAME EQU $addr or Name = $addr
				const match = line.match(/^\s*(?:DEF\s+)?([a-zA-Z0-9_]+)\s+(?:EQU|=)\s+\$([0-9a-fA-F]+)/i);
				if (match) {
					const name = match[1];
					const addr = parseInt(match[2], 16);
					// Prefer 'r' names for registers
					if (!this.symbols.has(addr) || name.startsWith('r')) {
						this.symbols.set(addr, name);
					}
				}
			}
		} catch (err) {
			// hardware.inc not found or unreadable, ignore
		}
	}

	getName(addr) {
		return this.symbols.get(addr);
	}
}

// ============================================================================
// DISASSEMBLER (Main Orchestrator)
// ============================================================================

class Disassembler {
	constructor(options = {}) {
		this.options = {
			outputDir: options.outputDir || '.',
			verbose: options.verbose ?? true,
			dumpBytes: options.dumpBytes || 0,
			...options
		};
	}

	async disassemble(romPath) {
		const startTime = Date.now();

		// Load ROM
		this.log(`Loading ROM: ${romPath}`);
		const rom = await ROMReader.fromFile(romPath);
		this._printROMInfo(rom);

		// Initialize components
		const opcodes = new OpcodeTable();
		const symbols = new SymbolTable();
		const hardware = new HardwareSymbols();
		await hardware.load(path.join(path.dirname(romPath), 'hardware.inc'));
		// Also try current directory
		if (hardware.symbols.size === 0) {
			await hardware.load('hardware.inc');
		}

		// Build entry points
		const entryPoints = this._buildEntryPoints();
		this.log(`\nStarting flow analysis from ${entryPoints.length} entry points...`);

		// Analyze code flow
		const analyzer = new FlowAnalyzer(rom, opcodes, symbols);
		const { codeMap, warnings } = analyzer.analyze(entryPoints);

		this.log(`Found ${codeMap.size} code bytes, ${symbols.labels.size} labels, ${hardware.symbols.size} hardware symbols`);

		if (warnings.length > 0) {
			this.log(`\nWarnings (${warnings.length}):`);
			warnings.slice(0, 10).forEach(w => this.log(`  - ${w}`));
			if (warnings.length > 10) {
				this.log(`  ... and ${warnings.length - 10} more`);
			}
		}

		// Write output
		this.log(`\nGenerating assembly files...`);
		const formatter = new InstructionFormatter(rom, opcodes, symbols, hardware);
		const writer = new ASMWriter(rom, codeMap, symbols, formatter, {
			dumpBytes: this.options.dumpBytes
		});
		writer.opcodes = opcodes; // Inject dependency

		await fs.mkdir(this.options.outputDir, { recursive: true });

		// Copy hardware.inc to output directory if it exists
		try {
			const hwSrc = path.join(path.dirname(romPath), 'hardware.inc');
			const hwDst = path.join(this.options.outputDir, 'hardware.inc');
			await fs.copyFile(hwSrc, hwDst);
		} catch (e) {
			try {
				await fs.copyFile('hardware.inc', path.join(this.options.outputDir, 'hardware.inc'));
			} catch (e2) { }
		}

		let totalBytes = 0;
		for (let i = 0; i < rom.numBanks; i++) {
			const result = await writer.writeBank(i, this.options.outputDir);
			totalBytes += result.bytes;
			this.log(`  Generated ${result.filename} (${result.bytes} bytes)`);
		}

		// Write symbol file
		await this._writeSymbols(symbols, rom, this.options.outputDir);

		const elapsed = ((Date.now() - startTime) / 1000).toFixed(2);
		this.log(`\nComplete! ${rom.numBanks} banks, ${totalBytes} bytes in ${elapsed}s`);

		return {
			banks: rom.numBanks,
			totalBytes,
			codeBytes: codeMap.size,
			labels: symbols.labels.size,
			warnings: warnings.length
		};
	}

	_buildEntryPoints() {
		const points = [];

		// Main entry point
		points.push({ addr: EntryPoints.MAIN_ENTRY, bank: 0 });

		// RST vectors
		for (const addr of EntryPoints.RESET_VECTORS) {
			points.push({ addr, bank: 0 });
		}

		// Interrupt vectors
		for (const addr of EntryPoints.INTERRUPT_VECTORS) {
			points.push({ addr, bank: 0 });
		}

		return points;
	}

	async _writeSymbols(symbols, rom, outputDir) {
		const lines = ['; Symbol file generated by GB Disassembler Ultimate', ''];

		const sortedLabels = [...symbols.labels.entries()]
			.sort((a, b) => a[0] - b[0]);

		for (const [romIdx, label] of sortedLabels) {
			const { addr, bank } = rom.romIndexToMem(romIdx);
			lines.push(`${bank.toString(16).padStart(2, '0')}:${addr.toString(16).padStart(4, '0')} ${label}`);
		}

		const filepath = path.join(outputDir, 'symbols.sym');
		await fs.writeFile(filepath, lines.join('\n') + '\n');
		this.log(`  Generated symbols.sym (${symbols.labels.size} symbols)`);
	}

	_printROMInfo(rom) {
		this.log(`  Title: "${rom.getTitle()}"`);
		this.log(`  Type: ${rom.getCartridgeType()}`);
		this.log(`  Size: ${rom.getROMSizeKB()} KB (${rom.numBanks} banks)`);
	}

	log(message) {
		if (this.options.verbose) {
			console.log(message);
		}
	}
}

// ============================================================================
// CLI
// ============================================================================

async function main() {
	const args = process.argv.slice(2);

	if (args.length === 0 || args.includes('--help') || args.includes('-h')) {
		console.log(`
Game Boy ROM Disassembler - Ultimate Edition

Usage: node gb-disassembler.js <rom.gb> [options]

Options:
  -o, --output <dir>   Output directory (default: current directory)
  -d, --dump <N>       Append hex dump of N bytes to each line
  -q, --quiet          Suppress output
  -h, --help           Show this help

Examples:
  node gb-disassembler.js game.gb
  node gb-disassembler.js game.gb -o ./disasm --dump 8
`);
		process.exit(0);
	}

	const romPath = args[0];
	let outputDir = '.';
	let verbose = true;
	let dumpBytes = 0;

	for (let i = 1; i < args.length; i++) {
		if ((args[i] === '-o' || args[i] === '--output') && args[i + 1]) {
			outputDir = args[++i];
		} else if ((args[i] === '-d' || args[i] === '--dump') && args[i + 1]) {
			dumpBytes = parseInt(args[++i], 10);
		} else if (args[i] === '-q' || args[i] === '--quiet') {
			verbose = false;
		}
	}

	try {
		await fs.access(romPath);
	} catch {
		console.error(`Error: File not found: ${romPath}`);
		process.exit(1);
	}

	const disassembler = new Disassembler({ outputDir, verbose, dumpBytes });

	try {
		await disassembler.disassemble(romPath);
	} catch (error) {
		console.error(`Error: ${error.message}`);
		if (verbose) {
			console.error(error.stack);
		}
		process.exit(1);
	}
}

// ============================================================================
// EXPORTS & ENTRY POINT
// ============================================================================

module.exports = {
	Disassembler,
	ROMReader,
	OpcodeTable,
	FlowAnalyzer,
	SymbolTable,
	InstructionFormatter,
	ASMWriter,
	Memory,
	FlowType,
	EntryPoints,
};

if (require.main === module) {
	main().catch(err => {
		console.error('Fatal error:', err);
		process.exit(1);
	});
}