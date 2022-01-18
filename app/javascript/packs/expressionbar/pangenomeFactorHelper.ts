import Factor from "./factor";
import FactorGroup from "./factorGroup";
import OrtholgueGroupSet from "./OrthologueGroupSet";

function getFactorsForOrthilogues(ortholog_group: OrtholgueGroupSet): Array<FactorGroup>{
	let genomes = new FactorGroup( {
		name: "Genome" , 
		order: 11, 
		selected: false, 
		factors: arrayToFactors([...new Set (ortholog_group.genes.map( g => g.genome))])
	})
	let chromsomes = new FactorGroup( {
		name: "Chromsome" , 
		order: 12, 
		selected: false, 
		factors: arrayToFactors([...new Set (ortholog_group.genes.map( g => g.chromsome))])
	})
	let genes = new FactorGroup( {
		name: "Gene" , 
		order: 13, 
		selected: true, 
		factors: arrayToFactors([...new Set (ortholog_group.genes.map( g => g.gene))])
	})
	return [genomes, chromsomes, genes];
}

function arrayToFactors(elements: string[]){
	return elements.map(
		(value, index) => new Factor({
			name: value, 
			description: value, 
			order: index, 
			selected: true
		})
		);
	}


export {getFactorsForOrthilogues}