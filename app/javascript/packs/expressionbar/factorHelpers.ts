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

function html_name(name: string):string{
	return name.split(" ").join("_");
}


function parseOrthoGroups(o: object):Map<string, OrtholgueGroupSet>{
	let ret = new Map<string, OrtholgueGroupSet>();

	for (var attrname in o) {
		ret.set(attrname, new OrtholgueGroupSet(o[attrname]));
	}
	return ret;

} 

export {parseFactors, getGroupFactorDescription, getGroupFactorLongDescription, html_name}