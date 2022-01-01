import ExpressionBar from "./expressionBar"

abstract class Control{
	expression_bar: ExpressionBar;
	name: string;
	label: string;
	text: string;
	container: JQuery;
	el: JQuery;
	
	constructor(expression_bar: ExpressionBar, name: string, text: string, container: JQuery){
		this.expression_bar = expression_bar;
		this.name = name;
		this.label = `${this.expression_bar.target}_${this.name}` 
		this.text = text;
		this.container = container;
		this.render();
	}

	abstract render(): void;

	abstract saveStatus(): void;
}

export default Control;