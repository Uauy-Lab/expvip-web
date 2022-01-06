export default class Factor{
	name: string;
	description: string;
	order: number;
	constructor(o: object){
		this.name = o["name"];
		this.description = o["description"];
		this.order = o["order"];
	}
}