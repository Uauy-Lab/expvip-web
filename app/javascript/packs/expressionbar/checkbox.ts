import Control from "./control";
import ExpressionBar from "./expressionBar"

class Checkbox extends Control{
	span  : JQuery;
	text_label : JQuery;
	constructor(expression_bar: ExpressionBar, name: string, text: string, container: JQuery){
		super(expression_bar,name,text,container);
	}
	render(){
		this.span = jQuery(`<span/>`);
		this.span.attr("id", `${this.label}Span`)
// <span id="${this.#expression_bar.target}_log2Span"><input type="checkbox" id="${this.#expression_bar.target}_log2" style="cursor: pointer;"><label for="${this.#expression_bar.target}_log2" style="cursor: pointer;">Log<sub>2</sub></label></input></span>
		
		this.el = jQuery(`<input/>`)
		.attr("type", "checkbox")
		.attr("style", "cursor:pointer")
		.attr("id" , this.label);

		this.text_label = jQuery(`<label>${this.text}</label>`)
		.attr("for", this.label)
		.attr("style", "cursor:pointer")
		// for="${this.#expression_bar.target}_log2" style="cursor: pointer;">Log<sub>2</sub></label>

		this.span.append(this.el);
		this.span.append(this.text_label);
		this.container.append(this.span);
	}
}

export default Checkbox;