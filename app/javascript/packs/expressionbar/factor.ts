export default class Factor{
	name: string;
	description: string;
	#order: number;
	color: string;
	defaultOrder: number;
	selected: boolean;
	defaultSelected: boolean;
	constructor(o: object){
		// console.log("Mira...")
		// console.log(o);
		this.name = o["name"];
		this.description = o["description"];
		// console.log(o['order']);
		this.order = o["order"];
		// console.log(this.order);
		this.defaultOrder = o["order"];
		this.selected = o["selected"];
		this.defaultSelected = this.selected;
	}

	set order(o: number){
		if(typeof o !== "number"){
			throw Error("Not setting up a number");
		}
		this.#order = o;
	}

	get order(){
		return this.#order;
	}

	restoreDefaults(){
		this.#order = this.defaultOrder;
		this.selected = this.defaultSelected;
	}
}