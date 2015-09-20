# README #


##Loading data ##

To laod data in the database, a set of rake tasks is provded. 

###Available factors and their order. 
The first thing to do is to setup the available factors. Each file looks like:

```
factor	order	name	short
Age	1	7 days	7d
Age	2	seedling stage	see
Age	3	14 days	14d
Age	4	three leaf stage	3_lea
Age	5	24 days	24d
Age	6	tillering stage	till
Age	7	fifth leaf stage	5_lea
Age	8	1 cm spike	1_sp
Age	9	two nodes detectable	2_no
Age	10	flag leaf stage	f_lea
Age	11	anthesis	anth
Age	12	2 dpa	2dpa
Age	13	4 dpa	4dpa
Age	14	6 dpa	6dpa
Age	15	8 dpa	8dpa
Age	16	9 dpa	9dpa
Age	17	10 dpa	10dpa
Age	18	11 dpa	11dpa
Age	19	12 dpa	12dpa
Age	20	4-12 dpa	4+dpa
Age	21	14 dpa	14dpa
Age	22	15 dpa	15dpa
Age	23	20 dpa	20dpa
Age	24	25 dpa	25dpa
Age	25	30 dpa	30dpa
Age	26	35 dpa	35dpa
```
Alternatively, a single file with all the factors on the same columns can be used to populate the table. The order of the columns is not important, as long as the headers are consistant.  

To load several files of factors do the following:

```sh
for f in ./FactorOrders/*.tsv; do 
	rake load_data:factor[$f]; 
done

```
###Experiment Metadata ###

The second step is to load the experiment meta data. Currently, a tab separated file is the input and it must contain the following columns with the header named exactly as stated:

* **secondary\_study\_accession**
* **run\_accession**
* **scientific\_name**
* **experiment\_title**
* **study\_title**
* **Variety**
* **Tissue**
* **Age**
* **Stress/disease**
* **Manuscript**
* **Group\_for\_averaging**
* **Group\_number\_for\_averaging**
* **Total reads**	
* **Mapped reads**
* **High level variety**
* **High level tissue**
* **High level age**
* **High level stress/disease**



The rake task is :

```sh
rake load_data:metadata[metadata.txt]
```

### Loading the gene sets ###
Before loading the actual expression, it is necesary to load the gene models. Currently, only the fasta file with the cdna from ensembl is supported. The fasta header should contain the following fields, besides the gene name (first string in the header).

* **cdna**
* **chromosome** or **scaffold** are converted to possition
* **gene** 
* **transcript** 
* **description** a free text, in quotes. Any other field with quotes may fail in the load. 

```sh
rake load_data:ensembl_genes[IWGSC2.26,/Triticum_aestivum.IWGSC2.26.cdna.all.fa]
```
#Loading the homologies
In order to show the homoeologues, a file with the homoeologies must bue loaded. The file is tab separated with the following format:

```
Gene	A	B	D	Group	Genome
Traes_5BS_0AFC3F795		Traes_5BS_0AFC3F795	Traes_5DS_C204EBAA9	5	B
Traes_5DS_C204EBAA9		Traes_5BS_0AFC3F795	Traes_5DS_C204EBAA9	5	D
Traes_7DL_82360D4EE1			Traes_7DL_82360D4EE1	7	D
Traes_2AL_1368BE0AD	Traes_2AL_1368BE0AD	Traes_2BL_CD459994C1		2	A
```

Note that the gene names are not the same as the transcript names, they correspond to the gene name. The file can be genrated with ensembl compara, using the following query:

```
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

Then, to fomrat the result of the query (saved as ```compara_homology.txt```), you can use the probided script

```sh
ruby bin/homologyTable.rb compara_homolgy.txt homology.txt homology_counts.txt
```
You can get your homologies elsewhere, as long as you keep the file format. 

```sh
rake load_data:homology[IWGSC2.26,/homology.txt]
```


###Loading values ###

The values are stored in a single long table. This allows to get new values, should we want to.  In order to load the data, the task ```load_data:values``` is provided. The table must contain a column ```target_id``` that has the gene name, as the first field in the fasta file used for the mapping. The rest of the columns most contain a header with the accession of the experiment. Each row represents a value. All the values in the table must be from the same time. For exaple, to load the FPKMs, the following command is used. 

```sh
rake "load_data:values[First run,IWGSC2.26,fpkm,edited_final_output_fpkm.txt]"
```



