
export default class Option{
	name: string;
	description: string;
	selected: boolean;
	el: JQuery<HTMLElement>;

	constructor(o: object){
		for (var attrname in o) {
			this[attrname] = o[attrname];
		}
	}

	render(){
		this.el = jQuery(`<option>${this.description}</option>`);
		this.el.attr("value", this.name);
		this.el.prop("selected", this.selected);
		return this.el;
	}
}
