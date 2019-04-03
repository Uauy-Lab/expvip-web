# README #

## Requirements

### Environment
Expvip runs on **Unix-Like** environments (Linux distribution or mac).<br>
**_The project doesn’t run on Windows OS_**
<br>

### Programs
The following must be installed on your environment (minimum requirements):
```
Git
Ruby 2.2
Rails 4.2.1
Nodejs 6.0.0
NPM 3.8.6 || Yarn 1.7.0
MySQL 5.5 (along with its development files - libmysqlclient-dev)
MongoDB 3.4
Kallisto 0.42.3 (optional)
```
Get Kallisto from [here](http://pachterlab.github.io/kallisto/)


### Data
Data required for setting up expvip can be downloaded form [here](http://www.wheat-expression.com/download)

## Setting up expVIP ##
Follow these steps:

### Software code
1. **Clone** the project using **Git** to the default repository. `git clone {SSH/URL}`
2.  Run `npm/yarn install` using the terminal to install the JavaScript dependencies and then run `npm/yarn bundle`.
3.  Run `bundle install` using the terminal to install the gem dependencies.

### Database set up


1.  **Mysql Database**: Set your mysql database with  user and password according to your **Config/Database.yml** file
```yaml
database: expvip
username: expvipUSR
password: expvipPWD
```
2.  Run the following rake tasks to create the database and tables.
```sh
rake db:setup
rake db:migrate
```
3.  Run `sequenceserver` to install **NCBI Blast+** binaries if not installed and to create the database.<br>
Give the path to the **.fasta** file (e.g. ```Triticum_aestivum.IWGSC2.26.cdna.all.fa``` or ```IWGSC_v1.1_ALL_20170706_transcripts.fasta```) where you have downloaded it to your machine for creating the database.
4.  Run the following rake task to load the factors from the file **FactorOrder.tsv** using ```rake load_data:factor[{path-to-FactorOrder.tsv}]```
5.  Run the following rake task to load the metadata from the file **default_metadata.txt** using `rake load_data:metadata[{path-to-default_metadata.txt}]`
6.  Run the following rake task to load the gene set from the file (e.g. ```Triticum_aestivum.IWGSC2.26.cdna.all.fa```) using `rake load_data:ensembl_genes[{gene-set-name},{path-to-The-file-containing-gene-set-data}]`
7.  Run the following rake task to load the homology data from the file (_compara_homolgy.txt_) using `rake load_data:homology_pairs[{gene-set-name},{path-to-the-file-containing-homology-data}]`.  Note that the gene names are not the same as the transcript names, they correspond to the gene name. The file can be genrated with ensembl compara, using the following query:
	```sql
	SELECT 
		homology_member.homology_id, cigar_line, perc_cov, perc_id, perc_pos, 
		gene_member.stable_id as genes, 
		gene_member.genome_db_id
	
	FROM 
	    homology_member 
	INNER JOIN homology USING (homology_id) 
	INNER JOIN method_link_species_set USING (method_link_species_set_id) 
	INNER JOIN gene_member USING (gene_member_id)
	WHERE method_link_species_set.name="T.aes homoeologues";
	```
8.  Start **MongoDB** service in order to populate the table with data.
`sudo service mongod start`
9.  Run the following rake task to load the value data into **MongoDB** from the file containing the value data (_final_output_tmp.txt_)<br> using `rake load_data:values_mongo[First Run,{gene-set-name},{tmp/counts},}{path-to-the-file-containing-tmp-or-counts-value-data}]`.

## Run expVIP
After you have followed all the mentioned steps. Run the following command `npm/yarn start` and navigate to `localhost:3000` in your browser.

## Important Note
 If any step was wrong or missed or needed to be modified please create an issue on expvip repository on GitHub and explain your proposed changes to the documentation.

 ## Contributing
Please submit all issues and pull requests to the [homonecloco/expvip-web](https://github.com/homonecloco/expvip-web) repository!

## Support
If you have any problem or suggestion please open an issue [here](https://github.com/homonecloco/expvip-web/issues).

## License

The MIT License

Copyright (c) 2015, Ricardo H. Ramirez-Gonzalez

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
