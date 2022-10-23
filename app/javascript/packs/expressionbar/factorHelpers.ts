import Factor from "./factor";
import FactorGroup from "./factorGroup";
import OrtholgueGroupSet from "./OrthologueGroupSet"
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
	// console.log(groupBy);
	var numOfFactors  = groupBy.length;
	let ret = "Not read";
	try {
		// console.log(factorArray);
		ret = factorArray.map(f => numOfFactors > 4 || f.description.length > 20? f.name : f.description).join(', ');
	} catch (error  ) {
		throw error;
	}
	return ret;
}

function getGroupFactorLongDescription(sample: {description: string, name:string, factors:object },groupBy : Array<string>, fgs: Map<string, FactorGroup>):string{
	var factorArray   = getFactorsForSample(sample, groupBy,fgs,);
	return factorArray.map(f => f.description).join(', ');
}

function getFactorsForSample(sample: {description: string, name:string, factors:object },groupBy : Array<string>, fgs: Map<string, FactorGroup>):Array<Factor>{
	var factorArray   = new Array<Factor>();
	for(var grpby of groupBy) {
		let fg = fgs.get(grpby);
		let fact = sample.factors[grpby];
		if(fact && fg){
			// console.log(fact);
			factorArray.push(fg.factors.get(fact));
		}else{
			// console.warn(`Can't find Factor for ${grpby}`);
			// console.error(grpby)
			// console.log(sample.factors);
			// console.log(fg);
		}
	};
	return factorArray;
}

function html_name(name: string):string{
	return name.split(" ").join("_");
}


function parseOrthoGroups(o: object):Map<string, OrtholgueGroupSet>{
	let ret = new Map<string, OrtholgueGroupSet>();
	for (var attrname in o) {
		ret.set(attrname, new OrtholgueGroupSet(o[attrname]));
	}
	console.log(ret);
	return ret;

} 


export {parseFactors, getGroupFactorDescription, getGroupFactorLongDescription, html_name, parseOrthoGroups}