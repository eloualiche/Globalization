#

all: symlink-data create-data compress-data

clean: 
	rm -rf log/* output/*

symlink-data: 
	gln -rsf ../Replication_all/empirics_all/output/basereturns.dta ./input

create-data:
	R CMD BATCH --vanilla ./src/update_replication.R ./log/update_replication.log.R

compress-data:
	pigz --best -f output/permno_SC.tsv

