import ExpressionBar from "./expressionBar"
import ExpressionData from "./dataContainer"
import GroupData from "./groupData";
import FactorGroup from "./factorGroup";
import { html_name } from "./factorHelpers";

export default class SortWindow{
	#eb: ExpressionBar;
	#target: string;
	constructor(eb: ExpressionBar){
		this.#eb = eb;
		this.#target = this.#eb.opt.target;
	}

	/**
	 * This function seems to be better somewhere else.
	 * Probably this came as a patch when selected factors whas comning undefined
	 * But should be set up just after the data object is set up. 
	 */
	#setDefault(){
		console.log(this.#eb);
		if (typeof this.#eb.opt.selectedFactors !== 'undefined') {
			this.#eb.data.selectedFactors = this.#eb.opt.selectedFactors;
		}
	}

	#appendSpanButton(target_div :JQuery , id: string, name:string, text: string, icon:string){
		let span = jQuery("<span/>");
		span.attr("id", `${id}_${name}`);
		span.attr("class", `ui-icon ${icon}`);
		span.attr("title", text);
		target_div.append(span);
	}

	#renderSingleFactorDiv(fg: FactorGroup){
		let name =  this.#target + '_sorted_list_' + html_name(fg.name);
		let outer_div = jQuery("<div/>");
		outer_div.attr("id",  `${this.#target}_factor`);
		this.#appendSpanButton(outer_div, "span", name, "Filter/reorder", "ui-icon-arrowthick-2-n-s" );
		outer_div.append("<br/>");
		this.#appendSpanButton(outer_div, "showHide", name,"Display/Hide Category",  "ui-icon-circle-plus");
		return outer_div;
	}

	render(){
		this.#setDefault();
		var data:ExpressionData = this.#eb.data;
		var selectedFactors:object = data.selectedFactors;
		var sorted_div = jQuery("#bar_expression_viewer_sort_div");
		for(let fo in selectedFactors){
			console.log("About to render", fo);
			let fg:FactorGroup = data.factors.get(fo);
			let factors = fg.sortedFactors();
			let fdiv = this.#renderSingleFactorDiv(fg);
			sorted_div.append(fdiv);

		}
		console.log( sorted_div);
	}
}