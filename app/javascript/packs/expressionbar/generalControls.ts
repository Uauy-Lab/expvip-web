import jQuery from 'jquery';
import ExpressionData from "./dataContainer"
import ExpressionBar from "./expressionBar"

class GeneralControls{
	#container : ExpressionBar;
	#data : ExpressionData;
	constructor(container : ExpressionBar , data: ExpressionData ){
		this.#container = container;
		this.#data = data;
	}

	toggleHomologueButtons(){
		if(!this.#data.hasHomologues){
			jQuery(`#${this.#container.target}_homSpan`).hide('fast');
			jQuery(`#${this.#container.target}_ternSpan`).html("");
			this.#container.storeValue('showTernaryPlot',false);
			this.#container.storeValue('showHomoeologues',false);
		}else {  // If there is homoeologues
			jQuery(`#${this.#container.target}_homSpan`).css('display', 'initial');
			jQuery(`#${this.#container.target}_ternSpan`).css('display', 'initial');
		}
	}

	toggleTernButtons(){
		if(this.#data.hasTern ){
			jQuery(`#${this.#container.target}_ternSpan`).css('display', 'initial');
		}else {
			jQuery(`#${this.#container.target}_ternSpan`).html("No homologies for ternary plot").css('display', 'initial').css('color', 'red');
			this.#container.storeValue('showTernaryPlot',false);
		}
	}
}
export default GeneralControls;