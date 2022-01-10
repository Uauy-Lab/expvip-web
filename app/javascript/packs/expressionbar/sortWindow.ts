import jQuery from 'jquery'
import ExpressionBar from "./expressionBar"
import ExpressionData from "./dataContainer"
import GroupData from "./groupData";
import FactorGroup from "./factorGroup";
import { html_name } from "./factorHelpers";
import Factor from "./factor";

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
		span.css("margin", 0);
		return span;
		// target_div.append(span);
	}

	#renderSingleFactorDiv(fg: FactorGroup){
		let name =  this.#target + '_sorted_list_' + html_name(fg.name);
		let outer_div = jQuery("<div/>");
		outer_div.attr("id", name);
		outer_div.attr("class",  `${this.#target}_factor`);
		outer_div.attr("style", "display: inline-block; text-align: centre; width: 16px; margin-left: 2px;");
		let span_div = this.#appendSpanButton(outer_div, "span", name, "Filter/reorder", "ui-icon-arrowthick-2-n-s" );
		outer_div.append(span_div);
		outer_div.append("<br/>");
		let show_hide_div = this.#appendSpanButton(outer_div, "showHide", name,"Display/Hide Category",  "ui-icon-circle-plus");
		outer_div.append(show_hide_div);
		let dialog_div = this.#appendFactorDialog(fg, name, outer_div);
		this.#addShowAndHideForCategoryCheckbox(span_div, dialog_div);
		return outer_div;
	}

	#addShowAndHideForCategoryCheckbox(category_span: JQuery, menu:JQuery){
		category_span.on("click", e=>{
			menu.show();
		})
		jQuery(document).on("mouseup", e=>{
			if(!menu.is(e.target) &&
				menu.has(e.target).length === 0 ){
				menu.hide();
			}
		})
	}

	#appendFactorControlButtons(name: string, action: string, target_div: JQuery, set: boolean){
		let div = jQuery(`<div>${action}</div>`);
		div.attr("id", `${action}_${name}`);
		div.css("cursor", "pointer");
		div.on("click", e => this.#eb.selectAllorNoneFactor(name , set) );
		target_div.append(div);
	}

	#appendFactorDialog(fg: FactorGroup, name:string, div: JQuery){
		let factors = fg.sortedFactors();
		let dialog_div = jQuery("<div/>");
		dialog_div.attr("id", `dialog_${name}`);
		dialog_div.attr("style", `z-index:3; overflow:auto; min-width:250px; max-height:${this.#eb.opt.height / 2}px`);
		this.#appendFactorControlButtons(name, "all", dialog_div, true);
		this.#appendFactorControlButtons(name, "none", dialog_div, false);
		let form_div = jQuery("<div/>");
		form_div.attr("id", `div_${name}`);
		let form = jQuery("<form/>");
		form.attr("style", "text-align: centre;");
		// form.attr("class", "ui-sortable");
		form.attr("id", name);
		for(let f of factors){
			this.#appendFactorCheckbox(f, fg, form);
		}
		form.css('text-align', 'centre');
		form.css('max-width', '100%;');
		form.css('overflow-x', 'hidden;');
		form.sortable({
		  axis: "y",
		  update:  (event, ui) => {
			var factor = ui.item.data('factor');
			// var value = ui.item.data('value');
			// var index = ui.item.index();
			this.#refershSortedOrder(factor);
		  }
		});
		dialog_div.append(form);
		div.append(dialog_div);
		dialog_div.hide();

		return dialog_div;
	}

	#refershSortedOrder(factor: string) {
		var self = this;
	
		var find = html_name(factor);
		var name = this.#target + '_sorted_list_' + find;
		jQuery('#' + name + ' div').each(function (e) {
		  let div = jQuery(this);
		  var factor = div.data('factor');
		  var value = div.data('value');
		  console.log(div[0]);
		  console.log(factor);
		  console.log(value);
		  console.log(self.#eb.data.renderedOrder);
		  self.#eb.data.renderedOrder[factor][value] = div.index();
		}
		);
		this.#eb.data.addSortPriority(factor, false);
		this.#eb.storeValue('sortOrder', this.#eb.data.sortOrder);
		this.#eb.storeValue('renderedOrder', this.#eb.renderedOrder);
	
		this.#eb.data.sortRenderedGroups(this.#eb.data.sortOrder, this.#eb.renderedOrder);
		this.#eb.setFactorColor(factor);
		this.#eb.refresh();
	  }

	#appendFactorCheckbox(f: Factor, fg: FactorGroup, form: JQuery){
		let toDisplay = f.description.length > 40 ? f.name : f.description;
		let selectedFactors = this.#eb.data.selectedFactors;
		let shortId = `${html_name(fg.name)}|${f.name}`;
		let outer_div = jQuery(`<div/>`);
		outer_div.attr("id", `${this.#eb.opt.target}_sorted_position:${f.name}`);
		outer_div.attr("style", `background-color:${f.color}`);
		outer_div.attr("height", this.#eb.opt.barHeight);
		outer_div.attr("data-factor", fg.name);
		outer_div.attr("data-value", f.name);
		outer_div.attr("title", f.description);
		
		let checkbox = jQuery("<input/>");
		checkbox.attr("id", shortId);
		checkbox.attr("type", "checkbox");
		checkbox.attr("data-factor", fg.name);
		checkbox.attr("data-value", f.name);
		checkbox.prop("checked", selectedFactors[fg.name][f.name]);

		checkbox.on("click",  (evt) => {
			this.#eb._updateFilteredFactors(this.#eb.sortDivId);
			if (this.#eb.refreshSVGEnabled == true) {
			  this.#eb.updateGroupBy(this.#eb);
			  this.#eb.refreshSVG(this.#eb);
			  this.#eb.data.sortRenderedGroups();
			  this.#eb.refresh();
			}
		  });

		outer_div.append(checkbox);
		outer_div.append(toDisplay);
		form.append(outer_div);
	}

	render(){
		this.#setDefault();
		var data:ExpressionData = this.#eb.data;
		var selectedFactors:object = data.selectedFactors;
		var sorted_div = jQuery(`#${this.#eb.sortDivId}`);
		for(let fo in selectedFactors){
			console.log("About to render", fo);
			let fg:FactorGroup = data.factors.get(fo);
			let fdiv = this.#renderSingleFactorDiv(fg);
			sorted_div.append(fdiv);

		}
		sorted_div.tooltip({
			track: true
		})
		console.log( sorted_div);
	}
}