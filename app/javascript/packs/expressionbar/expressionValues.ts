class ExpressionValues{
	name: string;
	path: string;
	loaded: boolean;
	#values: Map<string, object>;
	loading: boolean;

	constructor(name:string, path:string){
		this.name = name;
		this.path = path;
		this.loaded = false;
		this.loading = false;
	}

	async load(){
		console.log("Loading...");
		if(this.loaded){
			return;
		}
		if(this.loading){
			while(this.loading){
				await delay(500);
			}
			return;
		}
		this.loading = true;
		const fetch_promise = fetch(this.path);
		await fetch_promise.then (data => data.json()) 
		.then (data => {
			console.log("Returned json:");
			console.log(data)
			console.log(data["values"])
			this.#values = new Map();
			Object.keys(data["values"]).forEach(k=>{
				this.#values.set(k, data["values"[k]])
			})
			this.loaded = true;
		})
  		.catch((error) => {
     		console.error(error)
  		}).finally(() => {
			  this.loading = false;
		});
	}

	get  values(): object{
		this.load();
		console.log("The values are:");
		console.log(this.#values)
		return this.#values;

	}

	get types(): string[]{
		this.load();
		return Object.keys(this.#values);
	}

}

// module.exports.ExpressionValues = ExpressionValues;
export default ExpressionValues;
function delay(ms: number) {
	return new Promise( resolve => setTimeout(resolve, ms) );
}

