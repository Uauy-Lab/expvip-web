import FactorGroup from "./factorGroup";

export default function parseFactors(gfs: Array<object>): Map<string, FactorGroup>{
	var ret = new Map<string, FactorGroup>();
	// console.log("Parsing....");
	// console.log(gfs);
	for(const gf of gfs){
		// console.log(gf);
		var tmp = new FactorGroup(gf);
		// console.log(tmp);
		ret.set(tmp.name, tmp);
	}
	// console.log("About to return...");
	// console.log(ret);
	return ret;
}