const data = require('./analyzer.json')
const fs = require('fs').promises

const markdown = ({ diff, log, prev, hash, comment }) => {
	const lines = []
	lines.push('Consulte le [script]("../scripts/bfs_explorer.py") qui a permis de générer ces informations')
	lines.push('')
	lines.push("Je souhaite pouvoir améliorer ce script en te laissant constater les résultats qu'il a  produit")
	lines.push('')
	lines.push('Voici le commentaire git')
	lines.push('<CommentaireGit>')
	lines.push(comment)
	lines.push('</CommentaireGit>')
	lines.push('')
	lines.push('Le diff git')
	lines.push('<DiffGit>')
	lines.push(diff)
	lines.push('</DiffGit>')
	lines.push('')
	lines.push('Tes réflexions produites dans la production finale. Ces commenentaires ont été coupés.')
	lines.push('<ReflexionAgent>')
	lines.push(log)
	lines.push('</ReflexionAgent>')
	lines.push('')
	lines.push('Je veux que tu améliores le [fichier des conseils](../recommendations.md) en y insérant :')
	lines.push('- des critiques sur le prompt initial')
	lines.push("- des pistes d'améliorations")
	lines.push('- les découvertes que tu pourrais faire')
	lines.push('')
	lines.push('Dans ce meme fichier, je souhaite que tu établisses une note de réalisation pour cette étape')
	return lines.join('\n')
}

const main = async () => {
	const commands = data.map(async (element, i) => {
		const filename = `${__dirname}/logs/report_${String(i).padStart(5, '0')}.md`
		const content = markdown(element)
		return fs.writeFile(filename, content, 'utf-8')
	})
	await Promise.all(commands)

	return 'markdown(data[0])'
}

main()
	.then((res) => console.log(res))
	.catch((err) => console.error(err))
