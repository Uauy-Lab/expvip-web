import Factor from "./factor";

export default class FactorGroup{
	name: string;
	order: number;
	selected: boolean;
	defaultSelected: boolean;
	factors: Map<string, Factor>;
	constructor(o: object){
		this.name = o["name"];
		this.order = o["order"];
		this.selected = o["selected"];
		this.defaultSelected = this.selected;
		this.factors = new Map<string, Factor>();

		let factors = o["factors"];
		for (let f of factors) {
			let factor = new Factor(f);
			this.factors.set(factor.name, factor);
	   }
	}

	get sortedFactors() : Array<Factor>{
		let factors = [...this.factors.values()]
		return factors.sort((a,b) => a.order - b.order);
	}

	get selectedFactors() : object{
		let factors = [...this.factors.values()]
		let ret = {}
		factors.forEach(f => ret[f.name] = f.selected)
		return  ret;
	}

	get defaultOrder(){
		let ret = {}
		let factors = [...this.factors.values()].forEach(factor => {
			ret[factor.name] = factor.defaultOrder;
		})
		return ret;
	}

	get factorOrder(){
		let ret = {}
		let factors = [...this.factors.values()]
		factors.forEach(factor => {
			ret[factor.name] = factor.order;
		})
		return ret;
	}

	set factorOrder(ord:object){
		for(let key in ord ){
			this.factors.get(key).order = ord[key];
		}
	}

	restoreDefaults(){
		this.selected = this.defaultSelected;
		let factors = [...this.factors.values()]
		factors.forEach(f => f.restoreDefaults());
	}


}