const fs = require('fs').promises
const { spawn } = require('child_process')

function getGitDiff(commitA, commitB, options = {}) {
	return new Promise((resolve, reject) => {
		const args = ['diff', commitA, commitB]

		if (options.ignoreWhitespace) {
			args.push('-w')
		}

		if (options.repoPath) {
			args.unshift('-C', options.repoPath)
		}

		const git = spawn('git', args)

		let stdout = ''
		let stderr = ''

		git.stdout.on('data', (chunk) => {
			stdout += chunk.toString()
		})

		git.stderr.on('data', (chunk) => {
			stderr += chunk.toString()
		})

		git.on('error', reject)

		git.on('close', (code) => {
			if (code !== 0) {
				reject(new Error(`git diff failed (code ${code})\n${stderr}`))
			} else {
				resolve(stdout)
			}
		})
	})
}

const getPythonLog = async () => {
	const content = await fs.readFile('./python.log', { encoding: 'utf-8' })
	const [head, ...tail] = content.split('python3 scripts/bfs_explorer.py').pop().split('[CLAUDE] Lancement...')
	const last = tail.pop()
	return tail.map((str) => str.split('────────────────────────────────────────────────────────────')[1])
}

const getGitLog = async () => {
	const content = await fs.readFile('./git.log', { encoding: 'utf-8' })
	return content.split('\n').map((str) => {
		const [head, ...tail] = str.split(' ')
		return {
			hash: head,
			comment: tail.join(' '),
		}
	})
}

const main = async () => {
	const pl = await getPythonLog()
	const gl = await getGitLog()

	// pl.length = 1

	const result = []
	for (let index = 0; index < pl.length; index++) {
		const pi = index
		const gi = pl.length - (index + 1)
		const { hash: prev } = gl[gi + 1]
		const g = gl[gi]

		let diff = ''
		while (diff.length === 0) {
			try {
				diff = await getGitDiff(prev, g.hash)
			} catch (e) {
				console.error(e)

				diff = ''
			}
		}

		result.push(Object.assign({ diff, log: pl[pi], prev }, g))
	}

	return JSON.stringify(result, null, 2)
}

main()
	.then((res) => console.log(res))
	.catch((err) => console.error(err))
