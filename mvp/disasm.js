const fs = require('fs').promises
const path = require('path')

const main = async () => {
	const filePath = path.join(__dirname, 'rom.gb')
	const data = await fs.readFile(filePath)
	const bytes = new Uint8Array(data)
	console.error('Read', bytes.length, 'bytes from', filePath)

	const bankSize = 0x4000
	const numBanks = Math.ceil(bytes.length / bankSize)
	console.error('Number of banks:', numBanks)

	const banks = []
	for (let i = 0; i < numBanks; i++) {
		const start = i * bankSize
		const end = Math.min(start + bankSize, bytes.length)
		banks.push(bytes.slice(start, end))
	}

	banks.forEach((bank, index) => {
		// print index*bankSize in hex, padded to 4 digits
		const hexAddress = (index * bankSize).toString(16).toUpperCase().padStart(4, '0')
		const hexIndex = index.toString(16).toUpperCase().padStart(1, '0')
		const bankName = `$${index.toString().padStart(3, '0')}`
		const bankValue = index === 0 ? `ROM0[$${hexIndex}]` : `ROMX[$${hexAddress}], BANK[$${hexIndex}]`

		const bankSection = `SECTION "ROM Bank ${bankName}", ${bankValue}`
		console.error(bankSection)

		bank.forEach((byte, byteIndex) => {
			const byteHex = byte.toString(16).toLowerCase().padStart(2, '0')
			const addressHex = byteIndex.toString(16).toLowerCase().padStart(4, '0')
			console.error(`\t$${addressHex}: db $${byteHex}`)
		})
	})

	return
}

main()
	.catch((err) => {
		console.error(err)
		process.exit(1)
	})
	.finally(() => {
		process.exit(0)
	})
