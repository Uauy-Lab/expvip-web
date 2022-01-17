import Control from "./control";
import ExpressionBar from "./expressionBar";
import Option from "./option";

export default class Select extends Control{
	span  : JQuery;
	text_label : JQuery;
	#options: Option[];

	constructor(expression_bar: ExpressionBar, name: string, text: string, container: JQuery, options: Array<Option> ){
		super(expression_bar, name, text, container);
		this.options = options;
	}

	render(): void {
		this.span = jQuery(`<span/>`);
		this.span.attr("id", `${this.label}Span`);
		
		this.text_label = jQuery(`<label>${this.text}</label>`)
		.attr("for", this.label)
		.attr("style", "cursor:pointer");
		
		this.el = jQuery(`<select/>`)
		.attr("id" , this.label)
		.on("change", (evt) => this.saveStatus() );

		

		this.span.append(this.text_label);
		this.span.append(this.el);
		
		this.container.append(this.span);
	}

	saveStatus(): void {
		throw new Error("Method not implemented.");
	}

	set options(options:Option[]){
		this.#options = options;
		this.#options.forEach( o => this.el.append(o.render()))
	}

}