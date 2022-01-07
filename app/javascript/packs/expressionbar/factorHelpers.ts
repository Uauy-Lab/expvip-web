import Factor from "./factor";
import FactorGroup from "./factorGroup";

function parseFactors(gfs: Array<object>): Map<string, FactorGroup>{
	let ret = new Map<string, FactorGroup>();
	for(const gf of gfs){
		let tmp = new FactorGroup(gf);
		ret.set(tmp.name, tmp);
	}
	return ret;
}

function getGroupFactorDescription(sample: {description: string, name:string, factors:object },groupBy : Array<string>, fgs: Map<string, FactorGroup>):string{
	var factorArray   = getFactorsForSample(sample, groupBy,fgs);
	var numOfFactors  = groupBy.length;
	return factorArray.map(f => numOfFactors > 4 || f.description.length > 20? f.name : f.description).join(', ');
}

function getGroupFactorLongDescription(sample: {description: string, name:string, factors:object },groupBy : Array<string>, fgs: Map<string, FactorGroup>):string{
	var factorArray   = getFactorsForSample(sample, groupBy,fgs);
	return factorArray.map(f => f.description).join(', ');
}

function getFactorsForSample(sample: {description: string, name:string, factors:object },groupBy : Array<string>, fgs: Map<string, FactorGroup>):Array<Factor>{
	var factorArray   = new Array<Factor>();
	for(var grpby of groupBy) {
		let fg = fgs.get(grpby);
		let fact = sample.factors[grpby];
		factorArray.push(fg.factors.get(fact));
	};
	return factorArray;
}

export {parseFactors, getGroupFactorDescription, getGroupFactorLongDescription}