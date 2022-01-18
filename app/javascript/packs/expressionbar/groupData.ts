import { group } from "console";
import GroupedValues from "./groupedValues";
import ExpressionData from "./dataContainer";

export default class GroupData{
	#dataContainer: ExpressionData;

	constructor(dataContainer : ExpressionData){
		this.#dataContainer = dataContainer;
	}

	group(values: object, genes: Array<string>, property:string, groupBy: Array<string>){
		let ret = new Array<Array<GroupedValues>();
		for(let gene in genes){
			let data = values[gene][property];

		}
		return ret;
	}

	fillGroupByFactor(index: number, gene: string, data: object, groupBy: Array<string>){
		var groups ={};
		
		var innerArray: GroupedValues[] = new Array<GroupedValues>();
		var g = this.#dataContainer.groups;
		var e = this.#dataContainer.experiments;
		var names = [];
		var o: string ;
		var i = index;

		for(o in g){  
			var description = this.#dataContainer.getGroupFactorDescription(g[o], groupBy);
			var longDescription = this.#dataContainer.getGroupFactorLongDescription(g[o], groupBy);
			if(names.indexOf(description) === -1){
				var newObject = new GroupedValues(i++, description);
				newObject.gene = gene;
				newObject.longDescription = longDescription;
				var factorValues = this.#dataContainer.getGroupFactor(g[o], groupBy);
				newObject.factors = factorValues;
				groups[description] = newObject;
				names.push(description);
			}
		}
		i = index;
		for(o in e){
			if( !data  || typeof data[o] === 'undefined' ){
				continue; //This is for the cases when the data is set up but not defined
			}
			var group = g[e[data[o].experiment].group];

			if(!this.#dataContainer.isFiltered(group)){
				var description = this.#dataContainer.getGroupFactorDescription(g[e[o].group], groupBy);
				groups[description].addValueObject(data[o]);
			}
		}
		for(o in groups){
			var newObject = groups[o];
			if(newObject.isEmpty){
				continue;
			}
			newObject.log = this.#dataContainer.isLog();
			innerArray.push(newObject);
		}
		return innerArray;
	};
}