import OptionData from "./option";
import Gene from "./gene";

export default class OrtholgueGroupSet extends OptionData{
	genes: Array<Gene>;

	constructor(obj: object){
		super(obj);
		this.genes = obj["genes"].map((o: object) => new Gene(o));
	}

}