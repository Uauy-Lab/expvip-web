import Factor from "./factor";

export default class FactorGroup{
	name: string;
	order: number;
	selected: boolean;
	factors: Map<string, Factor>;
	constructor(o: object){
		this.name = o["name"];
		this.order = o["number"];
		this.selected = o["selected"];
		this.factors = new Map<string, Factor>();
		let factors = o["factors"];
		for (let f of factors) {
			let factor = new Factor(f);
			this.factors.set(factor.name, f);
	   }
	}
}