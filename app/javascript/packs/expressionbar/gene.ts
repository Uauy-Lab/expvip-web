export default class Gene{
	gene_set: String;
	gene: string;
	group: string;
	full_name: string;
	genome: string;
	chromosome: string;
	
	constructor(data: object){
		for (var attrname in data) {
			this[attrname] = data[attrname];			
		}
	} 

}