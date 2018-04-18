SELECT * FROM wheat_expression_dev.expression_values 
INNER JOIN genes ON gene_id=genes.id WHERE genes.name="Traes_7DS_FFE9ACDAB.2"; 

SELECT genes.id, genes.name FROM genes WHERE genes.id=105175;


SELECT * from type_of_values;


SELECT 
    *
FROM
    studies
        INNER JOIN
    experiments ON studies.id = experiments.study_id;


--This query doesnt work after the MongoDB update
SELECT 
    gene_id,
    genes.name,
    expression_values.value,
	type_of_values.name,
	experiments.id as experiment,
	experiments.accession,
	studies.id as study,
    studies.accession,
	experiment_group_id, 
	experiment_groups.description
FROM
    genes
        INNER JOIN
    expression_values ON gene_id = genes.id
        INNER JOIN
    type_of_values ON expression_values.type_of_value_id = type_of_values.id
        INNER JOIN
    experiments ON expression_values.experiment_id = experiments.id
        INNER JOIN
    studies ON studies.id = experiments.study_id
		INNER JOIN 
	experiment_groups_experiments ON experiment_groups_experiments.experiment_id = experiments.id
		INNER JOIN
	experiment_groups ON experiment_groups_experiments.experiment_group_id = experiment_groups.id
WHERE
    genes.name = 'Traes_7DS_FFE9ACDAB.2'
ORDER by	
	type_of_values.id,
	studies.id,
	experiments.id
; 

--This works with Compara 80

select * from gene_member where genome_db_id IN (SELECT genome_db_id FROM genome_db WHERE assembly="IWGSC2" and assembly_default=0);
select * from gene_member ;
SELECT * FROM genome_db WHERE assembly="IWGSC2";
SELECT * FROM genome_db;
select * from species_set;


SELECT * FROM 
gene_member
 INNER JOIN
genome_db ON gene_member.genome_db_id = genome_db.genome_db_id
where genome_db.name = "triticum_aestivum";

-- From the documentation:

SELECT homology_member.* FROM 
    homology_member JOIN homology USING (homology_id) 
INNER JOIN method_link_species_set USING (method_link_species_set_id) 
WHERE name="T.aes homoeologues" LIMIT 2;

--To get all the homology groups
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

