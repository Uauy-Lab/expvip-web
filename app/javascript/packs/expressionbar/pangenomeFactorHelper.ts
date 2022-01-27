import Factor from "./factor";
import FactorGroup from "./factorGroup";
import OrtholgueGroupSet from "./OrthologueGroupSet";
import ExpressionData from "./dataContainer"
function getFactorsForOrthologues(ortholog_group: OrtholgueGroupSet): Array<FactorGroup>{
	let chromsomes = new FactorGroup( {
		name: "Chromsome" , 
		order: 11, 
		selected: false, 
		factors: arrayToFactors([...new Set (ortholog_group.genes.map( g => g.chromosome))])
	})
	
	let genomes = new FactorGroup( {
		name: "Genome" , 
		order: 12, 
		selected: false, 
		factors: arrayToFactors([...new Set (ortholog_group.genes.map( g => g.genome))])
	})
	
	let genes = new FactorGroup( {
		name: "Gene" , 
		order: 13, 
		selected: true, 
		factors: arrayToFactors([...new Set (ortholog_group.genes.map( g => g.gene))])
	})
	return [chromsomes, genomes, genes];
}

function getFactorsForGenes(ortholog_group: OrtholgueGroupSet) {
	let ret = new Map<string, object>();
	ortholog_group.genes.forEach(g => {
		let m = {};
		m["Chromsome"] = g.chromosome;
		m["Genome"] = g.genome;
		m["Gene"] = g.gene;
		// ret.set(g.gene, m);
		ret.set(g.full_name, m);
	})
	console.log(ret);
	return ret;
}

function arrayToFactors(elements: string[]){
	return elements.map((value, index) => new Factor({
		name: value, 
		description: value, 
		order: index, 
		selected: true
	}));
}

function recalculateValues(values: object, ortholog_group: OrtholgueGroupSet) {
	console.log("Recalculating values");
	console.log(values);
	console.log(ortholog_group);
}
	
export {getFactorsForOrthologues, recalculateValues, getFactorsForGenes}