
import jQuery from 'jquery';
import Control from './control';
import ExpressionBar from "./expressionBar"

class Button extends Control{
	saveStatus(): void {
		throw new Error('Method not implemented.');
	}

	constructor(expression_bar: ExpressionBar, name: string, text: string, container: JQuery){
		super(expression_bar,name,text,container);
	}

	render(){
		this.el = jQuery(`<button>${this.text}</button>`);
		this.el.attr("type", "button");
		this.el.attr("style", "cursor:pointer");
		this.el.attr("id" , this.label);
		this.el.on("click", evt => this.expression_bar[this.name]());
		this.container.append(this.el);
	}

}

export default Button;
