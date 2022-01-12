import science from 'science';

export default class GroupedValues{
	renderIndex: number;
	id: number;
	name: string;
	#data: Array<object>;
	#value: number;
	#stdev: number;
	description: string;
	factors: object;
	gene: string;
	longDescription: string;
	#log: boolean;

	constructor(index: number, description: string){
		this.renderIndex = index;
		this.id = index;
		this.name = description;
		this.#data = [];
		this.factors = {};
		this.#value = 0;
		this.#stdev = 0.0;
		this.#log = false;
	}

	get data():Array<number>{
		return this.#data.map( o => o  &&  o["value"] ? o["value"] : null).filter( o => o != null) ;
	}

	addValueObject(o: object):void {
		this.#data.push(o);
		this.calculateStats();
	}

	calculateStats():void{
		this.#value = science.stats.mean(this.data);
		this.#stdev = Math.sqrt(science.stats.variance(this.data));		
	};

	get value():number{
		var ret = this.#value;
		if(this.#log){
			ret = ret < 1 ? 0 : Math.log2(ret); 
		}
		return ret;
	}

	get stdev():number{
		var ret = this.#stdev;
		if(this.#log){
			ret = ret < 1 ? 0 : Math.log2(ret); 
		}
		return ret;
	}

	set log(l:boolean){
		this.#log = l;
	}

	get isEmpty():boolean{
		return this.#data.length == 0;
	}
}