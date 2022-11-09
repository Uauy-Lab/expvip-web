import OptionData from "./option";
import Gene from "./gene";



export default class OrtholgueGroupSet extends OptionData{
	private _genes: Array<Gene>;
	homologues: boolean;
	genome: string;
	group: string;

	public get genes(): Array<Gene> {
		let ret = this._genes;
		console.log("Homologues: ", this.homologues)
		console.log("Genome: ", this.genome)
		console.log("Group: ", this.group)
		console.log("genes: ", this._genes)
		if(!this.homologues){
			if(this.genome){
				ret = ret.filter((a) => a.genome == this.genome)
			}
			if(this.group){
				ret = ret.filter((a) => a.group == this.group)
			}
		}
		if(ret.length == 0){
			console.error(this._genes)
			console.error(this.genome)
			console.error(this.group)
			throw new Error("Unable to find orthologues in grouo");
			
		}
		return ret;
	}
	public set genes(value: Array<Gene>) {
		this._genes = value;
	}
	
	constructor(obj: object){
		super(obj);
		this.genes = obj["genes"].map((o: object) => new Gene(o));
		this.homologues = false;
		this.genome = null;
		this.group = null;
	}

}